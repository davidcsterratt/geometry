"matorder" <-
function (...)
{
    x = cbind(...)
    if(!is.numeric(x))
        stop("Input should by numeric.")
    do.call("order", lapply(1:ncol(x), function(i) x[, i]))
}
