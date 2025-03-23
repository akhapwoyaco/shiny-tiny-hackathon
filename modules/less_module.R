# UI Module
dataframeTextUI <- function(id) {
  ns <- NS(id)
  
  uiOutput(ns("textOutputs"))
}

# Server Module
dataframeTextServer <- function(id, df = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {
    
    # Create dynamic UI with all column headers and values
    output$textOutputs <- renderUI({
      #
      data <- df() 
      #print(data)
      column_names <- names(data)
      
      # Create a list to hold all the text outputs
      text_outputs <- lapply(column_names, function(col) {
        value <- data[[col]][1]
        
        # Format the value based on its type
        formatted_value <- if(is.numeric(value)) {
          format(value, big.mark = ",", scientific = FALSE)
        } else if(is.logical(value)) {
          ifelse(value, "Yes", "No")
        } else {
          as.character(value)
        }
        
        # Create a div containing header and value
        tags$div(
          class = "column-text-display",
          style = "margin-bottom: 15px;",
          tags$h4(col, style = "margin-bottom: 5px;"),
          tags$p(formatted_value)
        )
      })
      
      # Return div containing all text outputs
      do.call(tags$div, c(list(id = session$ns("all-columns"), 
                               style = "display: flex; flex-wrap: wrap; gap: 20px;"), 
                          lapply(text_outputs, function(x) {
                            tagAppendAttributes(x, style = "flex: 1; min-width: 150px;")
                          })))
    })
  })
}
#