##' Search for the enclosing Delaunay convex hull
##' 
##' For \code{t <- delaunay(cbind(x, y))}, where \code{(x, y)} is a 2D set of
##' points, \code{tsearch(x, y, t, xi, yi)} finds the index in \code{t}
##' containing the points \code{(xi, yi)}.  For points outside the convex hull
##' the index is \code{NA}.
##' 
##' @param x X-coordinates of triangulation points
##' @param y Y-coordinates of triangulation points
##' @param t Triangulation, e.g. produced by \code{t <-
##'   delaunayn(cbind(x, y))}
##' @param xi X-coordinates of points to test
##' @param yi Y-coordinates of points to test
##' @param bary If \code{TRUE} return barycentric coordinates as well
##'   as index of triangle.
##' @param method One of \code{"quadtree"} or \code{"orig"}. The
##'   Quadtree algorithm is much faster and new from version
##'   0.4.0. The \code{orig} option uses the tsearch algorithm adapted
##'   from Octave code. Its use is deprecated and it may be removed
##'   from a future version of the package.
##' @return If \code{bary} is \code{FALSE}, the index in \code{t} containing the points 
##' \code{(xi, yi)}.  For points outside the convex hull the index is \code{NA}. 
##' If \code{bary} is \code{TRUE}, a list containing: 
##'   \describe{
##'    \item{list("idx")}{the index in \code{t} containing the points \code{(xi, yi)}}
##'    \item{list("p")}{a 3-column matrix containing the barycentric coordinates with 
##'    respect to the enclosing triangle of each point \code{(xi, yi)}.}
##'   }
##' @author Jean-Romain Roussel (Quadtree algorithm), David Sterratt (Octave-based implementation)
##' @note The original Octave function is Copyright (C) 2007-2012
##'   David Bateman
##' @seealso \code{\link{tsearchn}}, \code{\link{delaunayn}}
##' @export
tsearch <- function(x, y, t, xi, yi, bary=FALSE, method="quadtree") {
  xtxt  = deparse(substitute(x))
  ytxt  = deparse(substitute(y))
  xitxt = deparse(substitute(xi))
  yitxt = deparse(substitute(yi))
  ttxt  = deparse(substitute(t))
  
  if (!is.vector(x))  {stop(paste(xtxt, "is not a vector"))}
  if (!is.vector(y))  {stop(paste(ytxt, "is not a vector"))}
  if (!is.matrix(t))  {stop(paste(ttxt, "is not a matrix"))}
  if (!is.vector(xi)) {stop(paste(xitxt, "is not a vector"))}
  if (!is.vector(yi)) {stop(paste(yitxt, "is not a vector"))}
  
  if (length(x) != length(y)) {
    stop(paste(xtxt, "is not same length as", ytxt))
  }
  if (length(xi) != length(yi)) {
    stop(paste(xitxt, "is not same length as", yitxt))
  }
  if (ncol(t) != 3) {
    stop(paste(ttxt, "does not have three columns"))
  }
  if (any(as.integer(t) != t)) {
    stop(paste(ttxt, "does not have integer elements"))
  }
  
  if (length(x) == 0) {stop(paste(xtxt, "is empty"))}
  if (length(y) == 0) {stop(paste(ytxt, "is empty"))}
  
  if (any(is.na(x)))   {stop(paste(xtxt, "contains NAs"))}
  if (any(is.na(y)))   {stop(paste(ytxt, "contains NAs"))}
  
  if (length(x) < 3 | length(y) < 3) {
    stop("A triangulation should have at least 3 points")
  }
  
  storage.mode(t) <- "integer"
  
  if (max(t) > length(x)) {
    stop(paste(ttxt, "has indexes greater than the number of points"))
  }
  
  if (min(t) <= 0) {
    stop(paste(ttxt, "has indexes which refer to non-existing points"))
  }

  if (length(xi) == 0 | length(yi) == 0) {
    if (!bary)
      return (integer(0))
    else
      return (list(idx = integer(0), p = matrix(0,0,3)))
  }
  
  if (method == "quadtree") {
    out <- C_tsearch(x, y, t, xi, yi, bary)
  } else {
    out <- .Call("C_tsearch_orig", x, y, t, xi, yi, bary, PACKAGE="geometry")
  }

  if (bary) {
    names(out) <- c("idx", "p")
  }
  return(out)
}

