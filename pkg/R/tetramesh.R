"tetramesh" <-
function (T, X, col = heat.colors(nrow(T)), clear = TRUE, ...)
{
    if(require(rgl) == FALSE)
        stop("the rgl package is required for tetramesh")
    if (!is.numeric(T) | !is.numeric(T))
        stop("`T' and `X' should both be numeric.")
    if (ncol(T) != 4)
        stop("Expect first arg `T' to have 4 columns.")
    if (ncol(X) != 3)
        stop("Expect second arg `X' to have 3 columns.")
    t = t(rbind(T[, -1], T[, -2], T[, -3], T[, -4]))
    if (clear)
        rgl.clear()
    rgl.triangles(X[t, 1], X[t, 2], X[t, 3], col = col, ...)
}
