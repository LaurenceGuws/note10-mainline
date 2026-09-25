# Upstream contribution discipline

The Linux tree used by this project contains
`Documentation/process/coding-assistants.rst`; its rules apply to work prepared
with AI assistance.

For patches prepared here:

- preserve provenance and verify borrowed behaviour against the N975F;
- use normal Linux coding style and subsystem review practices;
- run the relevant build/tests, `checkpatch.pl`, and maintainer discovery before
  calling a series submission-ready;
- state hardware-testing limitations explicitly;
- use the required AI attribution trailer for AI-assisted contributions:
  `Assisted-by: ChatGPT:GPT-5.6 Sol`;
- never add Captain's `Signed-off-by:` automatically.

The DCO `Signed-off-by:` certifies the human submitter's review and right to
submit. Captain adds it personally after reviewing the final patch/series.

The public Exynos9825 d2s reference is a single large squashed bring-up commit.
It is useful hardware evidence, not an acceptable final upstream patch shape.
We should extract small subsystem commits with clear dependency order rather
than forwarding the squash.
