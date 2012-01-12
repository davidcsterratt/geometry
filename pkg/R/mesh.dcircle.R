##' Special Distance Functions
##' 
##' Elementary distance functions, usefull for defining distance functions of
##' more complex regions.
##' 
##' \code{regionA} and \code{regionB} must accept a matrix \code{p} with 2
##' columns as their first argument, and must return a vector of length
##' \code{nrow(p)} containing the signed distances of the supplied points in
##' \code{p} to their respective regions.
##' 
##' @aliases mesh.dcircle mesh.drectangle mesh.diff mesh.union mesh.intersect
##' mesh.dsphere mesh.hunif
##' @param p A matrix with 2 columns (3 in \code{mesh.dsphere}), each row
##' representing a point in the plane.
##' @param radius radius of circle
##' @param x1 lower left corner of rectangle
##' @param y1 lower left corner of rectangle
##' @param x2 upper right corner of rectangle
##' @param y2 upper right corner of rectangle
##' @param regionA vectorized function describing region A in the union /
##' intersection / difference
##' @param regionB vectorized function describing region B in the union /
##' intersection / difference
##' @param \dots additional arguments passed to \code{regionA} and
##' \code{regionB}
##' @return a vector of length \code{nrow(p)} containing the signed distances
##' @author Raoul Grasman; translated from original Matlab sources of Per-Olof
##' Persson.
##' @seealso \code{\link{distmesh2d}}
##' @references \url{http://www-math.mit.edu/~persson/mesh/}
##' 
##' \cite{P.-O. Persson, G. Strang, A Simple Mesh Generator in MATLAB. SIAM
##' Review, Volume 46 (2), pp. 329-345, June 2004}
##' @keywords arith math
##' @examples
##' 
##' example(distmesh2d)
##' @export
##' @export mesh.dcircle mesh.drectangle mesh.diff mesh.union mesh.intersect
##' mesh.dsphere mesh.hunif
"mesh.dcircle" <-
function (p, radius = 1, ...)
{
    if (!is.matrix(p))
        p = t(as.matrix(p))
    sqrt((p^2) %*% c(1, 1))-radius
}
