# Custom Logger Function
# Simple but effective logger with timestamps and log levels
custom_logger <- function(message, level = "INFO", log_to_console = TRUE) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- paste0("[", timestamp, "] [", level, "] ", message)
  
  # Always record to a global log variable for potential file writing
  if(!exists("log_history", envir = .GlobalEnv)) {
    assign("log_history", character(0), envir = .GlobalEnv)
  }
  
  log_history <- get("log_history", envir = .GlobalEnv)
  log_history <- c(log_history, log_entry)
  assign("log_history", log_history, envir = .GlobalEnv)
  
  # Optionally print to console
  if(log_to_console) {
    cat(log_entry, "\n")
  }
  
  # Return the log entry invisibly for potential further use
  invisible(log_entry)
}
