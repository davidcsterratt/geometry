## Copyright (C) 2017 David Sterratt
## Copyright (C) 2000-2017 Kai Habel
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it){
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for (more details.){
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

##' Transform spherical coordinates to Cartesian coordinates
##'
##' The inputs \code{theta}, \code{phi}, and \code{r} must be the same
##' shape, or scalar.  If called with a single matrix argument then
##' each row of \code{S} represents the spherical coordinate
##' (\code{theta}, \code{phi}, \code{r}).
##'
##' @param theta describes the angle relative to the positive x-axis.
##' @param phi is the angle relative to the xy-plane.
##' @param r is the distance to the origin \code{(0, 0, 0)}.
##'
##' If only a single return argument is requested then return a matrix
##' \code{C} where each row represents one Cartesian coordinate
##' (\code{x}, \code{y}, \code{z}).
##' @seealso \code{\link{cart2sph}}, \code{\link{pol2cart}}, \code{\link{cart2pol}}
##' @author Kai Habel
##' @author David Sterratt
##' @export
sph2cart <- function(theta, phi=NULL, r=NULL) {
  if ((is.null(phi) & !is.null(r)) |
      (is.null(r) & !is.null(phi))) {
    stop("There should be 3 arguments (theta, phi, r) or one argument (theta)")
  }

  if (is.null(phi) & is.null(r)) {
    if (!(is.numeric(theta))) {
      stop("input must be matrix with 3 columns [theta, phi, r]")
    }
    if (!(is.matrix(theta) & (ncol(theta) == 3))) {
      stop("matrix input must have 3 columns [theta, phi, r]")
    }
    r <- theta[,3]
    phi <- theta[,2]
    theta <- theta[,1]
  } else {
    if (!is.numeric(theta) | !is.numeric(phi) | !is.numeric (r))
      stop("theta, phi, r must be numeric arrays of the same size, or scalar")

    if ( !(((length(theta) == length(phi)) | (length(theta) == 1) | (length(phi) == 1)) &
           ((length(theta) == length(r)) | (length(theta) == 1) | (length(r) == 1)) &
           ((length(phi) == length(r)) | (length(phi) == 1) | (length(r) == 1)))) {
      stop("theta, phi, r must be matrices of the same size, or scalar")
    }
  }

  x <- r*cos(phi)*cos(theta)
  y <- r*cos(phi)*sin(theta)
  z <- r*sin(phi)

  return(cbind(x, y, z))
}


