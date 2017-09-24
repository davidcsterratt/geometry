##' Default is corners of a hypercube.
##' @title Generate various point distributions
##' @param n number of random points in hypercube
##' @param D number of dimensions of hypercube
##' @param B bounding box coordinate - faces will be \code{-B} and \code{B} from origin
##' @param C add a unit hypercube to the output - faces will be \code{-C} and \code{C} from origin
##' @return Matrix of points
##' @author David Sterratt
##' @export
rbox <- function(n=3000, D=3, B=0.5, C=NA) {
  P <- matrix(0, 0, D)
  if (!is.na(C)) {
    P <- rbind(P, 
               as.matrix(do.call(expand.grid, rep(list(c(-C, C)), D))))
  }
  if (n > 0) {
    P <- rbind(P, 
               matrix(stats::runif(n=n*D, min=-B, max=B), n, D))
  }
  return(P)
}
