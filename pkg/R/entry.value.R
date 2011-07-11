"entry.value" <-
function (a, idx) 
{
    if (!is.array(a)) 
        stop(paste("First argument `", deparse(substitute(a)), 
            "' should be an array.", sep = ""))
    if (!is.matrix(idx)) 
        stop(paste("Second argument `", substitute(idx), "' should be a matrix.", 
            sep = ""))
    n <- length(dim(a))
    if (n != ncol(idx)) 
        stop(paste("Number of columns in", deparse(substitute(idx)), 
            "is incompatible is dimension of", deparse(substitute(a))))
    a[(idx - 1) %*% c(1, cumprod(dim(a))[-n]) + 1]
}
"entry.value<-" <-
function (a, idx, value) 
{
    if (!is.array(a)) 
        stop(paste("First argument `", deparse(substitute(a)), 
            "' should be an array.", sep = ""))
    if (!is.matrix(idx)) 
        stop(paste("Second argument `", substitute(idx), "' should be a matrix.", 
            sep = ""))
    n <- length(dim(a))
    if (n != ncol(idx)) 
        stop(paste("Number of columns in", deparse(substitute(idx)), 
            "is incompatible is dimension of", deparse(substitute(a))))
    a[(idx - 1) %*% c(1, cumprod(dim(a))[-n]) + 1] <- value
    return(a)
}

