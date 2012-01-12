\name{distmesh2d}
\alias{distmesh2d}
\title{A simple mesh generator for non-convex regions}
\usage{
  distmesh2d(fd, fh, h0, bbox, p = NULL,
    pfix = array(0, dim = c(0, 2)), ..., dptol = 0.001,
    ttol = 0.1, Fscale = 1.2, deltat = 0.2,
    geps = 0.001 * h0,
    deps = sqrt(.Machine$double.eps) * h0, maxiter = 1000)
}
\arguments{
  \item{fd}{Vectorized signed distance function, accepting
  an \code{n}-by-\code{2} matrix, where \code{n} is
  arbitrary, as the first argument.}

  \item{fh}{Vectorized function that returns desired edge
  length as a function of position.  Accepts an
  \code{n}-by-\code{2} matrix, where \code{n} is arbitrary,
  as its first argument.}

  \item{h0}{Initial distance between mesh nodes. (Ignored
  of \code{p} is supplied)}

  \item{bbox}{Bounding box cbind(c(xmin,xmax),
  c(ymin,ymax))}

  \item{p}{An \code{n}-by-\code{2} matrix. The rows of
  \code{p} represent locations of starting mesh nodes.}

  \item{pfix}{\code{nfix}-by-2 matrix with fixed node
  positions.}

  \item{\dots}{parameters to be passed to \code{fd} and/or
  \code{fh}}

  \item{dptol}{Algorithm stops when all node movements are
  smaller than \code{dptol}}

  \item{ttol}{Controls how far the points can move
  (relatively) before a retriangulation with
  \code{\link{delaunayn}}.}

  \item{Fscale}{\dQuote{Internal pressure} in the edges.}

  \item{deltat}{Size of the time step in Eulers method.}

  \item{geps}{Tolerance in the geometry evaluations.}

  \item{deps}{Stepsize \eqn{\Delta x} in numerical
  derivative computation for distance function.}

  \item{maxiter}{Maximum iterations.}
}
\value{
  \code{n}-by-\code{2} matrix with node positions.
}
\description{
  An unstructured simplex requires a choice of meshpoints
  (vertex nodes) and a triangulation.  This is a simple and
  short algorithm that improves the quality of a mesh by
  relocating the meshpoints according to a relaxation
  scheme of forces in a truss structure. The topology of
  the truss is reset using Delaunay triangulation. A
  (sufficiently smooth) user supplied signed distance
  function (\code{fd}) indicates if a given node is inside
  or outside the region. Points outside the region are
  projected back to the boundary.
}
\details{
  This is an implementation of original Matlab software of
  Per-Olof Persson.

  Excerpt (modified) from the reference below:

  \sQuote{The algorithm is based on a mechanical analogy
  between a triangular mesh and a 2D truss structure. In
  the physical model, the edges of the Delaunay triangles
  of a set of points correspond to bars of a truss. Each
  bar has a force-displacement relationship \eqn{f(\ell,
  \ell_{0})}{F(L,L0)} depending on its current length
  \eqn{\ell}{L} and its unextended length
  \eqn{\ell_{0}}{L0}.}

  \sQuote{External forces on the structure come at the
  boundaries, on which external forces have normal
  orientations. These external forces are just large enough
  to prevent nodes from moving outside the boundary. The
  position of the nodes are the unknowns, and are found by
  solving for a static force equilibrium. The hope is that
  (when \code{fh = function(p) return(rep(1,nrow(p)))}),
  the lengths of all the bars at equilibrium will be nearly
  equal, giving a well-shaped triangular mesh.}

  See the references below for all details. Also, see the
  comments in the source file.
}
\section{Wishlist }{
  \itemize{ \item*Implement in C/Fortran \item*Implement an
  \code{n}D version as provided in the matlab package
  \item*Translate other functions of the matlab package }
}
\examples{
# examples distmesh2d
fd = function(p, ...) sqrt((p^2)\%*\%c(1,1)) - 1
     # also predefined as `mesh.dcircle'
fh = function(p,...)  rep(1,nrow(p))
bbox = matrix(c(-1,1,-1,1),2,2)
p = distmesh2d(fd,fh,0.2,bbox, maxiter=100)
    # this may take a while:
    # press Esc to get result of current iteration

# example with non-convex region
fd = function(p, ...) mesh.diff( p , mesh.drectangle, mesh.dcircle, radius=.3)
     # fd defines difference of square and circle

p = distmesh2d(fd,fh,0.05,bbox,radius=0.3,maxiter=4)
p = distmesh2d(fd,fh,0.05,bbox,radius=0.3, maxiter=10)
     # continue on previous mesh
}
\author{
  Raoul Grasman
}
\references{
  \url{http://www-math.mit.edu/~persson/mesh/}

  \cite{P.-O. Persson, G. Strang, A Simple Mesh Generator
  in MATLAB. SIAM Review, Volume 46 (2), pp. 329-345, June
  2004}
}
\seealso{
  \code{\link[tripack]{tri.mesh}}, \code{\link{delaunayn}},
  \code{\link{mesh.dcircle}},
  \code{\link{mesh.drectangle}},\cr
  \code{\link{mesh.diff}}, \code{\link{mesh.union}},
  \code{\link{mesh.intersect}}
}
\keyword{dplot}
\keyword{graphs}
\keyword{math}
\keyword{optimize}

