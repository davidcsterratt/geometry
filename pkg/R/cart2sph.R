## Copyright (C) 2000, 2001, 2002, 2004, 2005, 2006, 2007, 2009, 2017 Kai Habel
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## This file has been adapted for R by David C Sterratt

##' If called with a single matrix argument then each row of \code{c} 
##' represents the Cartesian coordinate (\code{x}, \code{y}, \code{z}).
##' 
##' Transform Cartesian to spherical coordinates
##' @param x x-coordinates or matrix with three columns
##' @param y y-coordinates (optional, if \code{x}) is a matrix 
##' @param z z-coordinates (optional, if \code{x}) is a matrix 
##' @return Matrix with columns:
##' \item{\code{theta}}{the angle relative to the positive x-axis}
##' \item{\code{phi}}{the angle relative to the xy-plane}
##' \item{\code{r}}{the distance to the origin \code{(0, 0, 0)}}
##' @seealso \code{\link{sph2cart}}, \code{\link{cart2pol}},
##'   \code{\link{pol2cart}}
##' @author Kai Habel
##' @author David Sterratt
##' @export
cart2sph <- function(x, y=NULL, z=NULL) {
  if ((is.null(y) & !is.null(z)) |
      (is.null(z) & !is.null(y))) {
    stop("There should be 3 arguments (x, y, z) or one argument (x)")
  }

  if (is.null(y) & is.null(z)) {
    if (!(is.numeric(x))) {
      stop("input must be matrix with 3 columns [x, y, z]")
    }
    if (!(is.matrix(x) & ncol(x) == 3)) {
      stop("matrix input must have 3 columns [x, y, z]")
    }
    z <- x[,3]
    y <- x[,2]    
    x <- x[,1]    
  } else {
    if (!is.numeric(x) | !is.numeric(y) | !is.numeric (z))
      stop("x, y, z must be numeric arrays of the same size, or scalar")

    if ( !(((length(x) == length(y)) | (length(x) == 1) | (length(y) == 1)) &
           ((length(x) == length(z)) | (length(x) == 1) | (length(z) == 1)) &
           ((length(y) == length(z)) | (length(y) == 1) | (length(z) == 1)))) {
      stop("x, y, z must be matrices of the same size, or scalar")
    }
  }

  theta <- atan2(y, x)
  phi <- atan2(z, sqrt(x^2 + y^2))
  r <- sqrt(x^2 + y^2 + z^2)

  return(cbind(theta, phi, r))
}

