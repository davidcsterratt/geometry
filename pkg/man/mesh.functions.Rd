\name{mesh.functions}
\alias{mesh.dcircle}
\alias{mesh.drectangle}
\alias{mesh.diff}
\alias{mesh.union}
\alias{mesh.intersect}
\alias{mesh.dsphere}
\alias{mesh.hunif}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Special Distance Functions }
\description{
  Elementary distance functions, usefull for defining distance functions
  of more complex regions.
}
\usage{
mesh.dcircle(p, radius = 1, ...)
mesh.dsphere(p, radius = 1, ...)
%}
%\usage{
mesh.drectangle(p, x1 = -1/2, y1 = -1/2, x2 = 1/2, y2 = 1/2, ...)
%}
%\usage{
mesh.diff(p, regionA, regionB, ...)
%}
%\usage{
mesh.intersect(p, regionA, regionB, ...)
%}
%\usage{
mesh.union(p, regionA, regionB, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{p}{ A matrix with 2 columns (3 in \code{mesh.dsphere}), each row representing a point in the plane. }
  \item{radius}{ radius of circle }
  \item{x1}{ lower left corner of rectangle }
  \item{y1}{ lower left corner of rectangle }
  \item{x2}{ upper right corner of rectangle }
  \item{y2}{ upper right corner of rectangle }
  \item{regionA}{ vectorized function describing region A in the union / intersection / difference }
  \item{regionB}{ vectorized function describing region B in the union / intersection / difference }
  \item{\dots}{ additional arguments passed to \code{regionA} and \code{regionB} }

}
\details{
  \code{regionA} and \code{regionB} must accept a matrix \code{p} with 2 columns as
  their first argument, and must return a vector of length \code{nrow(p)} containing
  the signed distances of the supplied points in \code{p} to their respective regions.
}
\value{
  a vector of length \code{nrow(p)} containing the signed distances
}

\references{
\url{http://www-math.mit.edu/~persson/mesh/}

\cite{P.-O. Persson, G. Strang, A Simple Mesh Generator in MATLAB.
SIAM Review, Volume 46 (2), pp. 329-345, June 2004}
 }
\author{ Raoul Grasman; translated from original Matlab sources of Per-Olof Persson. }


\seealso{ \code{\link{distmesh2d}} }
\examples{
example(distmesh2d)
}
\keyword{ arith }% at least one, from doc/KEYWORDS
\keyword{ math }% __ONLY ONE__ keyword per line
