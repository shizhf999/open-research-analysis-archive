# Public Scope and Exclusions

## Included

- R scripts converted to repository-relative paths for regeneration of selected aggregate-result figures.
- Aggregate exposure, model, mixture, structural-audit, docking, molecular-dynamics summary, PAXHR-PAXMIN calibration, and provenance tables.
- Public-source retrieval instructions and a SHA-256 manifest.

## Excluded

- Individual-level or analysis-ready participant records, including CSV/RDS data objects.
- Raw PAXMIN XPT files, minute-level time series, and participant-level hourly-minute matched-pair outputs.
- Submission-system figures, graphical abstracts, formatted manuscript tables, and supplementary-table workbooks.
- Raw NHANES downloads, GWAS summary-statistic archives, LD reference panels, and local protein/ligand caches.
- Molecular-dynamics trajectory and restart files, docking pose files, and large computational intermediates.
- Remote-computing packages, SSH/SFTP/rsync helpers, server paths, API credentials, access tokens, and local machine configuration.

## Provenance-path handling

Aggregate CSV fields that would otherwise expose the local project root are rewritten to `<project-root>` during the public build. This preserves their relative provenance meaning without publishing machine-specific paths.
- Executables, package libraries, virtual environments, and proprietary or redistribution-restricted material.

## Interpretation boundary

Included computational outputs are structural prioritization and model-sensitivity materials. They do not establish experimental affinity, target engagement, molecular mediation, or human causality. Aggregate epidemiologic outputs are cross-sectional associations and do not establish temporal or causal effects.
