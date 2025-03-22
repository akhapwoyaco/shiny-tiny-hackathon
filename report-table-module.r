# modules/report_table_module.R

# UI Function
reportTableUI <- function(id) {
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("report_table"))
  )
}

# Server Function
reportTableServer <- function(id,data) {
  moduleServer(
    id,
    function(input, output, session) {
      # Create summary table
      summarized_data <- reactive({
        req(data())
        
        # Summarize data by year and report type
        summary_data <- data() %>%
          group_by(Year, ReportType) %>%
          summarize(Count = sum(Count), .groups = "drop") %>%
          ungroup()
        
        # Get total by year
        year_totals <- summary_data %>%
          group_by(Year) %>%
          summarize(TotalReports = sum(Count), .groups = "drop")
        
        # Reshape to wide format
        wide_data <- summary_data %>%
          pivot_wider(
            id_cols = Year,
            names_from = ReportType,
            values_from = Count,
            values_fill = 0
          ) %>%
          left_join(year_totals, by = "Year") %>%
          arrange(desc(Year))
        
        return(wide_data)
      })
      
      # Render the table
      output$report_table <- DT::renderDT({
        req(summarized_data())
        
        # Format the data for display
        display_data <- summarized_data()
        
        # Create formatted table
        datatable(
          display_data,
          options = list(
            pageLength = 10,
            searching = FALSE,
            dom = 't',
            ordering = FALSE
          ),
          rownames = FALSE,
          selection = "multiple",
          class = "data-table"
        ) %>%
          formatStyle(
            columns = colnames(display_data),
            backgroundColor = "#f8f9fa",
            borderBottom = "1px solid #ddd"
          ) %>%
          formatRound(
            columns = colnames(display_data)[-1],  # Exclude Year column
            digits = 0
          ) %>%
          formatCurrency(
            columns = colnames(display_data)[-1],  # Exclude Year column
            currency = "",
            mark = ",",
            digits = 0
          )
      })
      
      # Return selected years
      return(reactive({
        input$report_table_rows_selected
      }))
    }
  )
}
# Output function
reportTableOutput <- function(id) {
  ns <- NS(id)
  reportTableUI(id)
}
