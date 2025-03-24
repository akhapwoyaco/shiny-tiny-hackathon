# modules/report_plot_module.R

# UI Function
reportPlotUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "panel panel-default",
      style = "padding: 15px; border: 1px solid #ddd; border-radius: 5px; margin-bottom: 15px;",
    plotlyOutput(ns("report_plot"), height = "600px"),
    tags$div(
      style = "margin-top: 10px;",
      actionButton(ns("resetSelection"), "Reset Selection", 
                   class = "btn-sm btn-info")
    )
    )
  )
}

# Server Function
reportPlotServer <- function(id, data, selected_categories = reactive(NULL), selected_columns = reactive(NULL)) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # Store the currently selected categories
      current_selections <- reactiveVal(NULL)
      
      # Observe external selection changes
      observeEvent(selected_categories(), {
        if (!is.null(selected_categories()) && length(selected_categories()) > 0) {
          current_selections(selected_categories())
        }
      })
      
      # Reset selection when button is clicked
      observeEvent(input$resetSelection, {
        current_selections(NULL)
        # send empty selection for clearing
        session$sendCustomMessage(type = 'resetTableFilter', message = TRUE)
      })
      
      #
      # Store the currently selected metric columns
      selected_metrics <- reactive({
        req(data())
        # Default to all metric columns except TotalRevenue and Region
        all_cols <- setdiff(colnames(data()), c("Year", "Total Reports"))
        
        # If column selection exists, use it
        if (!is.null(selected_columns()) && length(selected_columns()) > 0) {
          metric_cols <- intersect(selected_columns(), all_cols)
          if (length(metric_cols) > 0) {
            return(metric_cols)
          }
        }
        # print(all_cols)
        return(all_cols)
      })
      #
      # Create the plot
      summarized_data <- reactive({
        req(data())
        
        # Reshape to wide format
        wide_data <- data() |>
          tidyr::pivot_longer(
            cols = !Year,
            names_to = "ReportType",
            values_to = "Count"
          ) |>
          dplyr::filter(!grepl("^Total", ReportType))
        #
        return(wide_data)
      })
      #
      output$report_plot <- renderPlotly({
        req(summarized_data())
        
        # Prepare data for plotting
        plot_data <- summarized_data() |>
          select(Year, ReportType, Count) |>
          mutate(Year = as.numeric(Year)) |>
          arrange(Year, ReportType)
        
        # Create the plot
        p <- ggplot(plot_data, aes(x = Year, y = Count, fill = ReportType)) +
          geom_bar(stat = "identity", position = "stack") +
          scale_fill_brewer(palette = "Dark2") +
          labs(
               y = "Count",
               x = "") +
          theme_minimal() +
          theme(
            axis.title = element_blank(),
            axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "top",
            legend.title = element_blank(),
            plot.title = element_blank()
          )

        # Convert to plotly
        p = ggplotly(p, tooltip = c("x", "y", "fill")) |>
          layout(
            barmode = "stack",
            hovermode = "closest",
            showlegend = TRUE,
            margin = list(b = 100, l = 80, r = 40, t = 50),
            legend = list(orientation = "h", xanchor = "center", x = 0.5, y = -0.2)
          )
        #
        # Add custom JavaScript for interactivity
        p <- p |> onRender(paste0("
        function(el, x) {
          var graphDiv = el;
          var currentSelections = [];
          
          // Add click event listener
          el.on('plotly_click', function(data) {
            if (!data || !data.points || data.points.length === 0) return;
            
            var selectedCategory = data.points[0].x;
            
            
            // Get current selections from marker opacities
            var traces = graphDiv.data;
            if (traces[0].marker && traces[0].marker.opacity && Array.isArray(traces[0].marker.opacity)) {
              for (var j = 0; j < traces[0].x.length; j++) {
                if (traces[0].marker.opacity[j] === 1) {
                  currentSelections.push(traces[0].x[j]);
                }
              }
            } 
            
            // Toggle the selected category
            var index = currentSelections.indexOf(selectedCategory);
            if (index > -1) {
                currentSelections.splice(index, 1); // Remove if already selected
            } else {
                currentSelections.push(selectedCategory); // Add if not selected
            }
            
            // Reset on double click
            el.on('plotly_doubleclick', function() {
              Plotly.restyle(graphDiv, {'marker.opacity': 1});
              Shiny.setInputValue('", session$ns("bar_selection"), "', null);
            });
         
            // Update opacities based on selections
            var allOpacities = [];
            for (var i = 0; i < traces.length; i++) {
              var traceOpacities = [];
              for (var j = 0; j < traces[i].x.length; j++) {
                traceOpacities.push(currentSelections.includes(traces[i].x[j]) ? 1 : 0.3);
              }
              allOpacities.push(traceOpacities);
            }
            
            Plotly.restyle(graphDiv, {'marker.opacity': allOpacities});
            
            // Send selection to Shiny
            Shiny.setInputValue('", session$ns("bar_selection"), "', currentSelections);
          });
        }
      "))
        
        return(p)
      })
      # Return reactive list with selections
      return(list(
        selected_categories = reactive({
          if (!is.null(input$bar_selection)) {
            return(as.numeric(input$bar_selection))
          } else {
            return(NULL)
          }
          
        }),
        selected_metrics = selected_metrics
      ))
      #
    }
  )
}

