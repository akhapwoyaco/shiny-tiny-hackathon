# modules/data_loader_module.R

library(readxl)
library(tools)

# UI Function - not much UI needed for the loader
dataLoaderUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Instead, we'll use a hidden element to track loading status
    hidden(
      div(id = ns("loading_status"),
          "Loading data..."
       )
    ),
    verbatimTextOutput(ns("log_output"))
  )
}

# Server Function
dataLoaderServer <- function(id, report_type) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      # Logger - write to UI and to custom log
      log_to_ui <- reactiveVal("")
      
      log <- function(message, level = "INFO") {
        # Use our custom logger
        custom_logger(message, level)
        
        # Update UI log
        current_log <- log_to_ui()
        new_log <- paste0(format(Sys.time(), "%H:%M:%S"), " [", level, "] ", message, "\n", current_log)
        log_to_ui(new_log)
      }
      
      # Define data directory - adjust as needed
      data_dir <- "data"
      
      # Initialize reactive values to store our data
      data_store <- reactiveValues(
        totals_row = NULL,       # First row with totals
        yearly_data = NULL,      # All other rows with yearly data
        file_loaded = FALSE,     # Flag if data is currently loaded
        current_file = NULL,      # Name of current file
        years = NULL, # unique years
        column_categories = NULL # columns except first of years
      )
      
      # Watch for changes in report type and load appropriate data
      observeEvent(report_type(), {
        # Show loading status
        shinyjs::show("loading_status")
        
        # Get report type and transform to expected filename
        selected_type <- report_type()
        
        # Extract the part after "Reports by"
        file_suffix <- gsub("Reports by ", "", selected_type)
        
        # print(file_suffix)
        
        # Convert to snake case for filename
        file_name <- tolower(gsub(" ", "_", file_suffix))
        file_path <- file.path(data_dir, paste0(file_name, ".xlsx"))
        
        log(paste("Loading file:", file_path), "INFO")
   
        # Try to load the data
        tryCatch({
          log(paste("TRY CATCH Loading file:", file_path), "INFO")
          # We use readxl package if available, otherwise suggest installation
          if (!requireNamespace("readxl", quietly = TRUE)) {
            stop("Package 'readxl' is required but not installed. Install with install.packages('readxl')")
          }
          # Load from Excel if file exists
          raw_data <- readxl::read_excel(file_path, na = c(" ", "-"))
          
          # Convert to data.frame to ensure consistent behavior
          raw_data <- as.data.frame(raw_data) |> 
            dplyr::select(where(~!all(is.na(.))))
          
          log(paste("DATA Loaded file:", file_path), "INFO")
          
          # Check if data has at least one row
          if (nrow(raw_data) < 1) {
            stop("Excel file contains no data")
          } else {
            log(paste(file_path, " ,nrows:", nrow(raw_data)),"INFO")
          }
          # Split the data as per requirements
          data_store$totals_row <- raw_data[1, , drop = FALSE]
          
          # Check if there's data beyond the totals row
          if (nrow(raw_data) > 1) {
            
            data_beyond = raw_data[-1, , drop = FALSE]
              
            log(paste(file_path, " ,1nrows:", nrow(raw_data)),"INFO")
            data_store$yearly_data <- data_beyond
            
            years = data_beyond |> select(Year) |> pull()
            
            data_store$years = sort(unique( years ))
            data_store$column_categories <- colnames(data_beyond)[-1]
            
          } else {
            data_store$yearly_data <- NULL
            log("File only contains totals row, no yearly data", "WARNING")
          }
          
          data_store$file_loaded <- TRUE
          data_store$current_file <- file_path
          
          log(paste("Successfully loaded", file_path, "with", 
                    nrow(data_store$yearly_data), "years of data across", 
                    ncol(raw_data) - 1, "categories"), "SUCCESS")
          
        }, error = function(e) {
          # If error,
          log(paste("Error loading file:", e$message), "ERROR")
          data_store$file_loaded <- FALSE
        }, # warnings
        warning = function(w) {
          log(paste("Warning during load:", w$message), "WARNING")
        }
        )
        # Hide loading status
        shinyjs::hide("loading_status")
      })
      # Output logs to UI
      # output$log_output <- renderText({
      #   log_to_ui()})
      # Return reactive outputs for use by the parent module/app
      return(list(
        totals_data = reactive({ data_store$totals_row }),
        yearly_data = reactive({ data_store$yearly_data }),
        years = reactive({ data_store$years }),
        column_categories = reactive({ data_store$column_categories }),
        is_data_loaded = reactive({ data_store$file_loaded }),
        current_file = reactive({ data_store$current_file }),
        log_entries = reactive({ get("log_history", envir = .GlobalEnv) })
      ))
      
    }
  )
}