# Weight-Tracker
R script to plot weight from a csv file.

## Intended Use
This script is meant to track the weight change of multiple people and create little plots of weight over time.
I use it to help my wife visualize her progress and keep us accountable to each other.

## How to Use
1. Put a csv file with dates and weight in the data folder.
  - The file name should follow the form "{name}_{height in inches}_{weekly weight change}.csv".
  - {name} is a string.
  - {height} is an integer.
  - {weekly weight change} is a double. Negative for weight loss, positive for weight gain. Leave out to not plot a goal line.
  - The first column 'date' has format "yyyy-mm-dd".
  - The second column ' weight' is a dbl value representing weight in pounds.
2. Run the R script by running 'tar_make()' in an R console.
3. Check the output folder. The resultant plots end up there.

## Features
- Iterates through every csv file in the data folder.
- Runs using the targets package. Only CSV's that have been updated will be run again.
- Calculates and colors a recommended weight range based off BMI.
  - BMI is NOT a great indicator of health, but it's a starting place.
  - The minimum BMI value is 18.5 and the max is 23.9.
- Goals are plotted as a fixed line.
- Plot size is set by the targets 'start_date' and 'weeks'.
- Plot height automatically adjusts it's y-scale to fit weight and recommended weight range.
