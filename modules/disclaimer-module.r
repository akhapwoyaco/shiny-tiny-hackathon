# modules/disclaimer_module.R

# UI Function
disclaimerUI <- function(id) {
  ns <- NS(id)
  
  modalDialog(
    title = "Disclaimer",
    div(id = ns("disclaimer-message"),
        p("Each year, the FDA receives over one million adverse event and medication error reports associated with the use of drug or biologic products. The FDA uses these reports to monitor the safety of drug and biological products. The FDA Adverse Event Reporting System (FAERS) database houses reports submitted to the FDA by drug manufacturers (who are required to submit these reports to FDA) and others such as health care professionals and consumers. Submission of a safety report does not constitute an admission that medical personnel, user facility, importer, distributor, manufacturer or product caused or contributed to the event."),
        p("Although these reports are a valuable source of information, this surveillance system has limitations, including the potential submission of incomplete, inaccurate, untimely and/or unverified information. In addition, the incidence or prevalence of an event cannot be determined from this reporting system alone due to potential under-reporting of events and lack of information about frequency of use. Because of this, FAERS data comprise only one part of the FDA's important post-market surveillance data and the information on this website does not confirm a causal relationship between the drug product and the reported adverse event(s)."),
        tags$ul(
          tags$li("Consumers should not stop or change medication without first consulting with a health care professional."),
          tags$li("The FAERS web search feature is limited to adverse event reports between 1969 and the most recent quarter for which data are available."),
          tags$li("Data submitted to the FAERS system will be made available through the new querying tool on a quarterly basis."),
          tags$li("FAERS data alone cannot be used to establish rates of events, evaluate a change in event rates over time or compare event rates between drug products. The number of reports cannot be interpreted or used in isolation to reach conclusions about the existence, severity, or frequency of problems associated with drug products."),
          tags$li("Confirming whether a drug product actually caused a specific event can be difficult based solely on information provided in a given report."),
          tags$li("FAERS data do not represent all known safety information for a reported drug product and should be interpreted in the context of other available information when making drug-related or treatment decisions."),
          tags$li("Variations in trade, product, and company names affect search results. Searches only retrieve records that contain the search term(s) provided by the requester.")
        ),
        p("Importantly, safety reports submitted to FDA do not necessarily reflect a conclusion by FDA that the information in the reports constitutes an admission that the drug caused or contributed to an adverse event. Individual FAERS reports for a given product can be requested by submitting a Freedom of Information Act (FOIA) request at:"),
        p(a(href = "https://www.fda.gov/regulatoryinformation/foi/howtomakeafoiarequest/default.htm", 
            "https://www.fda.gov/regulatoryinformation/foi/howtomakeafoiarequest/default.htm"))
    ),
    div(class = "disclaimer-footer",
        checkboxInput(ns("accept_check"), "I have read and understand the disclaimer."),
        fluidRow(
          column(6),
          column(3, actionButton(ns("do_not_accept_btn"), "Do Not Accept", class = "btn-default")),
          column(3, actionButton(ns("accept_btn"), "Accept", class = "btn-primary disabled"))
        )
    ),
    size = "l",
    easyClose = FALSE,
    footer = NULL
  )
}



# Server Function
disclaimerServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      
      log <- function(message, level = "INFO") {
        # Use our custom logger
        custom_logger(message, level)
        
        new_log <- paste0(format(Sys.time(), "%H:%M:%S"), " [", level, "] ", message, "\n")
      }
      
      #
      log(paste("disclaimerServer-", id, "Initialization"), "INFO")
      #
      # Track whether the disclaimer has been accepted
      disclaimer_status <- reactiveVal(FALSE)
      
      # Show modal when the app starts
      showModal(disclaimerUI(session$ns(NULL)))
      
      # Enable accept button when checkbox is checked
      observeEvent(input$accept_check, {
       
        if (input$accept_check){
          log(paste("disclaimerServer-", id, "Read Disclaimer Checkbox Checked"), "INFO")
          removeClass(selector = paste(paste("#",id, sep = ''), "accept_btn", sep = "-"), class = "disabled")
        } else {
          log(paste("disclaimerServer-", id, "Read Disclaimer Checkbox Unchecked"), "WARN")
          addClass(selector = paste(paste("#",id, sep = ''), "accept_btn", sep = "-"), class = "disabled")
        }
          
      })
      #
      # Handle accept button click
      observeEvent(input$accept_btn, {
        if (input$accept_check) {
          log(paste("disclaimerServer-", id, "Accept Disclaimer"), "SUCCESS")
          removeModal()
          disclaimer_status(TRUE)
        }
      })
      
      # Handle do not accept button click
      observeEvent(input$do_not_accept_btn, {
        removeModal()
        disclaimer_status(FALSE)
        log(paste("disclaimerServer-", id, "Read Disclaimer REMOVED"), "WARN")
        # Show a message that the user needs to accept the disclaimer
        showModal(modalDialog(
          title = "Action Required",
          "You must accept the disclaimer to view the dashboard data. Please click the Disclaimer menu to proceed.",
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
      })
      
      # Return the disclaimer acceptance status
      return(disclaimer_status)
    }
  )
}
# Output function
disclaimerOutput <- function(id) {
  ns <- NS(id)
  uiOutput(ns("disclaimer_ui"))
}
