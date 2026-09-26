const std = @import("std");
const linux = std.os.linux;

const sector_size = 512;
const blkgetsize64: u32 = 0x80081272;

fn errnoName(rc: usize) []const u8 {
    return @tagName(linux.errno(rc));
}

fn writeAll(fd: linux.fd_t, bytes: []const u8) void {
    var off: usize = 0;
    while (off < bytes.len) {
        const rc = linux.write(fd, bytes.ptr + off, bytes.len - off);
        if (linux.errno(rc) != .SUCCESS)
            return;
        off += rc;
    }
}

fn log(comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const out = std.fmt.bufPrint(&buf, fmt, args) catch return;
    writeAll(1, out);
}

fn ensureDir(path: [*:0]const u8) void {
    const rc = linux.mkdir(path, 0o755);
    const err = linux.errno(rc);
    if (err != .SUCCESS and err != .EXIST)
        log("{s}\n", .{"{\"event\":\"mkdir_failed\"}"});
}

fn mountPseudo(source: ?[*:0]const u8, target: [*:0]const u8, fstype: [*:0]const u8) void {
    const rc = linux.mount(source, target, fstype, 0, 0);
    const err = linux.errno(rc);
    if (err == .SUCCESS or err == .BUSY)
        return;
    log("{{\"event\":\"mount_failed\",\"errno\":\"{s}\"}}\n", .{@tagName(err)});
}

fn sleepSeconds(seconds: i64) void {
    var req = linux.timespec{ .sec = seconds, .nsec = 0 };
    while (true) {
        var rem: linux.timespec = undefined;
        const rc = linux.nanosleep(&req, &rem);
        if (linux.errno(rc) == .SUCCESS)
            return;
        if (linux.errno(rc) != .INTR)
            return;
        req = rem;
    }
}

fn readLe32(bytes: []const u8) u32 {
    return @as(u32, bytes[0]) |
        (@as(u32, bytes[1]) << 8) |
        (@as(u32, bytes[2]) << 16) |
        (@as(u32, bytes[3]) << 24);
}

fn readLe64(bytes: []const u8) u64 {
    return @as(u64, readLe32(bytes[0..4])) |
        (@as(u64, readLe32(bytes[4..8])) << 32);
}

const GptHeader = struct {
    revision: u32,
    header_size: u32,
    current_lba: u64,
    backup_lba: u64,
    first_usable_lba: u64,
    last_usable_lba: u64,
    entries_lba: u64,
    entry_count: u32,
    entry_size: u32,
};

fn parseGptHeader(sector: []const u8) ?GptHeader {
    if (sector.len < sector_size)
        return null;
    if (!std.mem.eql(u8, sector[0..8], "EFI PART"))
        return null;
    const header_size = readLe32(sector[12..16]);
    if (header_size < 92 or header_size > sector_size)
        return null;
    const entry_size = readLe32(sector[84..88]);
    if (entry_size < 128 or entry_size > 4096)
        return null;
    return .{
        .revision = readLe32(sector[8..12]),
        .header_size = header_size,
        .current_lba = readLe64(sector[24..32]),
        .backup_lba = readLe64(sector[32..40]),
        .first_usable_lba = readLe64(sector[40..48]),
        .last_usable_lba = readLe64(sector[48..56]),
        .entries_lba = readLe64(sector[72..80]),
        .entry_count = readLe32(sector[80..84]),
        .entry_size = entry_size,
    };
}

fn preadExact(fd: linux.fd_t, buf: []u8, offset: i64) bool {
    var done: usize = 0;
    while (done < buf.len) {
        const rc = linux.pread(fd, buf.ptr + done, buf.len - done, offset + @as(i64, @intCast(done)));
        const err = linux.errno(rc);
        if (err != .SUCCESS) {
            log("{{\"event\":\"pread_failed\",\"offset\":{d},\"done\":{d},\"errno\":\"{s}\"}}\n", .{ offset, done, @tagName(err) });
            return false;
        }
        if (rc == 0) {
            log("{{\"event\":\"pread_eof\",\"offset\":{d},\"done\":{d}}}\n", .{ offset, done });
            return false;
        }
        done += rc;
    }
    return true;
}

fn checksum32(bytes: []const u8) u32 {
    var hash: u32 = 2166136261;
    for (bytes) |b| {
        hash ^= b;
        hash *%= 16777619;
    }
    return hash;
}

