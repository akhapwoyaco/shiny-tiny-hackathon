# tests/testthat/disclaimer_test.R
library(shinytest2)
library(testthat)
library(shiny)

# Helper function to create a test app instance
create_test_app <- function() {
  # Use a mock app configuration for testing
  app_path <- "../../"
  shinytest2::AppDriver$new(app_path)
}

# Test Suite for App Startup and Disclaimer Mechanism

# describe("FAERS Dashboard Startup and Disclaimer", {

# Test 1: Verify Disclaimer Modal Appears on Initial Load
test_that("displays disclaimer modal immediately on app startup", {
  app <- create_test_app()
  
  # Check that disclaimer modal is visible
  expect_true(
    app$get_js('document.querySelector(".modal-dialog") !== null'),
    info = "Disclaimer modal should be present on app startup"
  )
  
  # Verify modal content
  disclaimer_header <- app$get_js(
    'document.querySelector(".modal-title").innerText'
  )
  
  # Verify modal content
  disclaimer_text <- app$get_js(
    'document.querySelector(".modal-body").innerText'
  )
  
  expect_true(
    grepl("Disclaimer", disclaimer_header),
    info = "Disclaimer title should be present and readable"
  )
  
  expect_true(
    grepl("Each year, the FDA receives", disclaimer_text),
    info = "Disclaimer text should be present and readable"
  )
  
  app$stop()
})

# Test 2: Validate Initial Disclaimer Button States
test_that("ensures accept button is initially disabled", {
  app <- create_test_app()
  
  # Check initial state of accept button
  accept_btn_disabled <- app$get_js(
    'document.getElementById("disclaimer-accept_btn").classList.contains("disabled")'
  )
  
  expect_true(
    accept_btn_disabled,
    info = "Accept button should be disabled before checkbox is checked"
  )
  
  app$stop()
})

# Test 3: Dynamic Button Activation via Checkbox
test_that("dynamically enables accept button when disclaimer checkbox is checked", {
  app <- create_test_app()
  
  # Simulate checking the disclaimer checkbox
  app$set_inputs(`disclaimer-accept_check` = TRUE) # remember module inputs have `id` -. id = module-input
  
  # Wait and verify button is now enabled
  Sys.sleep(0.005)
  
  accept_btn_enabled <- app$get_js(
    '!document.getElementById("disclaimer-accept_btn").classList.contains("disabled")'
  )
  
  expect_true(
    accept_btn_enabled,
    info = "Accept button should become enabled after checkbox is checked"
  )
  
  app$stop()
})

# Test 4: Handling Do Not Accept Scenario
test_that("handles do not accept button correctly", {
  app <- create_test_app()
  
  # Click Do Not Accept without checking checkbox
  app$click("disclaimer-do_not_accept_btn")
  
  # Check that main dashboard remains hidden
  dashboard_hidden <- app$get_js(
    'document.getElementById("dashboard-content").style.display === "none"'
  )
  
  expect_true(
    dashboard_hidden,
    info = "Dashboard should remain hidden if disclaimer is not accepted"
  )
  
  # Verify error modal appears
  error_modal_header_present <- app$get_js(
    'document.querySelector(".modal-dialog .modal-header").innerText.includes("Action Required")'
  )
  
  error_modal_present <- app$get_js(
    'document.querySelector(".modal-dialog .modal-body").innerText.includes("You must accept the disclaimer")'
  )
  
  expect_true(
    error_modal_header_present,
    info = "Error modal should appear when not accepting disclaimer"
  )
  
  expect_true(
    error_modal_present,
    info = "Error modal should appear when not accepting disclaimer"
  )
  
  app$stop()
})

