# app.R
library(shiny)
library(shinydashboard)
library(shinyjs)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(tools)
library(htmlwidgets)
library(jsonlite)
#

#

# Load modules
source("modules/disclaimer-module.r")
source("modules/report-table-module.r")
source("modules/report-plot-module.r")
source("modules/data_loader_module.R")
source("modules/less_module.R")
source("modules/summary_statistics.R")
source("global.R")

# Define UI
ui <- fluidPage(
  useShinyjs(),
  includeCSS(path = file.path('www/css/main.css')),
  tags$head(
    # tags$style(HTML("")),
    tags$script(HTML("
      $(document).ready(function(){
        // Enable or disable accept button based on checkbox
        $('#accept-check').on('change', function() {
          if($(this).is(':checked')) {
            $('#accept-btn').removeClass('disabled');
          } else {
            $('#accept-btn').addClass ('disabled');
          }
        });
        
        // Handle table row selection
        $(document).on('click', '.data-table tbody tr', function() {
          $(this).toggleClass('selected');
          // Custom event to capture selection
          $(document).trigger('tableRowSelected', [$(this).data('year')]);
        });
      });
      
      // table selection
      $(document).on('click', 'table.report_table thead th', function() {
        var table = $(this).closest('table').DataTable();
        var colIdx = table.column($(this)).index();
        if (colIdx !== undefined) {
          Shiny.setInputValue('datatable_columns_selected', colIdx);
        }
      });
      
      //
      Shiny.addCustomMessageHandler('resetTableFilter', function(message) {
        if(message) {
          // Clear all opacity settings on plot
          var graphDiv = document.getElementById('report_plot-report_plot');
          if(graphDiv) {
            Plotly.restyle(graphDiv, {'marker.opacity': 1});
          }
          
          // Reset any table filtering if a DataTable API is available
          if(typeof $.fn.dataTable !== 'undefined') {
            $('.dataTable').each(function(){
              $(this).DataTable().search('').columns().search('').draw();
            });
          }
        }
      });
    "))
  ),
  
  # Header
  div(class = "header",
      fluidRow(
        column(6, 
               h3("FDA Adverse Events Reporting System (FAERS) Public Dashboard", 
                  style = "margin: 0;")
        ),
        column(6, 
               div(style = "text-align: right;",
                   tags$img(src = file.path("updatedFDA.png"), height = "40px", alt = "FDA Logo")
               )
        )
      )
  ),
  
  # Navigation menu
  navbarPage(title = NULL,id = "navbar", 
             tabPanel("Home", icon = icon("home")),
             tabPanel("Search", icon = icon("search")),
             tabPanel("Disclaimer", icon = icon("info-circle")),
             tabPanel("Report a Problem", icon = icon("exclamation-triangle")),
             tabPanel("FAQ", icon = icon("question-circle")),
             tabPanel("Site Feedback", icon = icon("comment"))
  ),
  
  # Main content
  div(id = "main-content",
      # This will be shown/hidden based on disclaimer acceptance
      hidden(
        div(
          id = "dashboard-content",
          # dataframeTextUI("my_data")
          
          fluidRow(
            column(8,
                   selectInput(
                     "report_filter_type", "Select Reports by", 
                     choices = c("Reports by Report Type", 
                                 "Reports by Reporter", 
                                 "Reports by Reporter Region", 
                                 "Reports by Report Seriousness", 
                                 "Reports by Age Group", 
                                 "Reports by Sex"),
                     selected = "Reports by Report Type",
                     width = "100%"),
                   reportPlotUI("report_plot")
            ),
            column(4, summaryStatsUI("stats"))
          ),
          fluidRow(
            column(12, h4("Reports received by Report Type: Click on Bar For Selection and De-selection of Data"))
          ),
          fluidRow(
            column(12, 
                   reportTableUI("report_table")
            )
          )
        )),
      
      # Disclaimer modal will be handled by the disclaimer module
      disclaimerOutput("disclaimer")
  ),
  
  # Footer
  div(class = "footer",
      p("Data as of December 31, 2024"),
      p("This page displays the number of adverse event reports received by FDA for drugs and therapeutic biologic products by the following Report Types:"),
      tags$ul(
        tags$li("Direct Reports are voluntarily submitted directly to FDA through the MedWatch program by consumers and healthcare professionals."),
        tags$li("Mandatory Reports are submitted by manufacturers and are categorized as:",
                tags$ul(
                  tags$li("Expedited reports that contain at least one adverse event that is not currently described in the product labeling and for which the patient outcome is serious, or"),
                  tags$li("Non-expedited reports that do not meet the criteria for expedited reports, including cases that are reported as Serious and expected, Non-serious and unexpected and Non-serious and expected.")
                )
        )
      )
  )
)

# Define server
server <- function(input, output, session) {
  
  # logger
  log <- function(message, level = "INFO") {
    # Use our custom logger
    custom_logger(message, level)
  }
  #
  log(message = "Session Startup", level = "SUCCESS")
  
  # Disclaimer logic
  disclaimer_accepted <- disclaimerServer("disclaimer")
  
  #
  # Data loading based on selected report type
  selected_report_type <- reactive({
    input$report_filter_type
  })
  #
  # Load data based on report type
  report_data <- dataLoaderServer("data_loader", selected_report_type)
  #
  # dataframeTextServer("my_data", report_data$totals_data)
  # Update UI based on disclaimer acceptance
  observeEvent(disclaimer_accepted(), {
    log(message = "Update UI based on disclaimer acceptance", level = "SUCCESS")
    if (disclaimer_accepted()) {
      show("dashboard-content")
    } else {
      hide("dashboard-content")
    }
  })
  #
  # Initialize the summary stats module with selections from both
  summaryStatsServer("stats", 
                     data = report_data$yearly_data,
                     selected_years = bar_results$selected_categories,
                     selected_metrics = bar_results$selected_metrics)
  #
  bar_results = reportPlotServer("report_plot", 
                                 report_data$yearly_data, 
                                 selected_categories = reactive(NULL),
                                 selected_columns = reactive(table_selections()))
  #
  table_selections = reportTableServer("report_table", 
                                       report_data$yearly_data, 
                                       selected_categories = bar_results$selected_categories)
  #
  # Handle table column header clicks
  observeEvent(input$datatable_columns_selected, {
    if (!is.null(input$datatable_columns_selected)) {
      col_idx <- as.numeric(input$datatable_columns_selected)
      
      # Get column name from data table
      all_cols <- colnames(data())
      if (col_idx < length(all_cols)) {
        col_name <- all_cols[col_idx + 1]  # +1 because JS is 0-indexed
        
        # Highlight the column in UI
        runjs(paste0("
          $('.dataTable thead th').removeClass('selected-column');
          $('.dataTable thead th:eq(", input$datatable_columns_selected, ")').addClass('selected-column');
        "))
      }
    }
  })
  #
  
  # Track session end
  session$onSessionEnded(function() {
    log(message = "Session ended", level = "SUCCESS")
  })
  #
}

# Run the application
shinyApp(ui = ui, server = server)
