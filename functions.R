# functions.R
# Holds helper functions for the targets pipeline
library(ggplot2)
library(tidyverse)

calc_min_weight <- function(height_in) {
  # Calculate minimum healthy weight based on height in inches
  min_bmi <- 18.5
  min_weight <- (min_bmi * (height_in ^ 2)) / 703
  return(min_weight)
}

calc_max_weight <- function(height_in) {
  # Calculate maximum healthy weight based on height in inches
  max_bmi <- 24.9
  max_weight <- (max_bmi * (height_in ^ 2)) / 703
  return(max_weight)
}

plot_weight <- function(
  title, weight_data, min_weight, max_weight, goals, weeks = 12) {
  
  # make sure date column is Date type
  weight_data$date <- as.Date(weight_data$date)

  # Validate goals input and print errors as appropriate
  if (missing(goals) || is.null(goals)) {
    stop("`goals` is required: supply (start_date, start_weight, weekly_change).")
  }
  if (!(is.list(goals) || is.vector(goals)) || length(goals) < 3) {
    stop("`goals` must be a list/vector: (start_date, start_weight, weekly_change).")
  }

  # Extract goal parameters
  start_date <- as.Date(goals[[1]])
  start_weight <- as.numeric(goals[[2]])
  weekly_change <- as.numeric(goals[[3]])

  # Create end date and end goal weight for trend line
  end_date <- start_date + weeks * 7
  end_weight <- start_weight + weekly_change * weeks

  # Create trend line data frame
  trend_data <- tibble(
    date = as.Date(c(start_date, end_date)),
    weight = c(start_weight, end_weight)
  )


  # Define average weight for buffer zones
  average <- (min_weight + max_weight) / 2
  up_buffer <- average + (max_weight - average) / 2
  low_buffer <- average - (average - min_weight) / 2

  # shaded bands using geom_rect (no warnings from inherit.aes)
  p <- ggplot(weight_data, aes(x = date, y = weight)) +
    # Add shaded bands for weight zones
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = -Inf, ymax = min_weight,
             fill = "red", alpha = 0.12) +
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = min_weight, ymax = low_buffer,
             fill = "orange", alpha = 0.12) +
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = low_buffer, ymax = average,
             fill = "green", alpha = 0.08) +
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = average, ymax = up_buffer,
             fill = "green", alpha = 0.08) +
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = up_buffer, ymax = max_weight,
             fill = "orange", alpha = 0.12) +
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = max_weight, ymax = Inf,
             fill = "red", alpha = 0.12) +
    # actual weight line
    geom_line(color = "blue") +
    # goal trend line
    geom_line(data = trend_data, aes(x = date, y = weight),
              color = "orange", linetype = "dashed") +
    # axis labels, title, theme
    labs(title = title, x = "Date", y = "Weight (lbs)") +
    theme_minimal()

  p
}
