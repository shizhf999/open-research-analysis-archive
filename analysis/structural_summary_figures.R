# Generated public-release variant. Source path and manuscript-specific output paths were replaced by build_public_release.ps1.
###############################################################################
# Aggregate result figures 1-3: target audit, structural sensitivity, and CRY2 overlap
#
# Uses only completed, provenance-labelled project outputs. It intentionally
# excludes legacy Atlas figures and any direct CSNK1D interpretation of 6GZD.
###############################################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(patchwork)
  library(tidyr)
})

proj_dir <- normalizePath(Sys.getenv("OPEN_RESEARCH_ROOT", unset = getwd()), mustWork = TRUE)
output_dir <- file.path(proj_dir, "results", "aggregate")
submission_dir <- file.path(proj_dir, "results", "regenerated")
dir.create(submission_dir, recursive = TRUE, showWarnings = FALSE)

required_files <- c(
  file.path(output_dir, "protein_audit", "protein_pdb_strict_accession_audit.csv"),
  file.path(output_dir, "docking", "redock_csnk1d_verified_5OKT", "vina_results_csnk1d_5OKT.csv"),
  file.path(output_dir, "docking", "redock_cry2_4MLP", "vina_results_cry2_4MLP.csv"),
  file.path(output_dir, "docking", "negative_controls", "molecular_negative_control_interpretation.csv"),
  file.path(output_dir, "md", "csnk1d_p48730_5okt", "summary", "csnk1d_5okt_mmpbsa_summary.csv"),
  file.path(output_dir, "md", "cry2_fulltraj_9gb", "summary", "cry2_fulltraj_mmpbsa_summary.csv"),
  file.path(output_dir, "md", "fig6_functional_interface", "cry2_decomp_interface_overlap_summary.csv")
)
stopifnot(all(file.exists(required_files)))

audit <- read_csv(required_files[[1]], show_col_types = FALSE) %>%
  mutate(status = if_else(grepl("^PASS", verdict), "Passed identity audit", "Excluded or boundary-labelled"))
csnk1d_dock <- read_csv(required_files[[2]], show_col_types = FALSE) %>%
  filter(status == "OK", ligand %in% c("BPA", "PFOA", "PFOS", "Cypermethrin")) %>%
  transmute(system = paste0(ligand, "-CSNK1D/5OKT"), ligand, target = "Human CSNK1D/P48730", score = best_affinity_kcalmol)
cry2_dock <- read_csv(required_files[[3]], show_col_types = FALSE) %>%
  filter(status == "OK", ligand == "Cypermethrin") %>%
  transmute(system = "Cypermethrin-CRY2/4MLP", ligand, target = "Mouse CRY2 template", score = best_affinity_kcalmol)
controls <- read_csv(required_files[[4]], show_col_types = FALSE) %>%
  filter(control_class == "scrambled_pocket") %>%
  transmute(
    system = case_when(
      ligand == "BPA" ~ "BPA-CSNK1D/5OKT",
      ligand == "PFOA" ~ "PFOA-CSNK1D/5OKT",
      ligand == "Cypermethrin" ~ "Cypermethrin-CRY2/4MLP",
      TRUE ~ ligand
    ),
    delta = delta_control_minus_true_kcalmol
  )

