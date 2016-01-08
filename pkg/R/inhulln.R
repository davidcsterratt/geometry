##' @title Test if points lie in convex hull
##' @param ch Convex hull produced using \code{\link{convhulln}}
##' @param p An \code{n}-by-\code{dim} matrix of points to test.  The rows of \code{p} represent
##' \code{n} points in \code{dim}-dimensional space.
##' @return A booean vector with \code{n} elements
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
inhulln <- function(ch, p) {
  return(.Call("inhulln", ch, p, PACKAGE="geometry"))
}
