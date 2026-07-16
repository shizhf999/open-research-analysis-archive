# Public Release Checklist

## Before pushing to GitHub

- [ ] Run `powershell -ExecutionPolicy Bypass -File scripts/build_public_release.ps1 -Clean`.
- [ ] Inspect `MANIFEST.sha256` and confirm each file is intended for public release.
- [ ] Search the final repository for credentials, tokens, emails, absolute local paths, `/root/`, `AutoDL`, `ssh`, `sftp`, `scp`, and `rsync`.
- [ ] Confirm that no raw downloads, individual-level records, RDS files, trajectories, poses, binaries, package libraries, or remote-execution helpers are tracked.
- [ ] Review all copied documentation for current scientific boundaries and remove any manuscript-specific language that is not wanted in the general archive.
- [ ] Obtain rights-holder approval for a license; add `LICENSE` and update `CITATION.cff` and `.zenodo.json`.
- [ ] Replace all `TO BE COMPLETED` fields with author-approved metadata.
- [ ] Initialize Git, commit, and tag a semantic release such as `v0.1.0`.

## Zenodo DOI workflow

1. Create the GitHub repository from this directory and push the approved release commit.
2. Sign in to Zenodo with the account that should manage the record.
3. In Zenodo GitHub settings, enable the repository.
4. Create the tagged GitHub release. Zenodo will archive it and mint a version DOI and a concept DOI.
5. Use the **version DOI** to cite the exact archived release; use the **concept DOI** when directing users to the latest version.
6. Add the final DOI URLs to `CITATION.cff`, the repository README, and any report that cites the archive.

A DOI cannot be generated locally and must not be fabricated. The GitHub-Zenodo connection requires an authorized account action.
