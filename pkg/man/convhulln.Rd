\name{convhulln}
\alias{convhulln}
\title{Compute smallest convex hull that encloses a set of points

Returns an index matrix to the points of simplices
(\dQuote{triangles}) that form the smallest convex simplicial
complex of a set of input points in N-dimensional space. This
function interfaces the Qhull library.

For slient operation, specify the option \code{Pp}.}
\usage{
  convhulln(p, options = "Tv")
}
\arguments{
  \item{p}{An \code{n}-by-\code{dim} matrix.  The rows of
  \code{p} represent \code{n} points in
  \code{dim}-dimensional space.}

  \item{options}{String containing extra options for the
  underlying Qhull command; see details below and Qhull
  documentation at
  \url{http://www.qhull.org/html/qconvex.htm#synopsis}.}
}
\value{
  An \code{m}-by-\code{dim} index matrix of which each row
  defines a \code{dim}-dimensional \dQuote{triangle}. The
  indices refer to the rows in \code{p}.  If the option
  \code{FA} is provided, then the output is a \code{list}
  with entries \code{$hull} containing the matrix mentioned
  above, and \code{$area} and \code{$vol} with the area and
  volume of the hull described by the matrix.
}
\description{
  Compute smallest convex hull that encloses a set of
  points

  Returns an index matrix to the points of simplices
  (\dQuote{triangles}) that form the smallest convex
  simplicial complex of a set of input points in
  N-dimensional space. This function interfaces the Qhull
  library.

  For slient operation, specify the option \code{Pp}.
}
\note{
  This is a port of the Octave's
  (\url{http://www.octave.org}) geometry library. The
  Octave source was written by Kai Habel.

  See further notes in \code{\link{delaunayn}}.
}
\examples{
# example convhulln
# ==> see also surf.tri to avoid unwanted messages printed to the console by qhull
ps <- matrix(rnorm(3000), ncol=3)  # generate points on a sphere
ps <- sqrt(3)*ps/drop(sqrt((ps^2) \%*\% rep(1, 3)))
ts.surf <- t(convhulln(ps, "QJ"))  # see the qhull documentations for the options
\dontrun{
rgl.triangles(ps[ts.surf,1],ps[ts.surf,2],ps[ts.surf,3],col="blue",alpha=.2)
for(i in 1:(8*360)) rgl.viewpoint(i/8)
}
}
\author{
  Raoul Grasman, Robert B. Gramacy and David Sterratt
  \email{david.c.sterratt@ed.ac.uk}
}
\references{
  \cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T.,
  \dQuote{The Quickhull algorithm for convex hulls,}
  \emph{ACM Trans. on Mathematical Software,} Dec 1996.}

  \url{http://www.qhull.org}
}
\seealso{
  \code{\link[tripack]{convex.hull}},
  \code{\link{delaunayn}}, \code{\link{surf.tri}},
  \code{\link{distmesh2d}}
}
\keyword{dplot}
\keyword{graphs}
\keyword{math}