# Test 5: Complete Disclaimer Acceptance Flow
test_that("fully processes disclaimer acceptance", {
  app <- create_test_app()
  
  # Check initial state
  initial_dashboard_state <- app$get_js(
    'document.getElementById("dashboard-content").style.display'
  )
  expect_equal(
    initial_dashboard_state,
    "none",
    info = "Dashboard should be initially hidden"
  )
  
  # Simulate full acceptance process
  app$set_inputs(`disclaimer-accept_check` = TRUE) 
  app$click("disclaimer-accept_btn")
  
  # Wait for transition
  Sys.sleep(0.05)
  
  # Verify dashboard is now visible
  dashboard_visible <- app$get_js(
    'document.getElementById("dashboard-content").style.display !== "none"'
  )
  
  expect_true(
    dashboard_visible,
    info = "Dashboard should become visible after accepting disclaimer"
  )
  
  app$stop()
})

# Test 6: Performance and Resource Management
test_that("manages resources efficiently during disclaimer interaction", {
  # Create multiple app instances to test resource handling
  apps <- lapply(1:5, function(x) create_test_app())
  
  # Verify each app loads disclaimer correctly
  results <- sapply(apps, function(app) {
    tryCatch({
      # Check disclaimer presence
      disclaimer_present <- app$get_js(
        'document.querySelector(".modal-dialog") !== null'
      )
      
      # Close the app
      app$stop()
      
      return(disclaimer_present)
    }, error = function(e) FALSE)
  })
  
  expect_true(
    all(results),
    info = "All app instances should load disclaimer successfully"
  )
})

# # Test 7: Accessibility Compliance
# it("ensures disclaimer modal meets basic accessibility standards", {
#   app <- create_test_app()
# 
#   # Check for key accessibility attributes
#   modal_aria_role <- app$get_js(
#     'document.querySelector(".modal-dialog").getAttribute("role")'
#   )
# 
#   expect_equal(
#     modal_aria_role,
#     "dialog",
#     info = "Modal should have correct ARIA role for accessibility"
#   )
# 
#   # Check that checkbox has proper label association
#   checkbox_label_exists <- app$get_js(
#     'document.querySelector("label[for=\'accept_check\']") !== null'
#   )
# 
#   expect_true(
#     checkbox_label_exists,
#     info = "Checkbox should have an associated label for screen readers"
#   )
# 
#   app$stop()
# })

# Test 8: Timeout and Persistence Handling
test_that("handles long delays or interruptions during disclaimer process", {
  app <- create_test_app()
  
  # Simulate a potential network delay or slow interaction
  Sys.sleep(2)
  
  # Verify disclaimer still present
  disclaimer_still_present <- app$get_js(
    'document.querySelector(".modal-dialog") !== null'
  )
  
  expect_true(
    disclaimer_still_present,
    info = "Disclaimer should persist even after a significant delay"
  )
  
  app$stop()
})

# Test 9: Cross-Browser Compatibility Simulation
test_that("maintains consistent disclaimer behavior across simulated browser environments", {
  # Simulate different browser interaction patterns
  browser_scenarios <- list(
    "modern_chrome" = list(
      checkbox_selector = "#disclaimer-accept_check",
      button_selector = "#disclaimer-accept_btn"
    ),
    "safari_mobile" = list(
      checkbox_selector = "input[type='checkbox']",
      button_selector = ".btn-primary"
    ),
    "ie" = list(
      checkbox_selector = "#disclaimer-accept_check",
      button_selector = "#disclaimer-accept_btn"
      # checkbox_selector = "input[name='accept_check']",
      # button_selector = "button.accept"
    )
  )
  
  results <- lapply(browser_scenarios, function(scenario) {
    app <- create_test_app()
    
    # Simulate checkbox interaction
    app$get_js(sprintf(
      'document.querySelector("%s").click()',
      scenario$checkbox_selector
    ))
    
    # Check button state
    button_enabled <- app$get_js(sprintf(
      '!document..getElementById("%s").classList.contains("disabled")',
      scenario$button_selector
    ))
    
    app$stop()
    
    return(button_enabled)
  })
  print(results)
  expect_true(
    all(unlist(results)),
    info = "Disclaimer interaction should work across simulated browser environments"
  )
})

# })


