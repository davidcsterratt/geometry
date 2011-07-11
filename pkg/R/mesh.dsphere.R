"mesh.dsphere" <-
function (p, radius = 1, ...) 
{
    if (!is.matrix(p)) 
        p = t(as.matrix(p))
    sqrt((p^2) %*% rep(1, ncol(p))) - radius
}
