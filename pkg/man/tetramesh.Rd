\name{tetramesh}
\alias{tetramesh}
\alias{trimesh}
\title{ Display triangles mesh (2D) render tetrahedron mesh (3D) }
\description{
  \code{tetramesh(T, X, col)} uses the \link[rgl]{rgl} package
  to display the tetrahedrons defined in the m-by-4 matrix T as mesh.
}
\usage{
tetramesh(T, X, col = heat.colors(nrow(T)), clear = TRUE, ...)
trimesh(T, p, p2, add = FALSE, axis = FALSE, boxed = FALSE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{T}{ T is a \code{m}-by-3 matrix in trimesh and \code{m}-by-4 in tetramesh. A row of \code{T} contains indices into \code{X}
  of the vertices of a triangle/tetrahedron. \code{T} is usually the output of delaunayn.  }
  \item{X}{ X is an n-by-2/n-by-3 matrix. The rows of X represent \code{n} points in 2D/3D space. }
  \item{p}{ A vector or a matrix. }
  \item{p2}{ if \code{p} is not a matrix \code{p} and \code{p2} are bind to a matrix with \code{cbind}. }
  \item{add}{ Add to existing plot in current active device? }
  \item{axis}{ Draw axes? }
  \item{boxed}{ Plot box? }
  \item{col}{ The tetrahedron color. See rgl documentation for details. }
  \item{clear}{ Should the current rendering device be cleared?  }
  \item{\dots}{ Parameters to the rendering device. See the \link[rgl]{rgl} package. }
}
\details{
  Each row of \code{T} specifies a triangle by giving the 3 indices of its points in \code{X}.
  Each row of \code{T} specifies a thetrahedron by giving the 4 indices of its points in \code{X}.
}

\author{ Raoul Grasman }


\seealso{ \code{\link[rgl]{rgl}}, \code{\link{delaunayn}}, \code{\link{convhulln}},
\code{\link{surf.tri}} }
\examples{
#example trimesh
p = cbind(x=rnorm(30), y=rnorm(30))
tt = delaunayn(p)
trimesh(tt,p)

\dontrun{
# example delaunayn
d = c(-1,1)
pc = as.matrix(rbind(expand.grid(d,d,d),0))
tc = delaunayn(pc)

# example tetramesh
library(rgl)
clr = rep(1,3) %o% (1:nrow(tc)+1)
rgl.viewpoint(60,fov=20)
rgl.light(270,60)
tetramesh(tc,pc,alpha=0.7,col=clr)
}
}
\keyword{ hplot }% at least one, from doc/KEYWORDS
