##' Distance of point from a convex hull
##'
##' Compute the perpendicular distance of a set of points from a
##' convex hull and the points on the hull at which perpendicular
##' lines from the point intersect the hull.
##' 
##' @param ch Convex hull produced using \code{\link{convhulln}}
##' @param p An \eqn{M}-by-\eqn{N} matrix of points. The rows
##'   of \code{p} represent \eqn{M} points in \eqn{N}-dimensional
##'   space.
##' @return A list comprising the following elements:
##'    \describe{
##'     \item{\code{distances}}{Vector \eqn{M} perpendicular distances
##'       of each point from the closest hyperplane. The sign is positive
##'       if the point is outside the hull and negative if it is inside
##'       the hull.}
##'     \item{\code{intersections}{p An \eqn{M}-by-\eqn{N} matrix of
##'        intersection points. The rows of \code{p} represent \eqn{M} points
##'        in \eqn{N}-dimensional space.}}
##' 
##' @author David Sterratt
##' @note \code{disthulln} was introduced in geometry 0.4.5, and is
##'   still under development. It is worth checking results for
##'   unexpected behaviour.
##' @seealso \code{\link{convhulln}}
##' @export
##' @examples
##' 
##' ch <- convhulln(cbind(c(-1, -1, 1), c(-1, 1, -1)), "FA")
##' ##' ## First point should be in the hull; last two outside
##' p <- rbind(c(-0.5, -0.5),
##'            c( 1  ,  1),
##'            c(10  ,  -1))
##' dh <- disthulln(ch, p)
##' plot(ch, xlim=c(-1, 10), ylim=c(-1, 10))
##' points(p)
##' points(dh$intersections, col="red")
##'
##' ## Test hypercube
##' p <- rbox(D=4, B=1)
##' ch <- convhulln(p)
##' tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0, 0)
##' pin <- inhulln(ch, tp)
##' ## Points on x-axis should be in box only betw,een -1 and 1
##' pin == (tp[,1] < 1 & tp[,1] > -1)
disthulln <- function(ch, p) {
  return(.Call("C_inhulln", ch, p, PACKAGE="geometry"))
}
 
