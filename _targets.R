# _targets.R
library(targets)
library(tidyverse)
library(ggplot2)

source("R/functions.R")

list(
  # Read in weight: csv with date and weight columns
  # Weight is in pounds, date is in YYYY-MM-DD format
  tar_target(tylers_file, "data/tylers_weight.csv", format = "file"),
  tar_target(tylers_weight, read_csv(tylers_file)),
  tar_target(larissas_file, "data/larissas_weight.csv", format = "file"),
  tar_target(larissas_weight, read_csv(larissas_file)),

  # Set height in inches (doesn't change over time)
  tar_target(tylers_height, 65),
  tar_target(larissas_height, 59),

  # Calc min and max healthy weight for Tyler based on his height
  # Functions use BMI formula: weight (lbs) / height (in)^2 * 703
  # BMI range of 18.5 to 24.9 is considered healthy
  tar_target(T_min_weight, calc_min_weight(tylers_height)),
  tar_target(T_max_weight, calc_max_weight(tylers_height)),
  tar_target(L_min_weight, calc_min_weight(larissas_height)),
  tar_target(L_max_weight, calc_max_weight(larissas_height)),


  # Set trend line goals for Tyler's weight loss.
  # start date, start weight, and weekly weight change in pounds
  tar_target(tylers_goal, list("2026-02-08", 185, -2)),
  tar_target(larissas_goal, list("2026-02-08", 93, 1)),

  # Plot weight data with healthy weight zones and trend line
  tar_target(tylers_weight_plot,
    plot_weight(
      "Tyler's Weight",
      tylers_weight, 
      T_min_weight, 
      T_max_weight, 
      tylers_goal)
  ),
  tar_target(larissas_weight_plot,
    plot_weight(
      "Larissa's Weight",
      larissas_weight, 
      L_min_weight, 
      L_max_weight, 
      larissas_goal)
  ),

  # Save plots to output folder
  tar_target(T_weight_plot_file,
    ggsave(
      "output/tylers_weight.png",
      plot = tylers_weight_plot,
      width = 4,
      height = 3,
      units = "in"
    )
  ),
  tar_target(L_weight_plot_file,
    ggsave(
      "output/larissas_weight.png",
      plot = larissas_weight_plot,
      width = 4,
      height = 3,
      units = "in"
    )
  )

)