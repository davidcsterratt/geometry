"mesh.hunif" <-
function (p, ...) 
{
    if (!is.matrix(p)) 
        stop("Input `p' should be matrix.")
    rep(1, nrow(p))
}
