## load the required libraries. ######################################

library(ggplot2) # makes the plots
library(tidyverse) # handles the data manipulation

## Define variables ##################################################

start_date <- as.Date("2026-02-08") + 7
weeks <- 12 # represents the number of weeks we want to plot

## get a list of all the file paths ##################################

csv_files <- list.files("data", pattern = "*habit.csv", full.names = TRUE)

# debug tool: print the variables we currently have
print("General Data")
print(paste0("Start date: ", as.character(start_date)))
print(paste0("weeks:      ", weeks))
print(paste0("CSV files:  ", csv_files))

## Process each file found in data ###################################
# This is where the main logic is handled.
# First we define the function process_and_plot(). This is where most
# of the logic is handled.
# Then, walk() iterates through file path listed in csv_files and then
# applies process_and_plot() to each file found in the data folder.

process_and_plot <- function(file_path) {  
  # extract name from the file name
  file_name <- tools::file_path_sans_ext(basename(file_path))
  name_elements <- unlist(str_split(file_name, "_"))
  name <- name_elements[1]
  
  # read the individual's csv file into a tibble.
  data <- read_csv(file_path, show_col_types = FALSE)
  # show_col_types quiets the output.

  # Debug messages
  print(paste0("file name: ", file_name))
  print(paste0("Name:      ", name))
  print(data)

  # make sure date column is Date type
  data$date <- as.Date(data$date)

  # start_date and end_date will help us define the size of the plot
  end_date <- start_date + weeks * 7

  # total_days is needed to calculate the cumulative percentage of completion
  total_days = end_date - start_date

  # Take the boolean values from the csv, and calculate completion percentage
  data <- data %>%
    # make each row a single habit report with columns: date, habit, completed
    pivot_longer(-date, names_to = "habit", values_to "completed") %>%
    # for each habit...
    group_by(habit) %>%
    # make a new column called completion
    # calculate completion percentage for each habit up to that date.
    mutate(completion = cumsum(completed) / total_days * 100) %>%
    ungroup()
 
 
  # Start creating the plot
  p <- ggplot(data, aes(x = date, y = completion, color = habit)) +
    geom_line(size = 1) +
    labs(title = name, x = "Date", y = "Completion") +
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
