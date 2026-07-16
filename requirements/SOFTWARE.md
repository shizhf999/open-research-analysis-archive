# Software requirements

## Included regeneration scripts

The included visualization and table scripts were run with R 4.5.2 and require the R packages listed in `R-packages.txt`. The result-reconstruction subset does not require proprietary software.

## Upstream analysis boundaries

The full upstream workflow may additionally require:

- R with `survey`, mixture-model packages, and MR packages;
- Python 3 for source-specific structural processing scripts;
- AutoDock Vina/Open Babel for docking reproduction;
- GROMACS and a compatible MM/PBSA workflow for molecular-dynamics reproduction;
- PLINK2 and an appropriate LD reference panel for genetic sensitivity analyses.

These tools and their binaries are not redistributed. Obtain them from their official sources and record exact versions in an environment lockfile only after reproducing the relevant workflow.
