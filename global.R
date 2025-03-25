#' @description Custom Logger Function
# Simple but effective logger with timestamps and log levels
#' @param message Logged Message
#' @param level Logging level (DEBUG, INFO, WARN, ERROR, SUCCESS)
#' @param log_to_console Whether to log to console
#' @param log_to_file Whether to log to file
#' @param log_file Path to log file (default: logs/{logs}.log)
#' 
custom_logger <- function(
    message, level = "INFO", log_to_console = TRUE, 
    log_to_file = FALSE, log_file = NULL) {
  #'
  #' Check if a message at this level should be logged
  levels <- c("DEBUG", "INFO", "WARN", "ERROR", "SUCCESS")
  level_idx <- match(toupper(level), levels)
  check_idx <- match(toupper(level), levels)
  # ensure level is in list of levels otherwise stop the logging function
  should_log = check_idx >= level_idx
  # print(should_log)
  stopifnot("USE PROPER LOGGING LEVELS" = should_log)
  #
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  # log entry
  log_entry <- sprintf("[%s] [%s] %s", timestamp, level, message)
  
  # Always record to a global log variable for potential file writing
  if(!exists("log_history", envir = .GlobalEnv)) {
    assign("log_history", character(0), envir = .GlobalEnv)
  }
  #
  log_history <- get("log_history", envir = .GlobalEnv)
  log_history <- c(log_history, log_entry)
  assign("log_history", log_history, envir = .GlobalEnv)
  
  # Setup log file if needed
  if (log_to_file) {
    if (is.null(log_file)) {
      # Create logs directory if it doesn't exist
      if (!dir.exists("logs")) {
        dir.create("logs", recursive = TRUE)
      }
      log_file <- file.path("logs", paste0("logs", ".log"))
    } else {
      log_file <- log_file
    }
    
    # Initialize log file with header
    cat(paste("# Log file Created on", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n"),
        file = log_file)
  }
  
  # Optionally print to console
  if(log_to_console) {
    # cat(log_entry, "\n")
    if (level == "ERROR") {
      cat(crayon::red(log_entry), "\n")
    } else if (level == "WARN") {
      cat(crayon::yellow(log_entry), "\n")
    } else if (level == "INFO") {
      cat(crayon::blue(log_entry), "\n")
    } else if (level == "SUCCESS") {
      cat(crayon::green(log_entry), "\n")
    } else {
      cat(log_entry, "\n")
    }
  }
  
  # Return the log entry invisibly for potential further use
  invisible(log_entry)
}


