## load the required libraries. ######################################

library(ggplot2) # makes the plots
library(tidyverse) # handles the data manipulation

## Define variables ##################################################

start_date <- as.Date("2026-02-08")
weeks <- 12 # represents the number of weeks we want to plot
min_bmi <- 18.5
max_bmi <- 24.9

## get a list of all the file paths ##################################

csv_files <- list.files("data", pattern = "*weight.csv", full.names = TRUE)

# debug tool: print the variables we currently have
print("General Data")
print(paste0("Start date: ", as.character(start_date)))
print(paste0("weeks:      ", weeks))
print(paste0("Min BMI:    ", min_bmi))
print(paste0("max BMI:    ", max_bmi))
print(paste0("CSV files:  ", csv_files))

## Process each file found in data ###################################
# This is where the main logic is handled.
# First we define the function process_and_plot(). This is where most
# of the logic is handled.
# Then, walk() iterates through file path listed in csv_files and then
# applies process_and_plot() to each file found in the data folder.

process_and_plot <- function(file_path) {  
  # extract name, height, and weekly goal from the file name
  file_name <- tools::file_path_sans_ext(basename(file_path))
  name_elements <- unlist(str_split(file_name, "_"))
  name <- name_elements[1]
  height <- as.integer(name_elements[2])
  goal <- as.numeric(name_elements[3])
  
  # read the individual's csv file into a tibble.
  data <- read_csv(file_path, show_col_types = FALSE)
  # show_col_types quiets the output.

  # Debug messages
  print(paste0("\n\n", "Individual Cases"))
  print(paste0("file name: ", file_name))
  print(paste0("Name:      ", name))
  print(paste0("height:    ", height))
  print(paste0("goal:      ", goal))
  print(data)

  # Calculate minimum healthy weight based on height in inches
  min_weight <- (min_bmi * (height ^ 2)) / 703

  # Calculate maximum healthy weight based on heigh in inches
  max_weight <- (max_bmi * (height ^ 2)) / 703

  # make sure date column is Date type
  data$date <- as.Date(data$date)

  # Create start and end points for goal line
  # start_date is already defined
  start_weight <- data %>% filter(date == start_date) %>% pull(weight)
  end_date <- start_date + weeks * 7
  end_weight <- start_weight + goal * weeks

  # Create trend line data frame so we can plot the goal line easier
  trend_data <- tibble(
    date = as.Date(c(start_date, end_date)),
    weight = c(start_weight, end_weight)
  )

  # Define average weight for buffer zones
  average <- (min_weight + max_weight) / 2
  up_buffer <- average + (max_weight - average) / 2
  low_buffer <- average - (average - min_weight) / 2

  # Start creating the plot
  p <- ggplot(data, aes(x = date, y = weight)) +
    # Add shaded bands for weight zones
    # red shading for under weight
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = -Inf, ymax = min_weight,
             fill = "red", alpha = 0.12) +
    # orange shading for lower 25% 
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = min_weight, ymax = low_buffer,
             fill = "orange", alpha = 0.12) +
    # Green shading for middle 50%
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = low_buffer, ymax = up_buffer,
             fill = "green", alpha = 0.08) +
    # Orange shading for upper 25%
        annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = up_buffer, ymax = max_weight,
             fill = "orange", alpha = 0.12) +
    # Red shading for overweight
    annotate("rect", xmin = -Inf, xmax = Inf,
             ymin = max_weight, ymax = Inf,
             fill = "red", alpha = 0.12) +
    # add a line for individual's weight data
    geom_line(color = "blue") +
    # add a line for goal data. It's a straight line since
    # we only defined two points for the start and end.
    geom_line(data = trend_data, aes(x = date, y = weight),
              color = "orange", linetype = "dashed") +
    # axis labels, title, theme
    labs(title = name, x = "Date", y = "Weight (lbs)") +
    theme_minimal()

  # Save the plot to the output folder
  # name the file "{start_date}_{name}" 
  ggsave(
    filename = paste0(start_date, "_", name,".png"),
    plot = p,
    path = "output",
    width = 6,
    height = 4,
    units = "in"
  )
} # end of the process_and_plot() function

# walk through each file_path listed in csv_files, and
# pass the file_path to process_and_plot().
walk(csv_files, process_and_plot)
