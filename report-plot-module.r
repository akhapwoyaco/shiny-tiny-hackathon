# modules/report_plot_module.R

# UI Function
reportPlotUI <- function(id) {
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("report_plot"), height = "600px")
  )
}


# Server Function
reportPlotServer <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      # Create the plot
      output$report_plot <- renderPlotly({
        req(data())
        
        # Prepare data for plotting
        plot_data <- data() %>%
          select(Year, ReportType, Count) %>%
          filter(ReportType %in% c("Expedited", "Non-Expedited", "Direct", "BSR")) %>%
          mutate(Year = as.factor(Year)) %>%
          arrange(Year, ReportType)
        
        # Create color mapping
        color_mapping <- c(
          "Expedited" = "#d9534f",
          "Non-Expedited" = "#5cb85c",
          "Direct" = "#5bc0de",
          "BSR" = "#f0ad4e"
        )
        
        # Create the plot
        p <- ggplot(plot_data, aes(x = Year, y = Count, fill = ReportType)) +
          geom_bar(stat = "identity", position = "stack") +
          scale_fill_manual(values = color_mapping) +
          labs(title = "Reports received by Report Type",
               y = "Report Count",
               x = "") +
          theme_minimal() +
          theme(
            axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "top",
            plot.title = element_text(hjust = 0.5)
          )
        
        # Convert to plotly
        ggplotly(p, tooltip = c("x", "y", "fill")) %>%
          layout(
            hovermode = "closest",
            margin = list(b = 100, l = 80, r = 40, t = 50),
            legend = list(orientation = "h", y = 1.1)
          )
      })
    }
  )
}
# Output function
reportPlotOutput <- function(id) {
  ns <- NS(id)
  reportPlotUI(id)
}
