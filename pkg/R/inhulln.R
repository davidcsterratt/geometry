##' Test if points lie in convex hull
##'
##' Tests if a set of points lies within a convex hull, returning a
##' boolean vector in which each element is \code{TRUE} if the
##' corresponding point lies within the hull and \code{FALSE} if it
##' lies outwith the hull or on one of its facets.
##' 
##' @param ch Convex hull produced using \code{\link{convhulln}}
##' @param p An \eqn{M}-by-\eqn{N} matrix of points to test.
##' The rows of \code{p} represent \eqn{M} points in \eqn{N}-dimensional space.
##' @return A boolean vector with \eqn{M} elements
##' @author David Sterratt
##' @seealso convhulln
##' @export
##' @examples
##' p <- cbind(c(-1, -1, 1), c(-1, 1, -1))
##' ch <- convhulln(p)
##' ## First point should be in the hull; last two outside
##' inhulln(ch, rbind(c(-0.5, -0.5),
##'                   c( 1  ,  1),
##'                   c(10  ,  0)))
##'
##' ## Test hypercube
##' p <- rbox(4, B=1)
##' ch <- convhulln(p)
##' tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0, 0)
##' pin <- inhulln(ch, tp)
##' ## Points on x-axis should be in box only between -1 and 1
##' pin == (tp[,1] < 1 & tp[,1] > -1)
inhulln <- function(ch, p) {
  return(.Call("C_inhulln", ch, p, PACKAGE="geometry"))
}
