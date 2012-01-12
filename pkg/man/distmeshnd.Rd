\name{distmeshnd}
\alias{distmeshnd}
\title{A simple mesh generator for non-convex regions in n-D space}
\usage{
  distmeshnd(fdist, fh, h, box,
    pfix = array(dim = c(0, ncol(box))), ..., ptol = 0.001,
    ttol = 0.1, deltat = 0.1, geps = 0.1 * h,
    deps = sqrt(.Machine$double.eps) * h)
}
\arguments{
  \item{fdist}{Vectorized signed distance function,
  accepting an \code{m}-by-\code{n} matrix, where \code{m}
  is arbitrary, as the first argument.}

  \item{fh}{Vectorized function that returns desired edge
  length as a function of position.  Accepts an
  \code{m}-by-\code{n} matrix, where \code{n} is arbitrary,
  as its first argument.}

  \item{h}{Initial distance between mesh nodes.}

  \item{box}{\code{2}-by-\code{n} matrix that specifies the
  bounding box. (See \link{distmesh2d} for an example.)}

  \item{pfix}{\code{nfix}-by-2 matrix with fixed node
  positions.}

  \item{\dots}{parameters that are passed to \code{fdist}
  and \code{fh}}

  \item{ptol}{Algorithm stops when all node movements are
  smaller than \code{dptol}}

  \item{ttol}{Controls how far the points can move
  (relatively) before a retriangulation with
  \code{\link{delaunayn}}.}

  \item{deltat}{Size of the time step in Eulers method.}

  \item{geps}{Tolerance in the geometry evaluations.}

  \item{deps}{Stepsize \eqn{\Delta x} in numerical
  derivative computation for distance function.}
}
\value{
  \code{m}-by-\code{n} matrix with node positions.
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
  between a triangular mesh and a n-D truss structure. In
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
  comments in the source file of \code{distmesh2d}.
}
\section{Wishlist }{
  \itemize{ \item*Implement in C/Fortran \item*Translate
  other functions of the matlab package }
}
\examples{
\dontrun{
# examples distmeshnd
require(rgl)

fd = function(p, ...) sqrt((p^2)\%*\%c(1,1,1)) - 1
     # also predefined as `mesh.dsphere'
fh = function(p,...)  rep(1,nrow(p))
     # also predefined as `mesh.hunif'
bbox = matrix(c(-1,1),2,3)
p = distmeshnd(fd,fh,0.2,bbox, maxiter=100)
    # this may take a while:
    # press Esc to get result of current iteration

# example with non-convex region
fd = function(p, ...) mesh.diff( p , mesh.drectangle, mesh.dcircle, radius=.3)
     # fd defines difference of square and circle

p = distmesh2d(fd,fh,0.05,bbox,radius=0.3,maxiter=4)
p = distmesh2d(fd,fh,0.05,bbox,radius=0.3, maxiter=10)
     # continue on previous mesh
}
}
\author{
  Raoul Grasman; translated from original Matlab sources of
  Per-Olof Persson.
}
\references{
  \url{http://www-math.mit.edu/~persson/mesh/}

  \cite{P.-O. Persson, G. Strang, A Simple Mesh Generator
  in MATLAB. SIAM Review, Volume 46 (2), pp. 329-345, June
  2004}
}
\seealso{
  \code{\link{distmesh2d}},
  \code{\link[tripack]{tri.mesh}}, \code{\link{delaunayn}},
  \code{\link{mesh.dsphere}}, \code{\link{mesh.hunif}},\cr
  \code{\link{mesh.diff}}, \code{\link{mesh.union}},
  \code{\link{mesh.intersect}}
}
\keyword{dplot}
\keyword{graphs}
\keyword{math}
\keyword{optimize}

