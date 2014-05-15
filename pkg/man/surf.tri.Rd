\name{surf.tri}
\alias{surf.tri}
\title{Find surface triangles from tetrahedra mesh}
\usage{
surf.tri(p, t)
}
\arguments{
  \item{p}{An \code{n}-by-\code{3} matrix. The rows of
  \code{p} represent \code{n} points in
  \code{dim}-dimensional space.}

  \item{t}{Matrix with 4 columns, interpreted as output of
  \code{\link{delaunayn}}.}
}
\value{
An \code{m}-by-\code{3} index matrix of which each row
defines a triangle. The indices refer to the rows in
\code{p}.
}
\description{
Find surface triangles from tetrahedron mesh typically
obtained with \code{\link{delaunayn}}.
}
\details{
\code{surf.tri} and \code{\link{convhulln}} serve a similar
purpose in 3D, but \code{surf.tri} also works for
non-convex meshes obtained e.g. with
\code{\link{distmeshnd}}.  It also does not produce
currently unavoidable diagnostic output on the console as
\code{convhulln} does at the Rterm console--i.e.,
\code{surf.tri} is silent.
}
\note{
\code{surf.tri} was based on matlab code for mesh of
Per-Olof Persson
(\url{http://www-math.mit.edu/~persson/mesh/index.html}).
}
\examples{
\dontrun{
# more extensive example of surf.tri
library(rgl)        # to render tesselation
library(R.matlab)   # to read matlab .mat files

# url's of publically available data:
data1.url = "http://neuroimage.usc.edu/USCPhantom/mesh_data.bin"
data2.url = "http://neuroimage.usc.edu/USCPhantom/CT_PCS_trans.bin"

meshdata = readMat(url(data1.url))
elec = readMat(url(data2.url))$eeg.ct2pcs/1000
brain = meshdata$mesh.brain[,c(1,3,2)]
scalp = meshdata$mesh.scalp[,c(1,3,2)]
skull = meshdata$mesh.skull[,c(1,3,2)]
tbr = t(surf.tri(brain, delaunayn(brain)))
tsk = t(surf.tri(skull, delaunayn(skull)))
tsc = t(surf.tri(scalp, delaunayn(scalp)))
rgl.triangles(brain[tbr,1], brain[tbr,2], brain[tbr,3],col="gray")
rgl.triangles(skull[tsk,1], skull[tsk,2], skull[tsk,3],col="white", alpha=0.3)
rgl.triangles(scalp[tsc,1], scalp[tsc,2], scalp[tsc,3],col="#a53900", alpha=0.6)
rgl.viewpoint(-40,30,.4,zoom=.03)
lx = c(-.025,.025); ly = -c(.02,.02);
rgl.spheres(elec[,1],elec[,3],elec[,2],radius=.0025,col='gray')
rgl.spheres( lx, ly,.11,radius=.015,col="white")
rgl.spheres( lx, ly,.116,radius=.015*.7,col="brown")
rgl.spheres( lx, ly,.124,radius=.015*.25,col="black")
}
}
\author{
Raoul Grasman
}
\seealso{
\code{\link[tripack]{tri.mesh}}, \code{\link{convhulln}},
\code{\link{surf.tri}}, \code{\link{distmesh2d}}
}
\keyword{dplot}
\keyword{math}
\keyword{optimize}

