# FDA Adverse Events Reporting System (FAERS) Dashboard

This Shiny application mimics the FDA's FAERS Public Dashboard, which displays information about adverse event reports received by the FDA for drugs and therapeutic biologic products.

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
   git clone https://github.com/your-username/faers-dashboard.git
   cd faers-dashboard
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
├── www/                  # Static resources
│   └── fda-logo.png      # FDA logo image
│
├── modules/              # Shiny modules
│   ├── disclaimer_module.R     # Handles the disclaimer popup
│   ├── report_table_module.R   # Manages the data table
│   └── report_plot_module.R    # Creates the stacked bar chart
│
├── data/                 # Data files (not included in this repo)
│   └── faers_data.csv    # Sample data file (you'll need to provide this)
│
└── tests/                # Unit tests
    └── testthat/
        └── test-modules.R  # Tests for the Shiny modules
```

## Usage

When you first launch the application, you'll see a disclaimer popup. You must check the "I have read and understand the disclaimer" box and click "Accept" to proceed to the dashboard.

Once the disclaimer is accepted, you can:
1. Select different report types from the dropdown menu
2. Filter by year or report type
3. Toggle between "All Years" and "Last 10 Years" views
4. Click on table rows to highlight specific years
5. Interact with the stacked bar chart to view details about specific report counts

## Data Source

The application is designed to work with a CSV file containing FAERS data. The expected columns are:
- Year
- ReportType
- Count
- TotalReports
- SeriousReports 
- DeathReports

You can replace the mock data in the app with actual FAERS data by obtaining it from the FDA website.

## Testing

Run the unit tests using:
```R
testthat::test_dir("tests/testthat/")
```

## Notes and Limitations

- This application is a demonstration and is not officially affiliated with or endorsed by the FDA.
- The dashboard uses mock data based on the screenshots provided. Replace with actual FAERS data for production use.
- Some features of the original FDA dashboard may be simplified or omitted.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
# FDA Adverse Events Reporting System (FAERS) Dashboard

This Shiny application mimics the FDA's FAERS Public Dashboard, which displays information about adverse event reports received by the FDA for drugs and therapeutic biologic products.

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
   git clone https://github.com/akhapwoyaco/faers-dashboard.git
   cd faers-dashboard
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
├── www/                  # Static resources
│   └── fda-logo.png      # FDA logo image
│
├── modules/              # Shiny modules
│   ├── disclaimer_module.R     # Handles the disclaimer popup
│   ├── report_table_module.R   # Manages the data table
│   └── report_plot_module.R    # Creates the stacked bar chart
│
├── data/                 # Data files (not included in this repo)
│   └── faers_data.csv    # Sample data file (you'll need to provide this)
│
└── tests/                # Unit tests
    └── testthat/
        └── test-modules.R  # Tests for the Shiny modules
```

## Usage

When you first launch the application, you'll see a disclaimer popup. You must check the "I have read and understand the disclaimer" box and click "Accept" to proceed to the dashboard.

Once the disclaimer is accepted, you can:
1. Select different report types from the dropdown menu
2. Filter by year or report type
3. Toggle between "All Years" and "Last 10 Years" views
4. Click on table rows to highlight specific years
5. Interact with the stacked bar chart to view details about specific report counts

## Data Source

The application is designed to work with a CSV file containing FAERS data. The expected columns are:
- Year
- ReportType
- Count
- TotalReports
- SeriousReports 
- DeathReports

You can replace the mock data in the app with actual FAERS data by obtaining it from the FDA website.

## Testing

Run the unit tests using:
```R
testthat::test_dir("tests/testthat/")
```

## Notes and Limitations

- This application is a demonstration and is not officially affiliated with or endorsed by the FDA.
- The dashboard uses mock data based on the screenshots provided. Replace with actual FAERS data for production use.
- Some features of the original FDA dashboard may be simplified or omitted.

## License



