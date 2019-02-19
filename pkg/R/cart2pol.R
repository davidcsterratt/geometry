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

##' Transform Cartesian coordinates to polar or cylindrical coordinates.
##'
##' The inputs \code{x}, \code{y} (, and \code{z}) must be the same shape, or
##' scalar.  If called with a single matrix argument then each row of \code{C}
##' represents the Cartesian coordinate (\code{x}, \code{y} (, \code{z})).
##'
##' @param x x-coordinates or matrix with three columns
##' @param y y-coordinates (optional, if \code{x}) is a matrix 
##' @param z z-coordinates (optional, if \code{x}) is a matrix 
##' @return A matrix \code{P} where each row represents one
##'   polar/(cylindrical) coordinate (\code{theta}, \code{r}, (,
##'   \code{z})).
##' @seealso \code{\link{pol2cart}}, \code{\link{cart2sph}},
##'   \code{\link{sph2cart}}
##' @author Kai Habel
##' @author David Sterratt
##' @export
cart2pol <- function(x, y=NULL, z=NULL) {

  if (is.null(y) & is.null(z)) {
    if (!(is.numeric(x))) {
      stop("input must be matrix with 2 or 3 columns")
    }
    if (!(is.numeric (x) & is.matrix (x) 
      & (ncol(x) == 2 | ncol(x) == 3))) {
      stop("matrix input must have 2 or 3 columns [X, Y (, Z)]");
    }
    if (ncol(x) == 3) {
      z <- x[,3]
    }
    y <- x[,2]
    x <- x[,1]
  } else {
    if  (is.null(z)) {
      if (!is.numeric (x) | !is.numeric (y)) {
        stop("X, Y must be numeric arrays of the same size, or scalar")
      }
      if ( !((length(x) == length(y)) | (length(x) == 1) | (length(y) == 1))) {
        stop("X, Y must be numeric arrays of the same size, or scalar")
      }
    } else {
      if (! is.numeric (x) | ! is.numeric (y) | ! is.numeric (z)) {
        stop("X, Y, Z must be numeric arrays of the same size, or scalar")
      }
      if ( !(((length(x) == length(y)) | (length(x) == 1) | (length(y) == 1)) &
             ((length(x) == length(z)) | (length(x) == 1) | (length(z) == 1)) &
             ((length(y) == length(z)) | (length(y) == 1) | (length(z) == 1)))) {
        stop("x, y, z must be matrices of the same size, or scalar")
      }
    }
  }
  theta <- atan2 (y, x)
  r <- sqrt(x^2 + y^2)
  if (is.null(z)) {
    return(cbind(theta=theta, r=r))
  }
  return(cbind(theta=theta, r=r, z=z))
}
