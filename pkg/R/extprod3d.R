##' Compute external- or `cross'- product of 3D vectors.
##' 
##' Computes the external product \deqn{ }{ (x2 * y3 - x3 * y2, x3 * y1 - x1 *
##' y3, x1 * y2 - x2 * y1) }\deqn{ \left(x_2 y_3 - x_3 y_2,\; x_3 y_1 - x_1
##' y_3,\; x_1 y_2 - x_2 y_1 \right) }{ (x2 * y3 - x3 * y2, x3 * y1 - x1 * y3,
##' x1 * y2 - x2 * y1) }\deqn{ }{ (x2 * y3 - x3 * y2, x3 * y1 - x1 * y3, x1 *
##' y2 - x2 * y1) } of the 3D vectors in \bold{x} and \bold{y}.
##' 
##' 
##' @param x \code{n}-by-3 matrix. Each row is one \bold{x}-vector
##' @param y \code{n}-by-3 matrix. Each row is one \bold{y}-vector
##' @param drop logical. If \code{TRUE} and if the inputs are one row
##'   matrices or vectors, then delete the dimensions of the array
##'   returned.
##' @return If \code{n} is greater than 1 or \code{drop} is
##'   \code{FALSE}, \code{n}-by-3 matrix; if \code{n} is 1 and
##'   \code{drop} is \code{TRUE}, a vector of length 3.
##' @author Raoul Grasman
##' @keywords arith math array
##' @seealso \code{\link[base]{drop}}
##' @export
"extprod3d" <-
function (x, y, drop=TRUE) 
{
    x = matrix(x, ncol = 3)
    y = matrix(y, ncol = 3)
    z = cbind(x[, 2] * y[, 3] - x[, 3] * y[, 2], x[, 3] * y[, 
        1] - x[, 1] * y[, 3], x[, 1] * y[, 2] - x[, 2] * y[, 
                                                           1])
    if (drop) {
      return(drop(z))
    }
    return(z)
}
