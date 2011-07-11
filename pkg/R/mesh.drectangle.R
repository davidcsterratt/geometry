"mesh.drectangle" <-
function (p, x1 = -1/2, y1 = -1/2, x2 = 1/2, y2 = 1/2, ...) 
{
    if (!is.matrix(p)) 
        p = t(as.matrix(p))
    d1 = y1 - p[, 2]
    d2 = -y2 + p[, 2]
    d3 = x1 - p[, 1]
    d4 = -x2 + p[, 1]
    d5 = sqrt(d1^2 + d3^2)
    d6 = sqrt(d1^2 + d4^2)
    d7 = sqrt(d2^2 + d3^2)
    d8 = sqrt(d2^2 + d4^2)
    matmin = function(...) apply(cbind(...), 1, min)
    d = -matmin(matmin(matmin(-d1, -d2), -d3), -d4)
    ix = d1 > 0 & d3 > 0
    d[ix] = d5[ix]
    ix = d1 > 0 & d4 > 0
    d[ix] = d6[ix]
    ix = d2 > 0 & d3 > 0
    d[ix] = d7[ix]
    ix = d2 > 0 & d4 > 0
    d[ix] = d8[ix]
    d
}
