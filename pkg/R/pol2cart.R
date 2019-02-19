## Copyright (C) 2000-2017 Kai Habel
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## This file has been adapted for R by David C Sterratt

##' Transform polar or cylindrical coordinates to Cartesian coordinates.
##'
##' The inputs \code{theta}, \code{r}, (and \code{z}) must be the same shape, or
##' scalar.  If called with a single matrix argument then each row of \code{P}
##' represents the polar/(cylindrical) coordinate (\code{theta}, \code{r}
##' (, \code{z})).
##'
##' @param theta describes the angle relative to the positive x-axis.
##' @param r is the distance to the z-axis (0, 0, z).
##' @param z (optional) is the z-coordinate
##' @return a matrix \code{C} where each row represents one Cartesian
##'   coordinate (\code{x}, \code{y} (, \code{z})).
##' @seealso \code{\link{cart2pol}}, \code{\link{sph2cart}},
##'   \code{\link{cart2sph}}
##' @author Kai Habel
##' @author David Sterratt
##' @export
pol2cart <- function(theta, r=NULL, z=NULL) {

  if (is.null(r) & is.null(z)) {
    if (!(is.numeric(theta))) {
      stop("input must be matrix with 2 or 3 columns")
    }
    if (!(is.numeric (theta) & is.matrix (theta) 
      & (ncol(theta) == 2 | ncol(theta) == 3))) {
      stop("matrix input must have 2 or 3 columns [THETA, R (, Z)]");
    }
    if (ncol(theta) == 3) {
      z <- theta[,3]
    }
    r <- theta[,2]
    theta <- theta[,1]
  } else {
    if  (is.null(z)) {
      if (!is.numeric (theta) | !is.numeric (r)) {
        stop("THETA, R must be numeric arrays of the same size, or scalar")
      }
      if ( !((length(theta) == length(r)) | (length(theta) == 1) | (length(r) == 1))) {
        stop("THETA, Y must be numeric arrays of the same size, or scalar")
      }
    } else {
      if (! is.numeric (theta) | ! is.numeric (r) | ! is.numeric (z)) {
        stop("THETA, R, Z must be numeric arrays of the same size, or scalar")
      }
      if ( !(((length(theta) == length(r)) | (length(theta) == 1) | (length(r) == 1)) &
             ((length(theta) == length(z)) | (length(theta) == 1) | (length(z) == 1)) &
             ((length(r) == length(z)) | (length(r) == 1) | (length(z) == 1)))) {
        stop("theta, r, z must be matrices of the same size, or scalar")
      }
    }
  }

  x <- r*cos(theta)
  y <- r*sin(theta)
  if (is.null(z)) {
    return(cbind(x=x, y=y))
  }
  return(cbind(x=x, y=y, z=z))
}
         
