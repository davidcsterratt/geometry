"mesh.dcircle" <-
function (p, radius = 1, ...)
{
    if (!is.matrix(p))
        p = t(as.matrix(p))
    sqrt((p^2) %*% c(1, 1))-radius
}
