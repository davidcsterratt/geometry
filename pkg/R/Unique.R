"Unique" <-
function (X, rows.are.sets = FALSE) 
{
    if (rows.are.sets) 
        X = matsort(X)
    X = X[matorder(X), ]
    dX = apply(X, 2, diff)
    uniq = c(TRUE, ((dX^2) %*% rep(1, ncol(dX))) > 0)
    X = X[uniq, ]
    return(X)
}
