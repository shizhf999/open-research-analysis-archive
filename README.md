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

## What this archive is and is not

This is a reproducibility and audit archive. It contains no individual-level analytic records, raw NHANES downloads, GWAS summary-statistic archives, molecular-dynamics trajectories, local software environments, binary executables, private remote-computing helpers, credentials, machine-specific configuration, or submission-system figures and formatted tables.

The archive provides exact aggregate result tables and figure/table-generation code for the reported analyses. Re-running upstream data acquisition, primary analytical cohort construction, docking, and molecular dynamics requires the public data providers and software described in `data_sources/` and `requirements/`.

## Quick start

```powershell
# From the repository root
Rscript analysis/activity_rhythm_figure.R
Rscript analysis/structural_summary_figures.R
```

The scripts write regenerated files to `results/regenerated/`. They resolve the repository root from the `OPEN_RESEARCH_ROOT` environment variable when set, otherwise from the current working directory.

## Release workflow

1. Run `scripts/build_public_release.ps1` from this directory.
2. Review `docs/PUBLIC_RELEASE_CHECKLIST.md` and the generated `MANIFEST.sha256`.
3. Create a GitHub repository from this directory; do not upload ignored files.
4. Complete the author, license, and release-version fields in `CITATION.cff` and `.zenodo.json`.
5. Connect the GitHub repository to Zenodo, create a GitHub release, and reserve/publish the Zenodo archive DOI.
6. Record the DOI only after Zenodo has minted it. Do not invent or prefill a DOI.

## Citation

The archived `v0.1.2` release is available at https://doi.org/10.5281/zenodo.21389313. Cite this version DOI for exact reproducibility. See `CITATION.cff`.

## License

A license must be selected and approved by all rights holders before public release. The repository is intentionally unlicensed until that decision is recorded; see `docs/LICENSE_DECISION.md`.
