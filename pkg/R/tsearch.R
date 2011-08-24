## Copyright (C) 2007 David Bateman
## Copyright (C) 2011 David Sterratt

## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 3 of the License, or (at your
## option) any later version.

## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.

## You should have received a copy of the GNU General Public License
## along with this program. If not, see
## <http://www.gnu.org/licenses/>.

##' For \code{t = delaunay(p)}, where \code{p} is a 2D set of points,
##' \code{tsearch(p[,1], p[,2], t, xi, yi)} finds the index in \code{t}
##' containing the points \code{(xi, yi)}.  For points outside the
##' convex hull the index is \code{NA}.
##'
##' @title Search for the enclosing Delaunay convex hull
##' @param x X-coordinates of triangluation points
##' @param y Y-coordinates of triangluation points
##' @param t Triangulation, e.g. produced by \code{t = delaunay(x, y)}
##' @param xi X-coordinates of points to test
##' @param yi Y-coordinates of points to test
##' @return The index in \code{t} containing the points \code{(xi,
##' yi)}.  For points outside the convex hull the index is \code{NA}.
##' @author David Sterratt
tsearch <- function(x, y, t, xi, yi) {
  if (!is.vector(x))  {stop(paste(deparse(substitute(x)), "is not a vector"))}
  if (!is.vector(y))  {stop(paste(deparse(substitute(y)), "is not a vector"))}
  if (!is.matrix(t))  {stop(paste(deparse(substitute(t)), "is not a matrix"))}
  if (!is.vector(xi))  {stop(paste(deparse(substitute(xi)), "is not a vector"))}
  if (!is.vector(yi))  {stop(paste(deparse(substitute(yi)), "is not a vector"))}
  if (length(x) != length(y)) {
    stop(paste(deparse(substitute(x)), "is not same length as ", deparse(substitute(y))))
  }
  if (length(xi) != length(yi)) {
    stop(paste(deparse(substitute(xi)), "is not same length as ", deparse(substitute(yi))))
  }
  if (ncol(t) != 3) {
    stop(paste(deparse(substitute(t)), "does not have three columns"))
  }
  if (!is.integer(t)) {
    stop(paste(deparse(substitute(t)), "is not an integer"))
  }
  out <- .Call("tsearch", as.double(x), as.double(y), t,
               as.double(xi), as.double(yi))
  return(out)
}

##' For \code{t = delaunayn (x)}, finds the index in \code{t}
##' containing the points \code{xi}. For points outside the convex
##' hull, \code{idx} is \code{NA}. \code{tsearchn} also returns the
##' barycentric coordinates \code{p} of the enclosing triangles.
##'
##' @title Search for the enclosing Delaunay convex hull
##' @param x An \code{n}-by-\code{dim} matrix.  The rows of \code{x}
##' represent \code{n} points in \code{dim}-dimensional space. 
##' @param t A \code{m}-by-\code{dim+1} matrix. A row of \code{t}
##' contains indices into \code{x} of the vertices of a
##' \code{dim}-dimensional simplex. \code{t} is usually the output of
##' delaunayn.
##' @param xi An \code{ni}-by-\code{dim} matrix.  The rows of
##' \code{xi} represent \code{n} points in \code{dim}-dimensional
##' space whose positions in the mesh are being sought.
##' @return A list containing:
##' \item{\code{idx}}{An \code{ni}-long
##' vector containing the indicies  of the row of \code{t} in which
##' each point in \code{xi} is found.}
##' \item{\code{p}}{An \code{ni}-by-\code{dim+1} matrix
##'  containing the barycentric coordinates with respect to the enclosing simplex of 
##' each point in \code{xi}.}
##' @seealso delaunayn
##' @author David Sterratt
tsearchn <- function(x, t, xi) {
  ## Check input
  if (!is.matrix(x))  {stop(paste(deparse(substitute(x)), "is not a matrix"))}
  if (!is.matrix(t))  {stop(paste(deparse(substitute(t)), "is not a matrix"))}
  if (!is.matrix(xi)) {stop(paste(deparse(substitute(xi)), "is not a matrix"))}

  nt <- dim(t)[1]                       # Number of simplexes
  m <- dim(x)[1]                        # Number of points in simplex grid
  n <- dim(x)[2]                        # Number of dimensions
  mi <- dim(xi)[1]                      # Number of points to search for
  ## If there are no points to search for, return an empty index
  ## vector and an empty coordinate matrix
  if (mi==0) {
    return(list(idx=c(), p=matrix(0, 0, n + 1)))
  }
  idx <- rep(NA, mi)
  p <- matrix(NA, mi, n + 1)

  ## Indicies of points that still need to be searched for
  ni <- 1:mi

  ## Go through each simplex in turn
  for (i in 1:nt) { 
    ## Only calculate the Barycentric coordinates for points that have not
    ## already been found in a simplex.
    b <- cart2bary(x[t[i,],], xi[ni,,drop=FALSE]);

    ## Our points xi are in the current triangle if (all(b >= 0) &&
    ## all (b <= 1)). However as we impose that sum(b,2) == 1 we only
    ## need to test all(b>=0). Note that we need to add a small margin
    ## for rounding errors
    intri <- apply(b >= -1e-12, 1, all)

    ## Set the simplex indicies  of the points that have been found to
    ## this simplex
    idx[ni[intri]] <- i

    ## Set the baryocentric coordinates of the points that have been found
    p[ni[intri],] <- b[intri,]

    ## Remove these points from the search list
    ni <- ni[!intri]

    ## If there are no more points to search for, give up
    if (length(ni) == 0) { break }
  }
  return(list(idx=idx, p=p))
}

cart2bary <- function(T, P) {
  ## Conversion of Cartesian to Barycentric coordinates.
  ## Given a reference simplex in N dimensions represented by a
  ## (N+1)-by-(N) matrix, and arbitrary point P in cartesion coordinates,
  ## represented by a N-by-1 row vector can be written as
  ##
  ## P = Beta * T
  ##
  ## Where Beta is a N+1 vector of the barycentric coordinates. A criteria
  ## on Beta is that
  ##
  ## sum (Beta) == 1
  ##
  ## and therefore we can write the above as
  ##
  ## P - T(end, :) = Beta(1:end-1) * (T(1:end-1,:) - ones(N,1) * T(end,:))
  ##
  ## and then we can solve for Beta as
  ##
  ## Beta(1:end-1) = (P - T(end,:)) / (T(1:end-1,:) - ones(N,1) * T(end,:))
  ## Beta(end) = sum(Beta)
  ##
  ## Note below is generalize for multiple values of P, one per row.
  M <- dim(P)[1]
  N <- dim(P)[2]
  ## 
  Beta <- (P - matrix(T[N+1,], M, N, byrow=TRUE)) %*% solve(T[1:N,] - matrix(1,N,1) %*% T[N+1,,drop=FALSE])
  Beta <- cbind(Beta, 1 - apply(Beta, 1, sum))
  return(Beta)
}

bary2cart <- function(T, Beta) {
  ## Conversion of Barycentric to Cartesian coordinates.
  ## Given a reference simplex T in N dimensions represented by a
  ## (N+1)-by-(N) matrix, and arbitrary point Beta in baryocentric coordinates,
  ## represented by a N+1-by-1 row vector, the cartesian coordinates P are
  ## given
  ##
  ## P = Beta * T
  return(Beta %*% T)
}
