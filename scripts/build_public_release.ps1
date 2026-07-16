[CmdletBinding()]
param(
    [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$ReleaseRoot = Split-Path -Parent $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ReleaseRoot

if ($Clean) {
    @('analysis', 'results', 'data_sources', 'MANIFEST.sha256') | ForEach-Object {
        $target = Join-Path $ReleaseRoot $_
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
    }
}

function Copy-PublicFile {
    param(
        [Parameter(Mandatory)] [string]$RelativePath,
        [Parameter(Mandatory)] [string]$DestinationRelativePath
    )

    $source = Join-Path $ProjectRoot $RelativePath
    $destination = Join-Path $ReleaseRoot $DestinationRelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required public source file is missing: $source"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
}

function Copy-PortableFigureScript {
    param(
        [Parameter(Mandatory)] [string]$SourceRelativePath,
        [Parameter(Mandatory)] [string]$DestinationName,
        [Parameter(Mandatory)] [string]$OutputSourceDirectory,
        [Parameter(Mandatory)] [string]$OutputReleaseDirectory
    )

    $source = Join-Path $ProjectRoot $SourceRelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Required script is missing: $source"
    }
    $content = [System.IO.File]::ReadAllText($source, [System.Text.UTF8Encoding]::new($false))
    $content = [regex]::Replace(
        $content,
        'proj_dir <- file\.path\([\s\S]*?\)\s*\r?\n(?=(out_dir|output_dir) <-)',
        "proj_dir <- normalizePath(Sys.getenv(`"OPEN_RESEARCH_ROOT`", unset = getwd()), mustWork = TRUE)`n"
    )
    $content = $content.Replace('# EI Figure', '# Aggregate result figure')
    $content = $content.Replace('# EI main Figures', '# Aggregate result figures')
    $content = $content.Replace('EI Figure 4 created:', 'Activity-rhythm figure created:')
    $content = $content.Replace('EI Figures 1-3 created in:', 'Structural summary figures created in:')
    $content = $content.Replace($OutputSourceDirectory, $OutputReleaseDirectory)
    $content = $content.Replace('file.path(proj_dir, "EI_Submission_Package", "final_figures")', 'file.path(proj_dir, "results", "regenerated")')
    $content = "# Generated public-release variant. Source path and manuscript-specific output paths were replaced by build_public_release.ps1.`n" + $content
    $destination = Join-Path $ReleaseRoot (Join-Path 'analysis' $DestinationName)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    [System.IO.File]::WriteAllText($destination, $content, [System.Text.UTF8Encoding]::new($false))
}

$publicFiles = @(
    @{ Source = 'output/nhanes_exposome/actigraphy_descriptive_stats.csv'; Destination = 'results/aggregate/nhanes_exposome/actigraphy_descriptive_stats.csv' },
    @{ Source = 'output/nhanes_exposome/exposure_detection_rates.csv'; Destination = 'results/aggregate/nhanes_exposome/exposure_detection_rates.csv' },
    @{ Source = 'output/nhanes_exposome/glm_meta_g_h_strict_detection_results.csv'; Destination = 'results/aggregate/nhanes_exposome/glm_meta_g_h_strict_detection_results.csv' },
    @{ Source = 'output/nhanes_exposome/bpa_creatinine_three_spec_sensitivity.csv'; Destination = 'results/aggregate/nhanes_exposome/bpa_creatinine_three_spec_sensitivity.csv' },
    @{ Source = 'output/nhanes_exposome/wqs_core5_meta_g_h_results.csv'; Destination = 'results/aggregate/nhanes_exposome/wqs_core5_meta_g_h_results.csv' },
    @{ Source = 'output/nhanes_exposome/bkmr_pip_supplementary.csv'; Destination = 'results/aggregate/nhanes_exposome/bkmr_pip_supplementary.csv' },
    @{ Source = 'output/protein_audit/protein_pdb_strict_accession_audit.csv'; Destination = 'results/aggregate/protein_audit/protein_pdb_strict_accession_audit.csv' },
    @{ Source = 'output/docking/redock_csnk1d_verified_5OKT/vina_results_csnk1d_5OKT.csv'; Destination = 'results/aggregate/docking/redock_csnk1d_verified_5OKT/vina_results_csnk1d_5OKT.csv' },
    @{ Source = 'output/docking/redock_cry2_4MLP/vina_results_cry2_4MLP.csv'; Destination = 'results/aggregate/docking/redock_cry2_4MLP/vina_results_cry2_4MLP.csv' },
    @{ Source = 'output/docking/negative_controls/molecular_negative_control_interpretation.csv'; Destination = 'results/aggregate/docking/negative_controls/molecular_negative_control_interpretation.csv' },
    @{ Source = 'output/md/csnk1d_p48730_5okt/summary/csnk1d_5okt_metric_summary_by_rep.csv'; Destination = 'results/aggregate/md/csnk1d_p48730_5okt/summary/csnk1d_5okt_metric_summary_by_rep.csv' },
    @{ Source = 'output/md/csnk1d_p48730_5okt/summary/csnk1d_5okt_mmpbsa_summary.csv'; Destination = 'results/aggregate/md/csnk1d_p48730_5okt/summary/csnk1d_5okt_mmpbsa_summary.csv' },
    @{ Source = 'output/md/cry2_fulltraj_9gb/summary/cry2_fulltraj_metric_summary_by_rep.csv'; Destination = 'results/aggregate/md/cry2_fulltraj_9gb/summary/cry2_fulltraj_metric_summary_by_rep.csv' },
    @{ Source = 'output/md/cry2_fulltraj_9gb/summary/cry2_fulltraj_mmpbsa_summary.csv'; Destination = 'results/aggregate/md/cry2_fulltraj_9gb/summary/cry2_fulltraj_mmpbsa_summary.csv' },
    @{ Source = 'output/md/fig6_functional_interface/cry2_decomp_interface_overlap_summary.csv'; Destination = 'results/aggregate/md/fig6_functional_interface/cry2_decomp_interface_overlap_summary.csv' },
    @{ Source = 'output/reproducibility/completed_local_outputs_manifest.csv'; Destination = 'results/provenance/completed_local_outputs_manifest.csv' },
    @{ Source = 'output/reproducibility/run_summary.json'; Destination = 'results/provenance/run_summary.json' }
)

$publicFiles | ForEach-Object { Copy-PublicFile -RelativePath $_.Source -DestinationRelativePath $_.Destination }

Copy-PortableFigureScript `
    -SourceRelativePath 'code/10f_ei_figure4_bpa_actigraphy.R' `
    -DestinationName 'activity_rhythm_figure.R' `
    -OutputSourceDirectory 'file.path(proj_dir, "output", "nhanes_exposome")' `
    -OutputReleaseDirectory 'file.path(proj_dir, "results", "aggregate", "nhanes_exposome")'
Copy-PortableFigureScript `
    -SourceRelativePath 'code/10h_ei_structural_main_figures.R' `
    -DestinationName 'structural_summary_figures.R' `
    -OutputSourceDirectory 'file.path(proj_dir, "output")' `
    -OutputReleaseDirectory 'file.path(proj_dir, "results", "aggregate")'

$manifestPath = Join-Path $ReleaseRoot 'MANIFEST.sha256'
Get-ChildItem -LiteralPath $ReleaseRoot -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\MANIFEST\.sha256$' } |
    Sort-Object FullName |
    ForEach-Object {
        $relative = $_.FullName.Substring($ReleaseRoot.Length).TrimStart('\') -replace '\\', '/'
        "$( (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() )  $relative"
    } | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Output "Public release built: $ReleaseRoot"
Write-Output "Files in manifest: $((Get-Content -LiteralPath $manifestPath).Count)"
Write-Output 'Review docs/PUBLIC_RELEASE_CHECKLIST.md before publishing.'
