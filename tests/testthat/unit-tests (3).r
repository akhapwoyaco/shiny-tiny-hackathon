# tests/testthat/test-modules.R
library(testthat)
library(shiny)
library(shinytest)

context("FAERS Dashboard Tests")

# Mock data for testing
create_mock_data <- function() {
  years <- 2020:2024
  
  data.frame(
    Year = rep(years, each = 4),
    ReportType = rep(c("Expedited", "Non-Expedited", "Direct", "BSR"), times = length(years)),
    Count = sample(10000:100000, length(years) * 4, replace = TRUE),
    TotalReports = rep(sample(200000:300000, length(years)), each = 4),
    SeriousReports = rep(sample(100000:200000, length(years)), each = 4),
    DeathReports = rep(sample(10000:30000, length(years)), each = 4)
  )
}

# Test the disclaimer module
test_that("Disclaimer module works correctly", {
  testServer(disclaimerServer, {
    # Initial state should be FALSE
    expect_false(session$getReturned()())
    
    # Simulate not accepting
    session$setInputs(do_not_accept_btn = 1)
    expect_false(session$getReturned()())
    
    # Simulate checking the box but not accepting
    session$setInputs(accept_check = TRUE)
    expect_false(session$getReturned()())
    
    # Simulate accepting with checkbox checked
    session$setInputs(accept_btn = 1)
    expect_true(session$getReturned()())
  })
})

# Test the report table module
test_that("Report table module creates correct table", {
  mock_data <- create_mock_data()
  
  testServer(reportTableServer, args = list(data = reactive(mock_data)), {
    # Expect the table to have the right dimensions
    expect_equal(nrow(summarized_data()), length(unique(mock_data$Year)))
    
    # Expect columns for each report type plus Year and Total
    expected_cols <- c("Year", "Expedited", "Non-Expedited", "Direct", "BSR", "TotalReports")
    expect_true(all(expected_cols %in% colnames(summarized_data())))
  })
})

# Test the report plot module
test_that("Report plot module creates plot", {
  mock_data <- create_mock_data()
  
  testServer(reportPlotServer, args = list(data = reactive(mock_data)), {
    # This is more of a smoke test - the plot should be created without error
    expect_error(output$report_plot, NA)
  })
})

# Integration tests would require a more comprehensive framework with shinytest
# This is a placeholder for additional tests
test_that("App initializes correctly", {
  # Would use shinytest to:
  # 1. Check that disclaimer shows on startup
  # 2. Verify that dashboard is hidden until disclaimer is accepted
  # 3. Test filter interactions
  # 4. Test year selection buttons
  # Skip for now as it requires a full app instance
  skip("Integration tests require shinytest with a running app")
})
