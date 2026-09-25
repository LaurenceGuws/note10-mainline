# Kernel work

Do not vendor a full Linux tree here yet.

Reference clones and build trees live in the workstream. Once the active delta is understood, prefer one of:

1. an explicit upstream base commit plus a small ordered patch/commit series; or
2. a dedicated Linux fork whose history remains suitable for upstream-style review.

`config/` contains maintained config fragments only. `patches/` is temporary staging for provenance-preserving patches that have not yet become proper kernel commits.
