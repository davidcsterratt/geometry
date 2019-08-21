##' Delaunay triangulation in N dimensions
##' 
##' The Delaunay triangulation is a tessellation of the convex hull of
##' the points such that no \eqn{N}-sphere defined by the \eqn{N}-
##' triangles contains any other points from the set.
##'
##' @param p An \eqn{M}-by-\eqn{N} matrix whose rows represent \eqn{M}
##'   points in \eqn{N}-dimensional space.
##'
##' @param options String containing extra control options for the
##'   underlying Qhull command; see the Qhull documentation
##'   (\url{../doc/qhull/html/qdelaun.html}) for the available
##'   options. 
##'
##'   The \code{Qbb} option is always passed to Qhull. The remaining
##'   default options are \code{Qcc Qc Qt Qz} for \eqn{N<4} and
##'   \code{Qcc Qc Qt Qx} for \eqn{N>=4}. If neither of the \code{QJ}
##'   or \code{Qt} options are supplied, the \code{Qt} option is
##'   passed to Qhull. The \code{Qt} option ensures all Delaunay
##'   regions are simplical (e.g., triangles in 2D). See
##'   \url{../doc/qhull/html/qdelaun.html} for more details. Contrary
##'   to the Qhull documentation, no degenerate (zero area) regions
##'   are returned with the \code{Qt} option since the R function
##'   removes them from the triangulation.
##'
##'   \emph{If \code{options} is specified, the default options are
##'   overridden.} It is recommended to use \code{output.options} for
##'   options controlling the outputs.
##'
##' @param output.options String containing Qhull options to control
##'   output. Currently \code{Fn} (neighbours) and \code{Fa} (areas)
##'   are supported. Causes an object of  return value for details. If
##'   \code{output.options} is \code{TRUE}, select all supported
##'   options.
##' 
##' @param full Deprecated and will be removed in a future release.
##'   Adds options \code{Fa} and \code{Fn}.
##'
##' @return If \code{output.options} is \code{NULL} (the default),
##'   return the Delaunay triangulation as a matrix with \eqn{M} rows
##'   and \eqn{N+1} columns in which each row contains a set of
##'   indices to the input points \code{p}. Thus each row describes a
##'   simplex of dimension \eqn{N}, e.g. a triangle in 2D or a
##'   tetrahedron in 3D.
##'
##'   If the \code{output.options} argument is \code{TRUE} or is a
##'   string containing \code{Fn} or \code{Fa}, return a list with
##'   class \code{delaunayn} comprising the named elements:
##'   \describe{
##'     \item{\code{tri}}{The Delaunay triangulation described above}
##'     \item{\code{areas}}{If \code{TRUE} or if \code{Fa} is specified, an
##'       \eqn{M}-dimensional vector containing the generalised area of
##'       each simplex (e.g. in 2D the areas of triangles; in 3D the volumes
##'       of tetrahedra). See \url{../doc/qhull/html/qh-optf.html#Fa}.}
##'     \item{\code{neighbours}}{If \code{TRUE} or if \code{Fn} is specified,
##'       a list of  neighbours of each simplex.
##'       See \url{../doc/qhull/html/qh-optf.html#Fn}} 
##'   }
##' 
##' @note This function interfaces the Qhull library and is a port
##'   from Octave (\url{http://www.octave.org}) to R. Qhull computes
##'   convex hulls, Delaunay triangulations, halfspace intersections
##'   about a point, Voronoi diagrams, furthest-site Delaunay
##'   triangulations, and furthest-site Voronoi diagrams. It runs in
##'   2D, 3D, 4D, and higher dimensions. It implements the
##'   Quickhull algorithm for computing the convex hull. Qhull handles
##'   round-off errors from floating point arithmetic. It computes
##'   volumes, surface areas, and approximations to the convex
##'   hull. See the Qhull documentation included in this distribution
##'   (the doc directory \url{../doc/qhull/index.html}).
##'
##' Qhull does not support constrained Delaunay triangulations, triangulation
##' of non-convex surfaces, mesh generation of non-convex objects, or
##' medium-sized inputs in 9D and higher. A rudimentary algorithm for mesh
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
##' rgl::rgl.viewpoint(60)
##' rgl::rgl.light(120,60)
##' tetramesh(tc,pc, alpha=0.9)
##' }
##'
##' tc1 <- delaunayn(pc, output.options="Fa")
##' ## sum of generalised areas is total volume of cube
##' sum(tc1$areas)
##' 
##' @export
##' @useDynLib geometry
delaunayn <-
function(p, options=NULL, output.options=NULL, full=FALSE) {
  tmp_stdout <- tempfile("Rf")
  tmp_stderr <- tempfile("Rf")
  on.exit(unlink(c(tmp_stdout, tmp_stderr)))

  ## Coerce the input to be matrix
  if (is.data.frame(p)) {
    p <- as.matrix(p)
  }

  ## Make sure we have real-valued input
  storage.mode(p) <- "double"
  
  ## We need to check for NAs in the input, as these will crash the C
  ## code.
  if (any(is.na(p))) {
    stop("The first argument should not contain any NAs")
  }

  ## Default options
  if (is.null(options)) {
    if (ncol(p) < 4) {
      options <- "Qt Qc Qz"
    } else {
      options <- "Qt Qc Qx"
    }
  }

  ## Combine and check options
  options <- tryCatch(qhull.options(options, output.options, supported_output.options  <- c("Fa", "Fn"), full=full), error=function(e) {stop(e)})
  
  ## It is essential that delaunayn is called with either the QJ or Qt
  ## option. Otherwise it may return a non-triangulated structure, i.e
  ## one with more than dim+1 points per structure, where dim is the
  ## dimension in which the points p reside.
  if (!grepl("Qt", options) & !grepl("QJ", options)) {
    options <- paste(options, "Qt")
  }

  out <- .Call("C_delaunayn", p, as.character(options), tmp_stdout, tmp_stderr, PACKAGE="geometry")

  # Remove NULL elements
  out[which(sapply(out, is.null))] <- NULL
  if (is.null(out$areas) & is.null(out$neighbours)) {
    attr(out$tri, "delaunayn") <- attr(out$tri, "delaunayn")
    return(out$tri)
  }
  class(out) <- "delaunayn"
  out$p <- p
  return(out)
}

##  LocalWords:  param Qhull Fn delaunayn Qbb Qcc Qc Qz Qx QJ itemize
##  LocalWords:  tri Voronoi Quickhull distmesh Grasman Gramacy Kai
##  LocalWords:  Habel seealso tripack convhulln Dobkin Huhdanpaa ACM
##  LocalWords:  dQuote emph dplot pc tc tetramesh dontrun useDynLib