fn probeSda() bool {
    const raw_fd = linux.open("/dev/sda", .{ .ACCMODE = .RDONLY, .CLOEXEC = true }, 0);
    const open_err = linux.errno(raw_fd);
    if (open_err != .SUCCESS) {
        log("{{\"event\":\"sda_open_failed\",\"errno\":\"{s}\"}}\n", .{@tagName(open_err)});
        return false;
    }
    const fd: linux.fd_t = @intCast(raw_fd);
    defer _ = linux.close(fd);

    var bytes: u64 = 0;
    const size_rc = linux.ioctl(fd, blkgetsize64, @intFromPtr(&bytes));
    const size_err = linux.errno(size_rc);
    if (size_err == .SUCCESS)
        log("{{\"event\":\"sda_open\",\"bytes\":{d},\"sectors\":{d}}}\n", .{ bytes, bytes / sector_size })
    else
        log("{{\"event\":\"sda_open\",\"bytes\":null,\"size_errno\":\"{s}\"}}\n", .{@tagName(size_err)});

    var mbr: [sector_size]u8 = undefined;
    if (!preadExact(fd, &mbr, 0))
        return false;
    const mbr_sig = mbr[510] == 0x55 and mbr[511] == 0xaa;
    log("{{\"event\":\"lba0\",\"mbr_signature\":{},\"fnv1a32\":\"{x:0>8}\"}}\n", .{ mbr_sig, checksum32(&mbr) });

    var gpt_sector: [sector_size]u8 = undefined;
    if (!preadExact(fd, &gpt_sector, sector_size))
        return false;
    const gpt = parseGptHeader(&gpt_sector) orelse {
        log("{s}\n", .{"{\"event\":\"gpt_header\",\"valid\":false}"});
        return false;
    };
    log("{{\"event\":\"gpt_header\",\"valid\":true,\"revision\":{d},\"header_size\":{d},\"current_lba\":{d},\"backup_lba\":{d},\"first_usable_lba\":{d},\"last_usable_lba\":{d},\"entries_lba\":{d},\"entry_count\":{d},\"entry_size\":{d}}}\n", .{
        gpt.revision,
        gpt.header_size,
        gpt.current_lba,
        gpt.backup_lba,
        gpt.first_usable_lba,
        gpt.last_usable_lba,
        gpt.entries_lba,
        gpt.entry_count,
        gpt.entry_size,
    });

    var entry_sector: [sector_size]u8 = undefined;
    const entries_offset: i64 = @intCast(gpt.entries_lba * sector_size);
    if (!preadExact(fd, &entry_sector, entries_offset))
        return false;
    log("{{\"event\":\"gpt_entries_read\",\"lba\":{d},\"fnv1a32\":\"{x:0>8}\"}}\n", .{ gpt.entries_lba, checksum32(&entry_sector) });

    const sample_lbas = [_]u64{ 2, 34, 2048 };
    var sample: [sector_size]u8 = undefined;
    for (sample_lbas) |lba| {
        const offset: i64 = @intCast(lba * sector_size);
        if (!preadExact(fd, &sample, offset))
            return false;
        log("{{\"event\":\"sample_read\",\"lba\":{d},\"fnv1a32\":\"{x:0>8}\"}}\n", .{ lba, checksum32(&sample) });
    }

    if (bytes >= sector_size and bytes % sector_size == 0) {
        const last_lba = bytes / sector_size - 1;
        const offset: i64 = @intCast(last_lba * sector_size);
        if (!preadExact(fd, &sample, offset))
            return false;
        const backup = parseGptHeader(&sample);
        log("{{\"event\":\"last_lba_read\",\"lba\":{d},\"backup_gpt\":{},\"fnv1a32\":\"{x:0>8}\"}}\n", .{ last_lba, backup != null, checksum32(&sample) });
    }

    return true;
}

pub fn main() noreturn {
    log("{s}\n", .{"{\"event\":\"note10_mainline_init\",\"version\":1,\"policy\":\"read_only_ufs\"}"});

    ensureDir("/dev");
    ensureDir("/proc");
    ensureDir("/sys");
    mountPseudo("devtmpfs", "/dev", "devtmpfs");
    mountPseudo("proc", "/proc", "proc");
    mountPseudo("sysfs", "/sys", "sysfs");

    var attempt: usize = 0;
    var success_count: usize = 0;
    while (attempt < 12) : (attempt += 1) {
        log("{{\"event\":\"probe_begin\",\"attempt\":{d}}}\n", .{attempt + 1});
        if (probeSda()) {
            success_count += 1;
            log("{{\"event\":\"probe_pass\",\"attempt\":{d},\"success_count\":{d}}}\n", .{ attempt + 1, success_count });
            if (success_count >= 3)
                break;
        } else {
            log("{{\"event\":\"probe_fail\",\"attempt\":{d}}}\n", .{attempt + 1});
        }
        sleepSeconds(5);
    }

    log("{{\"event\":\"probe_summary\",\"success_count\":{d},\"result\":\"{s}\"}}\n", .{ success_count, if (success_count >= 3) "pass" else "fail" });
    log("{s}\n", .{"{\"event\":\"idle\",\"message\":\"diagnostic init will remain alive; no storage writes are implemented\"}"});
    while (true)
        sleepSeconds(60);
}

test "parse valid GPT header" {
    var sector: [sector_size]u8 = @splat(0);
    @memcpy(sector[0..8], "EFI PART");
    sector[8] = 0x00;
    sector[9] = 0x00;
    sector[10] = 0x01;
    sector[11] = 0x00;
    sector[12] = 92;
    sector[24] = 1;
    sector[32] = 0xff;
    sector[40] = 34;
    sector[48] = 0xfe;
    sector[72] = 2;
    sector[80] = 128;
    sector[84] = 128;
    const gpt = parseGptHeader(&sector) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(@as(u64, 1), gpt.current_lba);
    try std.testing.expectEqual(@as(u64, 2), gpt.entries_lba);
    try std.testing.expectEqual(@as(u32, 128), gpt.entry_count);
    try std.testing.expectEqual(@as(u32, 128), gpt.entry_size);
}

test "reject non GPT sector" {
    const sector: [sector_size]u8 = @splat(0);
    try std.testing.expect(parseGptHeader(&sector) == null);
}