##' Search for the enclosing Delaunay convex hull
##' 
##' For \code{t = delaunayn(x)}, where \code{x} is a set of points in \eqn{N}
##' dimensions, \code{tsearchn(x, t, xi)} finds the index in \code{t}
##' containing the points \code{xi}. For points outside the convex hull,
##' \code{idx} is \code{NA}. \code{tsearchn} also returns the barycentric
##' coordinates \code{p} of the enclosing triangles.
##'
##' If \code{x} is \code{NA} and the \code{t} is a
##' \code{delaunayn} object produced by
##' \code{\link{delaunayn}} with the \code{full} option, then use the
##' Qhull library to perform the search. Please note that this is
##' experimental in geometry version 0.4.0 and is only partly tested
##' for 3D hulls, and does not yet work for hulls of 4 dimensions and
##' above.
##' 
##' @param x An \eqn{N}-column matrix, in which each row represents a
##'   point in \eqn{N}-dimensional space.
##' @param t A matrix with \eqn{N+1} columns. A row of \code{t}
##'   contains indices into \code{x} of the vertices of an
##'   \eqn{N}-dimensional simplex. \code{t} is usually the output of
##'   delaunayn.
##' @param xi An \eqn{M}-by-\eqn{N} matrix. The rows of \code{xi}
##'   represent \eqn{M} points in \eqn{N}-dimensional space whose
##'   positions in the mesh are being sought.
##' @param ... Additional arguments
##' @return A list containing:
##'   \describe{
##'     \item{\code{idx}}{An \eqn{M}-long vector containing the indices
##'       of the row of \code{t} in which each point in \code{xi} is found.}
##'    \item{\code{p}}{An \eqn{M}-by-\eqn{N+1} matrix containing the
##'     barycentric coordinates with respect to the enclosing simplex
##'     of each point in \code{xi}.}}
##' @author David Sterratt
##' @note Based on the Octave function Copyright (C) 2007-2012 David
##'   Bateman.
##' @seealso \code{\link{tsearch}}, \code{\link{delaunayn}}
##' @export
tsearchn <- function(x, t, xi, ...) {
  if (any(is.na(x)) && inherits(t, "delaunayn")) {
    return(tsearchn_delaunayn(t, xi))
  }
  fast <- TRUE
  if (!is.null(list(...)$fast) & is.logical(list(...)$fast))
    fast <- list(...)$fast

  ## Check input
  if (!is.matrix(x))  {stop(paste(deparse(substitute(x)), "is not a matrix"))}
  if (!is.matrix(t))  {stop(paste(deparse(substitute(t)), "is not a matrix"))}
  if (!is.matrix(xi)) {stop(paste(deparse(substitute(xi)), "is not a matrix"))}

  n <- dim(x)[2]                        # Number of dimensions
  if (n==2 && fast) {
    return(tsearch(x[,1], x[,2], t, xi[,1], xi[,2], bary=TRUE))
  }
  nt <- dim(t)[1]                       # Number of simplexes
  m <- dim(x)[1]                        # Number of points in simplex grid
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

  degenerate.simplices <- c()
  ## Go through each simplex in turn
  for (i in 1:nt) { 
    ## Only calculate the Barycentric coordinates for points that have not
    ## already been found in a simplex.
    b <- suppressWarnings(cart2bary(x[t[i,],], xi[ni,,drop=FALSE]))
    if (is.null(b)) {
      degenerate.simplices <- c(degenerate.simplices, i)
    } else {

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
  }
  if (length(degenerate.simplices) > 0) {
    warning(paste("Degenerate simplices:", toString(degenerate.simplices)))
  }
  return(list(idx=idx, p=p))
}

##' Conversion of Cartesian to Barycentric coordinates.
##' 
##' Given the Cartesian coordinates of one or more points, compute
##' the barycentric coordinates of these points with respect to a
##' simplex.
##' 
##' Given a reference simplex in \eqn{N} dimensions represented by a
##' \eqn{N+1}-by-\eqn{N} matrix an arbitrary point \eqn{P} in
##' Cartesian coordinates, represented by a 1-by-\eqn{N} row vector, can be
##' written as
##' \deqn{P = \beta X}
##' where \eqn{\beta} is an \eqn{N+1} vector of the barycentric coordinates.
##' A criterion on \eqn{\beta} is that
##' \deqn{\sum_i\beta_i = 1}
##' Now partition the simplex into its first \eqn{N} rows \eqn{X_N} and
##' its \eqn{N+1}th row \eqn{X_{N+1}}. Partition the barycentric
##' coordinates into the first \eqn{N} columns \eqn{\beta_N} and the
##' \eqn{N+1}th column \eqn{\beta_{N+1}}. This allows us to write
##' \deqn{P_{N+1} - X_{N+1} = \beta_N X_N + \beta_{N+1} X_{N+1} - X_{N+1}}
##' which can be written
##' \deqn{P_{N+1} - X_{N+1} = \beta_N(X_N - 1_N X_{N+1})}
##' where \eqn{1_N} is an \eqn{N}-by-1 matrix of ones.  We can then solve
##' for \eqn{\beta_N}:
##' \deqn{\beta_N = (P_{N+1} - X_{N+1})(X_N - 1_N X_{N+1})^{-1}}
##' and compute
##' \deqn{\beta_{N+1} = 1 - \sum_{i=1}^N\beta_i}
##' This can be generalised for multiple values of
##' \eqn{P}, one per row.
##' 
##' @param X Reference simplex in \eqn{N} dimensions represented by a
##' \eqn{N+1}-by-\eqn{N} matrix
##' @param P \eqn{M}-by-\eqn{N} matrix in which each row is the Cartesian
##' coordinates of a point.
##' @return \eqn{M}-by-\eqn{N+1} matrix in which each row is the
##' barycentric coordinates of corresponding row of \code{P}. If the
##' simplex is degenerate a warning is issued and the function returns
##' \code{NULL}.
##' @author David Sterratt
##' @note Based on the Octave function by David Bateman.
##' @examples
##' ## Define simplex in 2D (i.e. a triangle)
##' X <- rbind(c(0, 0),
##'            c(0, 1),
##'            c(1, 0))
##' ## Cartesian cooridinates of points
##' P <- rbind(c(0.5, 0.5),
##'            c(0.1, 0.8))
##' ## Plot triangle and points
##' trimesh(rbind(1:3), X)
##' text(X[,1], X[,2], 1:3) # Label vertices
##' points(P)
##' cart2bary(X, P)
##' @seealso \code{\link{bary2cart}}
##' @export
cart2bary <- function(X, P) {
  M <- nrow(P)
  N <- ncol(P)
  if (ncol(X) != N) {
    stop("Simplex X must have same number of columns as point matrix P")
  }
  if (nrow(X) != (N+1)) {
    stop("Simplex X must have N columns and N+1 rows")
  }
  X1 <- X[1:N,] - (matrix(1,N,1) %*% X[N+1,,drop=FALSE])
  if (rcond(X1) < .Machine$double.eps) {
    warning("Degenerate simplex")
    return(NULL)
  }
  Beta <- (P - matrix(X[N+1,], M, N, byrow=TRUE)) %*% solve(X1)
  Beta <- cbind(Beta, 1 - apply(Beta, 1, sum))
  return(Beta)
}

##' Conversion of Barycentric to Cartesian coordinates
##' 
##' Given the barycentric coordinates of one or more points with
##' respect to a simplex, compute the Cartesian coordinates of these
##' points.
##' 
##' @param X Reference simplex in \eqn{N} dimensions represented by a
##' \eqn{N+1}-by-\eqn{N} matrix
##' @param Beta \eqn{M} points in barycentric coordinates with
##' respect to the simplex \code{X} represented by a
##' \eqn{M}-by-\eqn{N+1} matrix
##' @return \eqn{M}-by-\eqn{N} matrix in which each row is the
##' Cartesian coordinates of corresponding row of \code{Beta}
##' @examples
##' ## Define simplex in 2D (i.e. a triangle)
##' X <- rbind(c(0, 0),
##'            c(0, 1),
##'            c(1, 0))
##' ## Cartesian cooridinates of points
##' beta <- rbind(c(0, 0.5, 0.5),
##'               c(0.1, 0.8, 0.1))
##' ## Plot triangle and points
##' trimesh(rbind(1:3), X)
##' text(X[,1], X[,2], 1:3) # Label vertices
##' P <- bary2cart(X, beta)
##' points(P)
##' @seealso \code{\link{cart2bary}}
##' @author David Sterratt
##' @export
bary2cart <- function(X, Beta) {
  return(Beta %*% X)
}

tsearchn_delaunayn <- function(t, xi) {
  warning("tsearchn using the Qhull library is currently an experimental feature. It has been tested somewhat for 3D triangulations, but it does not work reliably for 4D triangulations. See https://github.com/davidcsterratt/geometry/issues/6")
  ts <- .Call("C_tsearchn", t, xi)
  p <- do.call(rbind,
               lapply(1:nrow(xi), function(i) {
                 cart2bary(ts$P[t$tri[ts$idx[i],],], xi[i,,drop=FALSE])
               }))
  ## C_tsearchn will return the *best* facet. Need to check it is
  ## actually in the triangulation
  outwith_facet_inds <- which(apply(p < 0, 1, any))
  idx <- ts$idx
  idx[outwith_facet_inds] <- NA
  p[outwith_facet_inds,] <- NA
  return(list(idx=idx, p=p, P=ts$P))
}
