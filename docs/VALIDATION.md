# Validation

Run the build:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_public_release.ps1 -Clean
```

Then regenerate the included figures from aggregate outputs:

```powershell
Rscript analysis/activity_rhythm_figure.R
Rscript analysis/structural_summary_figures.R
```

Expected behavior:

- The build creates `MANIFEST.sha256` and does not copy excluded raw, individual-level, binary, trajectory, or remote-execution material.
- The figure scripts read only files under `results/aggregate/` and write to `results/regenerated/`.
- If a required aggregate input is missing, the script stops rather than substituting simulated or fallback data.

The checksum manifest attests to the archived files only; it does not validate upstream public data retrieval or third-party tool versions.
