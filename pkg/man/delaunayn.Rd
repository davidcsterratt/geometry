\name{delaunayn}
\alias{delaunayn}
\title{Delaunay triangulation in N-dimensions}
\description{
  The Delaunay triangulation is a tessellation of the convex hull of the
  points such that no n-sphere defined by the n-triangles contains
  any other points from the set.
}
\usage{
delaunayn(p, options = "QJ")
}
\arguments{
  \item{p}{ \code{p} is an \code{n}-by-\code{dim} matrix. The rows of \code{p} represent \code{n}
            points in \code{dim}-dimensional space. }
  \item{options}{ Optional options, see details below. }
}
\details{

This function interfaces the qhull library, and intents to be a port from
Octave to R. Qhull computes convex hulls, Delaunay triangulations, halfspace
intersections about a point, Voronoi diagrams, furthest-site Delaunay
triangulations, and furthest-site Voronoi diagrams. It runs in 2-d, 3-d, 4-d,
and higher dimensions. It implements the Quickhull algorithm for computing the
convex hull. Qhull handles roundoff errors from floating point arithmetic. It
computes volumes, surface areas, and approximations to the convex hull. See the
qhull documentation included in this distribution (the doc directory
\url{../doc/index.htm}).

The input \code{n}-by-\code{dim} matrix contains \code{n} points of dimension dim.
The return matrix \code{T} has \code{m} rows and \code{dim+1} columns.
It contains for each row a set of indices to the points, which describes a
simplex of dimension dim.  The 3D simplex is a tetrahedron.

If a second optional argument is given, it must be a string containing extra
options for the underlying qhull command.  In particular, "Qt" may be useful
for joggling the input to cope with non-simplicial cases. (See the Qhull
documentation (\url{../doc/index.htm}) for the available options.)
}

\value{
  The return matrix has \code{m} rows and \code{dim+1} columns. It contains
  for each row a set of indices to the points, which describes a simplex of
  dimension dim.
}

\references{
\cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T., \dQuote{The
Quickhull algorithm for convex hulls,} \emph{ACM Trans. on Mathematical
Software,} Dec 1996.}

\url{http://www.qhull.org}
}

\author{ Raoul Grasman and Robert B. Gramacy \email{bobby@statslab.cam.ac.uk}; 
based on the corresponding Octave sources of Kai Habel. }

\note{
This intents to be a port of the Octave's (\url{http://www.octave.org}) geometry
library. The sources originals were from Kai Habel.

The current implementation calls Qhull always with the "QJ" option. (See Qhull
documentation for details).

All console printing is sent to a file in the CWD called \dQuote{qhull\_out.txt} unless another
file is specified with the TO option -- see the qhull documentation.
To get the usual progress-related output specify the R-specific option "Pp Ps".

Qhull does not support constrained Delaunay triangulations, triangulation of
non-convex surfaces, mesh generation of non-convex objects, or medium-sized
inputs in 9-D and higher. A rudimentary algorithm for mesh generation
in non-convex regions using Delaunay triangulation is implemented in \link{distmesh2d}
(currently only 2D).
}

\seealso{ \code{\link[tripack]{tri.mesh}},
          \code{\link{convhulln}},
          \code{\link{surf.tri}},
          \code{\link{distmesh2d}} }
\examples{
# example delaunayn
d = c(-1,1)
pc = as.matrix(rbind(expand.grid(d,d,d),0))
tc = delaunayn(pc)

# example tetramesh
\dontrun{
library(rgl)
rgl.viewpoint(60)
rgl.light(120,60)
tetramesh(tc,pc, alpha=0.9)
}

# example surf.tri
# ==> see also convhulln, but it currently prints an unavoidable
#     message to the console
ps = matrix(rnorm(3000),ncol=3)        # generate poinst on a sphere
ps = sqrt(3) * ps / drop(sqrt((ps^2) \%*\%rep(1,3)))
ts = delaunayn(ps)
ts.surf = t( surf.tri(ps,ts) )
\dontrun{
rgl.triangles(ps[ts.surf,1], ps[ts.surf,2] ,ps[ts.surf,3],
              col="blue", alpha=.2)
for(i in 1:(8*360)) rgl.viewpoint(i/8)
}
}
\keyword{ math }
\keyword{ dplot }
\keyword{ graphs }
