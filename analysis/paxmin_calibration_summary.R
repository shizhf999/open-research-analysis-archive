suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
})

archive_root <- normalizePath(Sys.getenv("OPEN_RESEARCH_ROOT", unset = getwd()), mustWork = TRUE)
input_dir <- file.path(archive_root, "results", "aggregate", "nhanes_exposome")
output_dir <- file.path(archive_root, "results", "regenerated")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

required_files <- c(
  "paxmin_hourly_minute_IS_concordance.csv",
  "paxmin_hourly_minute_IS_bpa_models.csv",
  "bpa_is_iqr_effect_scale_summary.csv"
)
missing_files <- required_files[!file.exists(file.path(input_dir, required_files))]
if (length(missing_files) > 0) {
  stop("Missing required aggregate input(s): ", paste(missing_files, collapse = ", "))
}

agreement <- read_csv(file.path(input_dir, "paxmin_hourly_minute_IS_concordance.csv"), show_col_types = FALSE) %>%
  filter(cycle %in% c("G", "H"))
models <- read_csv(file.path(input_dir, "paxmin_hourly_minute_IS_bpa_models.csv"), show_col_types = FALSE) %>%
  filter(cycle == "Two-cycle inverse-variance")
effect_scale <- read_csv(file.path(input_dir, "bpa_is_iqr_effect_scale_summary.csv"), show_col_types = FALSE)

agreement_plot <- agreement %>%
  select(cycle, pearson_r, spearman_rho) %>%
  pivot_longer(-cycle, names_to = "metric", values_to = "value") %>%
  ggplot(aes(cycle, value, fill = metric)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.62) +
  geom_text(aes(label = sprintf("%.3f", value)), position = position_dodge(width = 0.7), vjust = -0.35, size = 3) +
  scale_fill_manual(values = c(pearson_r = "#246a73", spearman_rho = "#bc6c25"), labels = c(pearson_r = "Pearson r", spearman_rho = "Spearman rho")) +
  coord_cartesian(ylim = c(0, 1)) +
  labs(title = "Hourly and minute IS rank concordance", x = NULL, y = "Correlation", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

model_plot <- models %>%
  mutate(
    resolution = recode(outcome, hourly_IS = "Hourly IS", minute_IS = "Minute IS"),
    resolution = factor(resolution, levels = c("Hourly IS", "Minute IS"))
  ) %>%
  ggplot(aes(resolution, beta, ymin = ci_lower, ymax = ci_upper, color = resolution)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey45") +
  geom_pointrange(size = 0.5) +
  scale_color_manual(values = c("Hourly IS" = "#246a73", "Minute IS" = "#bc6c25")) +
  labs(title = "Two-cycle BPA-IS estimates", x = NULL, y = "Adjusted beta per BPA doubling") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "none")

scale_plot <- effect_scale %>%
  ggplot(aes(cycle, absolute_difference_percent_of_is_sd, fill = cycle)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.1f%%", absolute_difference_percent_of_is_sd)), vjust = -0.35, size = 3) +
  scale_fill_manual(values = c(G = "#246a73", H = "#bc6c25")) +
  expand_limits(y = 12) +
  labs(title = "IQR-scale descriptive contrast", x = NULL, y = "Absolute difference (% of IS SD)") +
  theme_minimal(base_size = 11)

summary_figure <- (agreement_plot | model_plot) / scale_plot + plot_annotation(
  title = "Aggregate PAXMIN calibration and BPA-IS summaries",
  subtitle = "Aggregate descriptive and model outputs; not individual-level data"
)

ggsave(file.path(output_dir, "paxmin_calibration_summary.pdf"), summary_figure, width = 10, height = 7)
ggsave(file.path(output_dir, "paxmin_calibration_summary.png"), summary_figure, width = 10, height = 7, dpi = 300)

write_csv(
  bind_rows(
    agreement %>% transmute(section = "concordance", cycle, metric = "pearson_r", value = pearson_r),
    agreement %>% transmute(section = "concordance", cycle, metric = "spearman_rho", value = spearman_rho),
    models %>% transmute(section = "two_cycle_model", cycle, metric = outcome, value = beta),
    effect_scale %>% transmute(section = "effect_scale", cycle, metric = "absolute_difference_percent_of_is_sd", value = absolute_difference_percent_of_is_sd)
  ),
  file.path(output_dir, "paxmin_calibration_summary.csv")
)

message("Created aggregate PAXMIN calibration summaries in: ", output_dir)