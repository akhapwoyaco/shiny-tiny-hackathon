# FDA Adverse Events Reporting System (FAERS) Dashboard

This Shiny application mimics the FDA's FAERS Public Dashboard, which displays information about adverse event reports received by the FDA for drugs and therapeutic biologic products.


## [APP](https://akhapwoyachris.shinyapps.io/appsilon_shiny_tiny_hackathon/) 

LInk: https://akhapwoyachris.shinyapps.io/appsilon_shiny_tiny_hackathon/


## Features

- Disclaimer popup that must be accepted before viewing data
- Summary statistics for total reports, serious reports, and death reports
- Interactive data table with filtering capabilities
- Stacked bar chart visualization that can be scrolled horizontally
- Multiple filtering options through dropdown menus
- Year range selection (All Years vs Last 10 Years)
- Responsive design for different screen sizes

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/akhapwoyaco/shiny-tiny-hackathon.git
   cd shiny-tiny-hackathon
   ```

2. Install the required R packages:
   ```R
   install.packages(c("shiny", "shinydashboard", "shinyjs", "DT", "dplyr", "tidyr", "ggplot2", "plotly", "testthat", "shinytest"))
   ```

3. Run the application:
   ```R
   shiny::runApp()
   ```

## Project Structure

```
faers-dashboard/
│
├── app.R                 # Main application file
├── global.R              # global function logger
├── www/                  # Static resources
│   └── fda-logo.png      # FDA logo image
│
├── modules/              # Shiny modules
│   ├── data_loader_module.R  # load the datasets
│   ├── summary-statistics.R (Reactive)/less_module.R (Non-Reactive)         # format total-summary output
│   ├── disclaimer_module.R     # Handles the disclaimer popup
│   ├── report_table_module.R   # Manages the data table
│   └── report_plot_module.R    # Creates the stacked bar chart
│
├── data/                 # Data files (included in this repo/ downloaed from the site)
│   ├── age_group.xlsx
│   ├── report_seriousness.xlsx
│   ├── report_type.xlsx
│   ├── reporter.xlsx
│   ├── reporter_region.xlsx
│   └── sex.xlsx
│
└── tests/                # Unit tests
    └── testthat/
        └── disclaimer_test  # Tests for the Disclaimer Shiny module
```

## Usage

When you first launch the application, you'll see a disclaimer popup. You must check the "I have read and understand the disclaimer" box and click "Accept" to proceed to the dashboard.

Once the disclaimer is accepted, you can:
0. Accept Disclaimer
1. Select different report types from the dropdown menu
2. Filter by report type
3. Toggle between bars to filter the table as well as update the summary statistics 
4. Click on table rows to highlight specific column (TODO)
5. Interact with the stacked bar chart to view details about specific report counts

## Data Source

The application is designed to work with a CSV file containing FAERS data. The expected columns are:
- Year
- ReportType
- Count

## Testing 

TODO

Run the unit tests using:
```R
testthat::test_dir("tests/testthat/")
```

## Notes and Limitations

- This application is a demonstration and is not officially affiliated with or endorsed by the FDA.
- The dashboard uses mock data based on the screenshots provided. Replace with actual FAERS data for production use.
- Some features of the original FDA dashboard may be simplified or omitted.

## License



