##' Default is corners of a hypercube.
##' @title Generate various point distributions
##' @param D number of dimensions of hypercube
##' @param B bounding box coordinate - faces will be \code{-B} and \code{B} from origin
##' @return Matrix of points
##' @author David Sterratt
##' @export
rbox <- function(D=2, B=0.5) {
  return(as.matrix(do.call(expand.grid, rep(list(c(-B, B)), D))))
}
