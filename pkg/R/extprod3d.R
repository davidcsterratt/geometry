"extprod3d" <-
function (x, y) 
{
    x = matrix(x, ncol = 3)
    y = matrix(y, ncol = 3)
    drop(cbind(x[, 2] * y[, 3] - x[, 3] * y[, 2], x[, 3] * y[, 
        1] - x[, 1] * y[, 3], x[, 1] * y[, 2] - x[, 2] * y[, 
        1]))
}
