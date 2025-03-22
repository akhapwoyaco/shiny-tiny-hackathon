# app.R
library(shiny)
library(shinydashboard)
library(shinyjs)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)

# Load modules
source("modules/disclaimer-module.r")
source("modules/report-table-module.r")
source("modules/report-plot-module.r")

# Define UI
ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      .header {
        background-color: #3c8dbc;
        color: white;
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
                   column(4,
                          div(class = "summary-box total-reports",
                              h4("Total Reports"),
                              textOutput("total_reports_count")
                          )
                   ),
                   column(4,
                          div(class = "summary-box serious-reports",
                              h4("Serious Reports (excluding death)"),
                              textOutput("serious_reports_count")
                          )
                   ),
                   column(4,
                          div(class = "summary-box death-reports",
                              h4("Death Reports"),
                              textOutput("death_reports_count")
                          )
                   )
                 ),
                 
                 fluidRow(
                   column(12,
                          selectInput("report_filter_type", "Reports by", 
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
                 
                 fluidRow(
                   column(12,
                          div(class = "btn-group", style = "margin-bottom: 15px;",
                              actionButton("all_years_btn", "All Years", class = "btn-primary"),
                              actionButton("last_10_years_btn", "Last 10 Years", class = "btn-default")
                          )
                   )
                 ),
                 
                 fluidRow(
                   column(12, h4("Reports received by Report Type"))
                 ),
                 
                 fluidRow(
                   column(4, 
                          div(class = "year-filter",
                              selectInput("year_filter", "Year", choices = NULL)
                          ),
                          div(class = "report-type-filter",
                              selectInput("report_type_filter", "Report Type", choices = NULL)
                          ),
                          reportTableOutput("report_table")
                   ),
                   column(8, reportPlotOutput("report_plot"))
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
  
  # Data handling
  report_data <- reactive({
    # This would typically load from a file or database
    # For now we'll create mock data based on the screenshots
    req(disclaimer_accepted())
    
    years <- 2009:2024
    
    data <- data.frame(
      Year = rep(years, each = 4),
      ReportType = rep(c("Expedited", "Non-Expedited", "Direct", "BSR"), times = length(years)),
      Count = c(
        # Mock data for each year and report type
        # 2009
        330083, 126159, 34166, 0,
        # 2010
        409063, 234633, 28944, 0,
        # 2011
        498420, 255165, 28042, 0,
        # 2012
        574943, 326224, 29012, 0,
        # 2013
        631158, 409045, 28390, 0,
        # 2014
        741482, 422721, 34230, 0,
        # 2015
        833112, 845020, 41659, 0,
        # 2016
        863270, 769112, 50991, 0,
        # 2017
        941777, 801203, 62030, 0,
        # 2018
        1155290, 897308, 87551, 0,
        # 2019
        1215941, 854855, 105388, 0,
        # 2020
        1242171, 882083, 78560, 0,
        # 2021
        1387985, 868056, 72549, 0,
        # 2022
        1308258, 950762, 78079, 0,
        # 2023
        1248041, 837783, 68631, 0,
        # 2024
        1168649, 815057, 58123, 0
      )
    )
    
    # Add totals
    data_summarized <- data %>%
      group_by(Year) %>%
      summarize(TotalReports = sum(Count)) %>%
      ungroup()
    
    # Create a lookup for serious and death counts
    serious_counts <- data.frame(
      Year = years,
      SeriousReports = c(200000, 250000, 300000, 350000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000, 1100000, 1200000, 1300000, 1350000, 1372823),
      DeathReports = c(20000, 30000, 40000, 45000, 50000, 60000, 70000, 80000, 90000, 100000, 150000, 180000, 200000, 220000, 250000, 262500)
    )
    
    # Combine all data
    full_data <- data %>%
      left_join(data_summarized, by = "Year") %>%
      left_join(serious_counts, by = "Year")
    
    # Return the data
    return(full_data)
  })
  
  # Update UI based on disclaimer acceptance
  observeEvent(disclaimer_accepted(), {
    if (disclaimer_accepted()) {
      show("dashboard-content")
      
      # Initialize filters
      updateSelectInput(session, "year_filter",
                        choices = c("All", sort(unique(report_data()$Year), decreasing = TRUE)))
      
      updateSelectInput(session, "report_type_filter",
                        choices = c("All", unique(report_data()$ReportType)))
    } else {
      hide("dashboard-content")
    }
  })
  
  # Summary statistics
  output$total_reports_count <- renderText({
    format(sum(unique(report_data()$TotalReports)), big.mark = ",")
  })
  
  output$serious_reports_count <- renderText({
    format(max(report_data()$SeriousReports), big.mark = ",")
  })
  
  output$death_reports_count <- renderText({
    format(max(report_data()$DeathReports), big.mark = ",")
  })
  
  # Table and plot modules
  filtered_data <- reactive({
    req(report_data())
    data <- report_data()
    
    if (input$year_filter != "All") {
      data <- data %>% filter(Year == as.numeric(input$year_filter))
    }
    
    if (input$report_type_filter != "All") {
      data <- data %>% filter(ReportType == input$report_type_filter)
    }
    
    return(data)
  })
  
  reportTableServer("report_table", filtered_data)
  reportPlotServer("report_plot", filtered_data)
  
  # Handle year range selection
  observeEvent(input$all_years_btn, {
    updateSelectInput(session, "year_filter", selected = "All")
  })
  
  observeEvent(input$last_10_years_btn, {
    # Get the most recent 10 years
    recent_years <- sort(unique(report_data()$Year), decreasing = TRUE)[1:10]
    updateSelectInput(session, "year_filter", 
                     choices = c("All", sort(unique(report_data()$Year), decreasing = TRUE)),
                     selected = "All")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
