#-------------------------------------------------
summaryStatsUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "panel panel-default",
      style = "padding: 15px; border: 1px solid #ddd; border-radius: 5px; margin-bottom: 15px;",
      tags$h4("Summary Statistics"),
      uiOutput(ns("summaryStats"))
    )
  )
}

summaryStatsServer <- function(id, data, selected_years = reactive(NULL), selected_metrics = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {
    
    # logger
    log <- function(message, level = "INFO") {
      # Use our custom logger
      custom_logger(message, level)
    }
    
    log(paste("summaryStatsServer-", id, "Initialization"), "INFO")
    
    # Filter data based on selections
    filtered_data <- reactive({
      req(data())
      df <- data()
      
      if (!is.null(selected_years()) && length(selected_years()) > 0) {
        df = df |> dplyr::filter(Year %in% selected_years())
      } 
      
      return(df)
    })
    
    # Calculate summary statistics for all metrics
    summary_stats <- reactive({
      req(filtered_data())
      df <- filtered_data()
      
      # Default to all metric columns except Total
      metric_cols <- setdiff(colnames(df), c("Year"))
      
      
      # Calculate summaries
      result <- list(
        Totals = colSums(df[, metric_cols], na.rm = TRUE),
        Averages = colMeans(df[, metric_cols], na.rm = TRUE),
        Years = length(unique(df$Year)),
        Categories = length(unique(metric_cols))
      )
      
      return(result)
    })
    
    # Render summary statistics
    output$summaryStats <- renderUI({
      stats <- summary_stats()
      
      # Get current metrics
      metrics <- if (!is.null(selected_metrics()) && length(selected_metrics()) > 0) {
        c(selected_metrics(), "Total Reports")
      } else {
        # Default to all metric columns
        setdiff(colnames(df), c("Year", "Total Reports"))
      }
      
      tagList(
        tags$h5("Totals by Metric"),
        tags$div(
          class = "row",
          lapply(metrics, function(metric) {
            
            tags$div(
              class = "col",
              tags$div(
                # class = "col-md-3",
                style = "text-align: center; padding: 10px; background-color: #f8f9fa; border-radius: 5px; margin-bottom: 10px;",
                tags$h6(metric),
                # tags$h4(
                  formatC(stats$Totals[metric], format="f", digits=2, big.mark=",")#)
              )
            )
          })
        ),
        tags$hr(),
        tags$div(
          class = "row",
          tags$div(
            class = "col-md-3",
            tags$div(
              style = "text-align: center; color: green; padding: 10px; background-color: #f8f9fa; border-radius: 5px;",
              tags$h6("Selected Years"),
              tags$h4(style = "color: #17a2b8;", stats$Years)
            )
          ),
          tags$div(
            class = "col-md-3",
            tags$div(
              style = "text-align: center; color: green; padding: 10px; background-color: #f8f9fa; border-radius: 5px;",
              tags$h6("Categories"),
              tags$h4(style = "color: #17a2b8;", stats$Categories)
            )
          ),
          tags$div(
            class = "col-md-6",
            tags$div(
              style = "text-align: center; color: green; padding: 10px; background-color: #f8f9fa; border-radius: 5px;",
              tags$h6("Grand Total"),
              tags$h4(style = "color: #17a2b8;", formatC(stats$Totals["Total Reports"], format="f", digits=2, big.mark=","))
            )
          )
        )
      )
    })
  })
}