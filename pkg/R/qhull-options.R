qhull.options <- function(options, output.options, supported_output.options, full=FALSE) {
  if (full) {
    if (!is.null(output.options)) {
      stop("full and output.options should not be specified together")
    }
    output.options = TRUE
    ## Enable message in 0.4.1
    ## Turn to warning in 0.4.2
    ## message("delaunayn: \"full\" option is deprecated; adding \"Fa\" and \"Fn\" to options")
  }
  
  if (is.null(output.options)) {
    output.options <- ""
  }
  if (is.logical(output.options)) {
    if (output.options) {
      output.options <- paste(supported_output.options, collapse=" ")
    } else {
      output.options  <- ""
    }    
  }
  if (!is.character(output.options)) {
    stop("output.options must be a string, logical or NULL")
  }
  
  ## Input sanitisation
  options <- paste(options, output.options, collapse=" ")
  return(options)
}
