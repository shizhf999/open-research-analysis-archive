# Open Research Analysis Archive

A generic, platform-neutral archive for sharing analysis code, nonrestricted derived results, provenance records, and instructions for retrieving public source data.

This archive is intentionally not named for a journal, manuscript, or submission. It can support multiple future reports that use the included analysis components.

## Contents

- `analysis/`: portable R scripts for regenerating selected tables and figures from the included nonrestricted result summaries.
- `results/`: nonrestricted, aggregate analysis outputs used by the portable scripts.
- `data_sources/`: public-data retrieval instructions, source URLs, and access boundaries.
- `docs/`: reuse, provenance, validation, and release guidance.
- `requirements/`: software and package requirements.
- `scripts/build_public_release.ps1`: rebuilds the public subset from the local research workspace.
- `.zenodo.json`: Zenodo metadata template shared with the GitHub release.

The `v0.1.3` release preparation adds aggregate PAXHR-PAXMIN calibration summaries, matched-resolution BPA-IS model estimates, and an IQR-scale descriptive effect-size summary. It does not add raw PAXMIN files, individual-level matched pairs, or code that scans raw XPT records.

## What this archive is and is not

This is a reproducibility and audit archive. It contains no individual-level analytic records, raw NHANES downloads, GWAS summary-statistic archives, molecular-dynamics trajectories, local software environments, binary executables, private remote-computing helpers, credentials, machine-specific configuration, or submission-system figures and formatted tables.

The archive provides exact aggregate result tables and figure/table-generation code for the reported analyses. Re-running upstream data acquisition, primary analytical cohort construction, docking, and molecular dynamics requires the public data providers and software described in `data_sources/` and `requirements/`.

## Quick start

```powershell
# From the repository root
Rscript analysis/activity_rhythm_figure.R
Rscript analysis/structural_summary_figures.R
Rscript analysis/paxmin_calibration_summary.R
```

The scripts write regenerated files to `results/regenerated/`. They resolve the repository root from the `OPEN_RESEARCH_ROOT` environment variable when set, otherwise from the current working directory.

## Release workflow

1. Run `scripts/build_public_release.ps1` from this directory.
2. Review `docs/PUBLIC_RELEASE_CHECKLIST.md` and the generated `MANIFEST.sha256`.
3. Review the public subset before creating any subsequent release; do not upload ignored files.
4. Update `CITATION.cff` and `.zenodo.json` for any new release version.
5. Commit, tag, and publish the approved version on GitHub; then connect the release to Zenodo and record its minted version DOI.

## Citation

The archived `v0.1.3` release is available at https://doi.org/10.5281/zenodo.21429423. Cite this version DOI for the aggregate PAXMIN calibration materials and the other contents of this release. The earlier `v0.1.2` DOI (https://doi.org/10.5281/zenodo.21389313) predates the PAXMIN aggregate calibration materials.

## License

This release is distributed under the MIT License. See `LICENSE`.