audit_plot <- audit %>%
  count(status, verdict, name = "n") %>%
  mutate(label = paste0(verdict, "\n(n=", n, ")")) %>%
  ggplot(aes(x = status, y = n, fill = status)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(aes(label = n), vjust = -0.35, size = 3.4) +
  scale_fill_manual(values = c("Passed identity audit" = "#2A9D8F", "Excluded or boundary-labelled" = "#D1495B")) +
  labs(title = "A. Structure identity audit", x = NULL, y = "PDB inputs") +
  theme_classic(base_size = 9) +
  theme(axis.text.x = element_text(size = 7.5), plot.title = element_text(face = "bold"))

dock_data <- bind_rows(csnk1d_dock, cry2_dock) %>%
  mutate(system = factor(system, levels = rev(system)))
dock_plot <- ggplot(dock_data, aes(x = score, y = system, fill = target)) +
  geom_col(width = 0.66) +
  geom_text(aes(label = sprintf("%.2f", score)), hjust = 1.12, color = "white", size = 3) +
  scale_fill_manual(values = c("Human CSNK1D/P48730" = "#3D5A80", "Mouse CRY2 template" = "#E76F51")) +
  labs(title = "B. Corrected focal docking", x = "Vina score (kcal/mol; prioritization only)", y = NULL, fill = NULL) +
  theme_classic(base_size = 9) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

control_plot <- controls %>%
  mutate(system = factor(system, levels = rev(system))) %>%
  ggplot(aes(x = delta, y = system)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey55") +
  geom_segment(aes(x = 0, xend = delta, yend = system), color = "#7A8B99", linewidth = 0.8) +
  geom_point(size = 3, color = "#087E8B") +
  geom_text(aes(label = sprintf("+%.2f", delta)), nudge_y = 0.22, size = 2.8) +
  labs(title = "C. Scrambled-pocket control", x = "Control minus true-pocket score (kcal/mol)", y = NULL) +
  theme_classic(base_size = 9) +
  theme(plot.title = element_text(face = "bold"), axis.text.y = element_text(size = 7.5))

figure1 <- audit_plot + dock_plot + control_plot +
  plot_layout(widths = c(0.78, 1.28, 1.05))

csnk1d_energy <- read_csv(required_files[[5]], show_col_types = FALSE) %>%
  filter(analysis_layer %in% c("all100_gb", "all100_pb"), system %in% c("BPA", "PFOA")) %>%
  mutate(method = factor(method, levels = c("GB", "PB")), complex = paste0(system, "-CSNK1D/5OKT"))
cry2_energy <- read_csv(required_files[[6]], show_col_types = FALSE) %>%
  filter(window_start_ns == 80, window_end_ns == 100, method %in% c("GB", "PB")) %>%
  transmute(
    complex = "Cypermethrin-CRY2/4MLP template",
    replicate, method = factor(method, levels = c("GB", "PB")),
    delta_total_kcal_mol
  )

energy_plot <- bind_rows(
  csnk1d_energy %>% select(complex, replicate, method, delta_total_kcal_mol),
  cry2_energy
) %>%
  ggplot(aes(x = replicate, y = delta_total_kcal_mol, fill = method)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey55") +
  geom_col(position = position_dodge(width = 0.72), width = 0.64) +
  facet_wrap(~complex, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = c("GB" = "#457B9D", "PB" = "#E9C46A")) +
  labs(title = "A. MM/PBSA solvation-model sensitivity", x = "100-ns replicate", y = "Delta total (kcal/mol)", fill = NULL) +
  theme_classic(base_size = 9) +
  theme(legend.position = "bottom", strip.text = element_text(face = "bold"), plot.title = element_text(face = "bold"))

boundary_plot <- tibble::tribble(
  ~system, ~provenance, ~interpretation,
  "BPA/PFOA-CSNK1D", "Human P48730 / 5OKT", "Direct-target structural hypothesis",
  "Cypermethrin-CRY2", "Mouse 4MLP template", "Homology-template structural hypothesis"
) %>%
  ggplot(aes(x = provenance, y = system, fill = interpretation)) +
  geom_tile(color = "white", linewidth = 1.1) +
  geom_text(aes(label = interpretation), size = 3.2) +
  scale_fill_manual(values = c("Direct-target structural hypothesis" = "#A8DADC", "Homology-template structural hypothesis" = "#F4A261")) +
  labs(title = "B. Provenance boundary", x = NULL, y = NULL, fill = NULL) +
  theme_void(base_size = 9) +
  theme(legend.position = "none", plot.title = element_text(face = "bold"), axis.text.y = element_text(size = 8, color = "black"))

figure2 <- energy_plot / boundary_plot +
  plot_layout(heights = c(3.4, 0.85))

overlap <- read_csv(required_files[[7]], show_col_types = FALSE) %>%
  filter(reference_test %in% c("2CX pocket exact", "2CX pocket +/-2", "PER2 interface exact", "PER2 interface +/-2")) %>%
  mutate(reference_test = factor(reference_test, levels = c("2CX pocket exact", "2CX pocket +/-2", "PER2 interface exact", "PER2 interface +/-2")))

overlap_plot <- ggplot(overlap, aes(x = reference_test, y = share_supported, fill = reference_test)) +
  geom_col(width = 0.65, show.legend = FALSE) +
  geom_text(aes(label = paste0(n_supported, "/", n_decomp_residues, " (", sprintf("%.1f", 100 * share_supported), "%)")), vjust = -0.4, size = 3.1) +
  scale_fill_manual(values = c("2CX pocket exact" = "#2A9D8F", "2CX pocket +/-2" = "#80C9B9", "PER2 interface exact" = "#E76F51", "PER2 interface +/-2" = "#F4A261")) +
  scale_y_continuous(limits = c(0, 0.78), labels = scales::percent_format(accuracy = 1)) +
  labs(title = "A. CRY2 residue overlap", x = NULL, y = "Share of 54 receptor residues") +
  theme_classic(base_size = 9) +
  theme(axis.text.x = element_text(angle = 18, hjust = 1), plot.title = element_text(face = "bold"))

residue_summary <- tibble::tribble(
  ~evidence_layer, ~finding, ~interpretation,
  "2CX pocket", "19/54 exact; 35/54 within +/-2", "Pocket-centred structural hypothesis",
  "PER2 interface", "1/54 exact; 7/54 within +/-2", "No support for PER2 disruption"
)
residue_text <- ggplot(residue_summary, aes(x = evidence_layer, y = 1, fill = evidence_layer)) +
  geom_tile(color = "white") +
  geom_text(aes(label = paste0(finding, "\n", interpretation)), size = 3.3) +
  scale_fill_manual(values = c("2CX pocket" = "#CDEDE6", "PER2 interface" = "#FCE0D6")) +
  labs(title = "B. Interpretation boundary") +
  theme_void(base_size = 9) +
  theme(legend.position = "none", plot.title = element_text(face = "bold"))

figure3 <- overlap_plot / residue_text +
  plot_layout(heights = c(3.2, 1))

save_figure <- function(figure, name, width, height) {
  path <- file.path(submission_dir, name)
  ggsave(paste0(path, ".pdf"), figure, width = width, height = height, bg = "white")
  ggsave(paste0(path, ".png"), figure, width = width, height = height, dpi = 400, bg = "white")
}

save_figure(figure1, "Figure_1_Target_audit_and_docking", 13.2, 5.3)
save_figure(figure2, "Figure_2_Structural_persistence_and_sensitivity", 12.6, 7.2)
save_figure(figure3, "Figure_3_CRY2_residue_overlap", 10.2, 7.0)

write_csv(audit, file.path(submission_dir, "Figure_1_target_audit_plot_data.csv"))
write_csv(dock_data, file.path(submission_dir, "Figure_1_docking_plot_data.csv"))
write_csv(controls, file.path(submission_dir, "Figure_1_control_plot_data.csv"))
write_csv(csnk1d_energy, file.path(submission_dir, "Figure_2_csnk1d_energy_plot_data.csv"))
write_csv(cry2_energy, file.path(submission_dir, "Figure_2_cry2_energy_plot_data.csv"))
write_csv(overlap, file.path(submission_dir, "Figure_3_overlap_plot_data.csv"))
message("Structural summary figures created in: ", submission_dir)