# modules/report_table_module.R

# UI Function
reportTableUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      #style = "padding: 15px; border: 1px solid #ddd; border-radius: 5px; margin-bottom: 15px;",
      DT::DTOutput(ns("report_table"))
    )
  )
}

# Server Function
reportTableServer <- function(id,data, selected_categories = reactive(NULL)) {
  moduleServer(
    id,
    function(input, output, session) {
      #
      # Store selected table columns
      selected_cols <- reactiveVal(NULL)
      
      # Create aggregated data table
      summarized_data <- reactive({
        # print(selected_categories())
        if (!is.null(selected_categories()) && length(selected_categories()) > 0) {
          data() |>
            filter(Year %in% selected_categories())
        } else {
          data()
        }
      })
      #
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
            autoWidth = TRUE,
            columnDefs = list(
              list(className = 'dt-center dt-clickable', targets = "_all")
            ),
            drawCallback = JS("
            function(settings) {
              $(this).find('thead th').addClass('clickable-header').css('cursor', 'pointer');
            }
          ")
          ),
          selection = "none",
          rownames = FALSE,
          extensions = 'Buttons',
          class = "compact stripe hover",
          callback = JS("
          table.on('click', 'thead th', function() {
            var colIdx = table.column(this).index();
            Shiny.setInputValue('datatable_columns_selected', colIdx);
          });
        ")
        ) 
      })
      
      #
      # Handle column header clicks with custom JS
      observeEvent(input$dataTable_columns_selected, {
        cols <- input$dataTable_columns_selected
        if (length(cols) > 0) {
          col_names <- colnames(filtered_data())[cols]
          selected_cols(col_names)
        }
      })
      
      # Return selected columns
      return(reactive(selected_cols()))
      #
    }
  )
}




