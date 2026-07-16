# Generated public-release variant. Source path and manuscript-specific output paths were replaced by build_public_release.ps1.
###############################################################################
# Aggregate result figure 4: BPA and hourly-derived actigraphy rhythm metrics
#
# Creates a restrained main-text figure from completed NHANES result files.
# Panel A preserves the RA/IV primary-null context next to secondary IS.
# Panel B shows G-cycle creatinine-handling sensitivity for the IS estimate.
###############################################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(patchwork)
})

proj_dir <- normalizePath(Sys.getenv("OPEN_RESEARCH_ROOT", unset = getwd()), mustWork = TRUE)
out_dir <- file.path(proj_dir, "results", "aggregate", "nhanes_exposome")
submission_dir <- file.path(proj_dir, "results", "regenerated")
dir.create(submission_dir, recursive = TRUE, showWarnings = FALSE)

meta_path <- file.path(out_dir, "glm_meta_g_h_strict_detection_results.csv")
sensitivity_path <- file.path(out_dir, "bpa_creatinine_three_spec_sensitivity.csv")
stopifnot(file.exists(meta_path), file.exists(sensitivity_path))

fmt_p <- function(value) {
  ifelse(value < 0.001, "<0.001", sprintf("%.3f", value))
}

meta <- read_csv(meta_path, show_col_types = FALSE)
sensitivity <- read_csv(sensitivity_path, show_col_types = FALSE)

endpoint_data <- meta %>%
  filter(exposure == "BPA_cr", outcome %in% c("RA", "IV", "IS")) %>%
  transmute(
    outcome,
    endpoint_type = if_else(is_primary, "Primary endpoint", "Secondary endpoint"),
    estimate_G = beta_G,
    lower_G = beta_G - 1.96 * se_G,
    upper_G = beta_G + 1.96 * se_G,
    p_G,
    estimate_H = beta_H,
    lower_H = beta_H - 1.96 * se_H,
    upper_H = beta_H + 1.96 * se_H,
    p_H,
    estimate_meta = beta_RE,
    lower_meta = ci_lo_RE,
    upper_meta = ci_hi_RE,
    p_meta = p_RE,
    fdr_meta = fdr_tier_RE
  ) %>%
  mutate(outcome = factor(outcome, levels = c("RA", "IV", "IS")))

forest_data <- bind_rows(
  endpoint_data %>% transmute(outcome, endpoint_type, model = "NHANES 2011-2012", estimate = estimate_G,
                             lower = lower_G, upper = upper_G, p_value = p_G, fdr = NA_real_),
  endpoint_data %>% transmute(outcome, endpoint_type, model = "NHANES 2013-2014", estimate = estimate_H,
                             lower = lower_H, upper = upper_H, p_value = p_H, fdr = NA_real_),
  endpoint_data %>% transmute(outcome, endpoint_type, model = "Random-effects meta-analysis", estimate = estimate_meta,
                             lower = lower_meta, upper = upper_meta, p_value = p_meta, fdr = fdr_meta)
) %>%
  mutate(
    row_label = paste(outcome, model, sep = " - "),
    row_label = factor(row_label, levels = rev(c(
      "RA - NHANES 2011-2012", "RA - NHANES 2013-2014", "RA - Random-effects meta-analysis",
      "IV - NHANES 2011-2012", "IV - NHANES 2013-2014", "IV - Random-effects meta-analysis",
      "IS - NHANES 2011-2012", "IS - NHANES 2013-2014", "IS - Random-effects meta-analysis"
    ))),
    endpoint_type = factor(endpoint_type, levels = c("Primary endpoint", "Secondary endpoint")),
    point_shape = if_else(model == "Random-effects meta-analysis", "Meta-analysis", "Cycle")
  )

panel_a <- ggplot(forest_data, aes(x = estimate, y = row_label, color = endpoint_type)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey55") +
  geom_errorbar(aes(xmin = lower, xmax = upper), orientation = "y", width = 0.18, linewidth = 0.65) +
  geom_point(aes(shape = point_shape), size = 2.7, stroke = 0.9) +
  scale_color_manual(values = c("Primary endpoint" = "#586174", "Secondary endpoint" = "#087E8B")) +
  scale_shape_manual(values = c("Cycle" = 16, "Meta-analysis" = 18)) +
  labs(
    title = "A. BPA associations with activity-rhythm metrics",
    subtitle = "RA and IV are primary endpoints; IS is secondary",
    x = "Survey-weighted beta (95% CI)", y = NULL, color = NULL, shape = NULL
  ) +
  theme_classic(base_size = 10) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 8.5)
  )

sensitivity_data <- sensitivity %>%
  filter(outcome == "IS") %>%
  mutate(
    specification = recode(
      spec,
      "ratio_method" = "BPA/creatinine ratio",
      "covariate_method" = "Raw BPA + creatinine covariate",
      "sanchez_residual" = "Creatinine-residual BPA"
    ),
    specification = factor(specification, levels = rev(c(
      "BPA/creatinine ratio", "Raw BPA + creatinine covariate", "Creatinine-residual BPA"
    ))),
    p_label = paste0("p = ", fmt_p(p_value))
  )

panel_b <- ggplot(sensitivity_data, aes(x = beta, y = specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey55") +
  geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), orientation = "y", width = 0.18,
                linewidth = 0.65, color = "#087E8B") +
  geom_point(size = 2.8, color = "#087E8B") +
  geom_text(aes(label = p_label), nudge_y = 0.23, size = 3, hjust = 0) +
  labs(
    title = "B. G-cycle IS sensitivity to creatinine handling",
    subtitle = "Similar direction and magnitude across specifications",
    x = "Survey-weighted beta (95% CI)", y = NULL
  ) +
  coord_cartesian(xlim = c(-0.028, 0.002), clip = "off") +
  theme_classic(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 8.5),
    plot.margin = margin(5.5, 30, 5.5, 5.5)
  )

figure4 <- panel_a + panel_b +
  plot_layout(widths = c(1.35, 1)) +
  plot_annotation(
    title = "Figure 4. Urinary BPA and hourly-derived actigraphy rhythm metrics in NHANES",
    subtitle = paste0(
      "BPA-to-IS random-effects beta = -0.0108 (95% CI -0.0171 to -0.0045; p = ",
      "0.000758; secondary-tier FDR = 0.0182)."
    ),
    theme = theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 9.5)
    )
  )

output_base <- file.path(submission_dir, "Figure_4_BPA_hourly_actigraphy")
ggsave(paste0(output_base, ".pdf"), figure4, width = 13, height = 6.6, bg = "white")
ggsave(paste0(output_base, ".png"), figure4, width = 13, height = 6.6, dpi = 400, bg = "white")

write_csv(forest_data, paste0(output_base, "_plot_data.csv"))
message("Activity-rhythm figure created: ", output_base)
