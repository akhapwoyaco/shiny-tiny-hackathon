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

#

#

# Load modules
source("modules/disclaimer-module.r")
source("modules/report-table-module.r")
source("modules/report-plot-module.r")
source("modules/data_loader_module.R")
source("modules/less_module.R")
source("global.R")

# Define UI
ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      .header {
        /*background-color: #3c8dbc;*/
        color: black;
        padding: 10px;
        margin-bottom: 15px;
      }
      
      .footer {
        border-top: 1px solid #ddd;
        padding: 10px;
        margin-top: 15px;
        font-size: 12px;
      }
      
      .dashboard-container {
        margin-top: 20px;
      }
      
      .summary-box {
        text-align: center;
        padding: 15px;
        margin-bottom: 15px;
        border-radius: 5px;
      }
      
      .total-reports {
        background-color: #f8f9fa;
        border: 1px solid #ddd;
      }
      
      .serious-reports {
        background-color: #fff3cd;
        border: 1px solid #ffeeba;
      }
      
      .death-reports {
        background-color: #f8d7da;
        border: 1px solid #f5c6cb;
      }
      
      #disclaimer-message {
        font-size: 14px;
        line-height: 1.5;
      }
      
      .btn-primary {
        background-color: #3c8dbc;
      }
      
      .disclaimer-footer {
        margin-top: 15px;
        text-align: right;
      }
      
      .disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
      
      .year-filter, .report-type-filter {
        margin-bottom: 15px;
      }
      
      .nav-tabs {
        margin-bottom: 15px;
      }
      #navbar {
        background-color: #3c8dbc;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 20px;
        color: black;
        
      }
      #navbar a {
        margin: 0 10px;
        color: white;
        flex-grow:1;
        text-align:center;
        
      }
      .clickable-header:hover {
        background-color: #e9ecef;
      }
      
      .dt-clickable {
        cursor: pointer;
      }
      
      .selected-column {
        background-color: #e2f0fb !important;
      }

    ")),
    tags$script(HTML("
      $(document).ready(function(){
        // Enable or disable accept button based on checkbox
        $('#accept-check').on('change', function() {
          if($(this).is(':checked')) {
            $('#accept-btn').removeClass('disabled');
          } else {
            $('#accept-btn').addClass('disabled');
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
  navbarPage("", id = "navbar", 
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
      hidden(div(id = "dashboard-content",
                      fluidRow(
                   column(8,
                          div(class = "summary-box total-reports",
                              h4("Total Reports"),
                              dataframeTextUI("my_data"))),
                   column(4,
                          selectInput(
                            "report_filter_type", "Reports by", 
                            choices = c("Reports by Report Type", 
                                        "Reports by Reporter", 
                                        "Reports by Reporter Region", 
                                        "Reports by Report Seriousness", 
                                        "Reports by Age Group", 
                                        "Reports by Sex"),
                            selected = "Reports by Report Type",
                            width = "100%")
                   )
                 ),
                 
                 # fluidRow(
                 #   column(12,
                 #          div(class = "btn-group", style = "margin-bottom: 15px;",
                 #              actionButton("all_years_btn", "All Years", class = "btn-primary"),
                 #              actionButton("last_10_years_btn", "Last 10 Years", class = "btn-default")
                 #          )
                 #   )
                 # ),
                 fluidRow(
                   column(12, h4("Reports received by Report Type"))
                 ),
                 
                 fluidRow(
                   column(6, 
                          reportTableOutput("report_table")
                   ),
                   column(6, 
                          reportPlotOutput("report_plot"))
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
  dataframeTextServer("my_data", report_data$totals_data)
  # Update UI based on disclaimer acceptance
  observeEvent(disclaimer_accepted(), {
    if (disclaimer_accepted()) {
      show("dashboard-content")
    } else {
      hide("dashboard-content")
    }
  })
  #
  bar_results = reportPlotServer("report_plot", 
                                 report_data$yearly_data, 
                                 selected_categories = reactive(NULL))
  #
  reportTableServer("report_table", 
                    report_data$yearly_data, 
                    selected_categories = bar_results$selected_categories)
  #
}

# Run the application
shinyApp(ui = ui, server = server)
