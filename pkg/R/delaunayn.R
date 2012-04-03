##' @title Delaunay triangulation in N-dimensions
##' 
##' The Delaunay triangulation is a tessellation of the convex hull of
##' the points such that no N-sphere defined by the N-triangles
##' contains any other points from the set.
##' 
##' This function interfaces the Qhull library, and intents to be a port from
##' Octave to R. Qhull computes convex hulls, Delaunay triangulations,
##' halfspace intersections about a point, Voronoi diagrams, furthest-site
##' Delaunay triangulations, and furthest-site Voronoi diagrams. It runs in
##' 2-d, 3-d, 4-d, and higher dimensions. It implements the Quickhull algorithm
##' for computing the convex hull. Qhull handles roundoff errors from floating
##' point arithmetic. It computes volumes, surface areas, and approximations to
##' the convex hull. See the Qhull documentation included in this distribution
##' (the doc directory \url{../doc/index.htm}).
##'
##' The \code{Qt} option is supplied to Qhull by default. The code
##' ensures that one of \code{Qt} or \code{QJ} is passed to Qhull.
##' See \url{../doc/qdelaun.htm} for more details.
##' 
##' For slient operation, specify the option \code{Pp}. 
##'
##' @param p \code{p} is an \code{n}-by-\code{dim} matrix. The rows of \code{p}
##' represent \code{n} points in \code{dim}-dimensional space.
##' @param options String containing extra options for the underlying
##' Qhull command.(See the Qhull documentation
##' (\url{../doc/qdelaun.htm}) for the available options.)
##' @return The return matrix has \code{m} rows and \code{dim+1}
##' columns. It contains for each row a set of indices to the points,
##' which describes a simplex of dimension \code{dim}. The 3D simplex
##' is a tetrahedron.
##' @note This is  a port of Octave's (\url{http://www.octave.org})
##' geometry library.
##' 
##' Qhull does not support constrained Delaunay triangulations, triangulation
##' of non-convex surfaces, mesh generation of non-convex objects, or
##' medium-sized inputs in 9-D and higher. A rudimentary algorithm for mesh
##' generation in non-convex regions using Delaunay triangulation is
##' implemented in \link{distmesh2d} (currently only 2D).
##' @author Raoul Grasman and Robert B. Gramacy; based on the
##' corresponding Octave sources of Kai Habel.
##' @seealso \code{\link[tripack]{tri.mesh}}, \code{\link{convhulln}},
##' \code{\link{surf.tri}}, \code{\link{distmesh2d}}
##' @references \cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T.,
##' \dQuote{The Quickhull algorithm for convex hulls,} \emph{ACM Trans. on
##' Mathematical Software,} Dec 1996.}
##' 
##' \url{http://www.qhull.org}
##' @keywords math dplot graphs
##' @examples
##' 
##' # example delaunayn
##' d <- c(-1,1)
##' pc <- as.matrix(rbind(expand.grid(d,d,d),0))
##' tc <- delaunayn(pc)
##' 
##' # example tetramesh
##' \dontrun{
##' library(rgl)
##' rgl.viewpoint(60)
##' rgl.light(120,60)
##' tetramesh(tc,pc, alpha=0.9)
##' }
##' 
##' @export
##' @useDynLib geometry
delaunayn <- function (p, options="") {
  ## Input sanitisation
  options <- paste(options, collapse=" ")

  ## It is essential that delaunayn is called with either the QJ or Qt
  ## option. Otherwise it may return a non-triangulated structure, i.e
  ## one with more than dim+1 points per structure, where dim is the
  ## dimension in which the points p reside.
  if (!grepl("Qt", options) & !grepl("QJ", options)) {
    options <- paste(options, "Qt")
  }
  .Call("delaunayn", p, options, PACKAGE="geometry")
}
