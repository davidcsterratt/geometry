##' Compute smallest convex hull that encloses a set of points
##' 
##' Returns information about the smallest convex complex of a set of
##' input points in \eqn{N}-dimensional space (the convex hull of the
##' points). By default, indices to points forming the facets of the
##' hull are returned; optionally normals to the facets and the
##' generalised surface area and volume can be returned. This function
##' interfaces the \href{http://www.qhull.org}{Qhull} library.
##'
##' @param p An \eqn{M}-by-\eqn{N} matrix. The rows of \code{p}
##'   represent \eqn{M} points in \eqn{N}-dimensional space.
##'
##' @param options String containing extra options for the underlying
##'   Qhull command; see details below and Qhull documentation at
##'   \url{../doc/qhull/html/qconvex.html#synopsis}.
##'
##' @param output.options String containing Qhull options to generate
##'   extra output. Currently \code{n} (normals) and \code{FA}
##'   (generalised areas and volumes) are supported; see
##'   \sQuote{Value} for details. If \code{output.options} is
##'   \code{TRUE}, select all supported options.
##' 
##' @param return.non.triangulated.facets logical defining whether the
##'   output facets should be triangulated; \code{FALSE} by default.
##' 
##' @return By default (\code{return.non.triangulated.facets} is
##'   \code{FALSE}), return an \eqn{M}-by-\eqn{N} matrix in which each
##'   row contains the indices of the points in \code{p} forming an
##'   \eqn{N-1}-dimensional facet. e.g In 3 dimensions, there are 3
##'   indices in each row describing the vertices of 2-dimensional
##'   triangles.
##' 
##'   If \code{return.non.triangulated.facets} is \code{TRUE} then the
##'   number of columns equals the maximum number of vertices in a
##'   facet, and each row defines a polygon corresponding to a facet
##'   of the convex hull with its vertices followed by \code{NA}s
##'   until the end of the row.
##'
##'   If the \code{output.options} or \code{options} argument contains
##'   \code{FA} or \code{n}, return a list with class \code{convhulln}
##'   comprising the named elements:
##'   \describe{
##'     \item{\code{p}}{The points passed to \code{convnhulln}}
##'     \item{\code{hull}}{The convex hull, represented as a matrix indexing \code{p}, as
##'       described above}
##'     \item{\code{area}}{If \code{FA} is specified, the generalised area of
##'       the hull. This is the surface area of a 3D hull or the length of
##'       the perimeter of a 2D hull.
##'       See \url{../doc/qhull/html/qh-optf.html#FA}.}
##'     \item{\code{vol}}{If \code{FA} is specified, the generalised volume of
##'        the hull. This is volume of a 3D hull or the area of a 2D hull.
##'        See \url{../doc/qhull/html/qh-optf.html#FA}. }
##'     \item{\code{normals}}{If \code{n} is specified, this is a matrix
##'     hyperplane normals with offsets. See \url{../doc/qhull/html/qh-opto.html#n}.}
##'   }
##'
##' @note This function was originally a port of the
##'   \href{http://www.octave.org}{Octave} convhulln function written
##'   by Kai Habel.
##' 
##' See further notes in \code{\link{delaunayn}}.
##' 
##' @author Raoul Grasman, Robert B. Gramacy, Pavlo Mozharovskyi and
##'   David Sterratt \email{david.c.sterratt@@ed.ac.uk}
##' @seealso \code{\link{intersectn}}, \code{\link{delaunayn}},
##'   \code{\link{surf.tri}}, \code{\link[tripack]{convex.hull}}
##' @references \cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T.,
##'   \dQuote{The Quickhull algorithm for convex hulls,} \emph{ACM
##'   Trans. on Mathematical Software,} Dec 1996.}
##'
##' \url{http://www.qhull.org}
##' @keywords math dplot graphs
##' @examples
##' ## Points in a sphere
##' ps <- matrix(rnorm(3000), ncol=3)  
##' ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1, 3)))
##' ts.surf <- t(convhulln(ps))  # see the qhull documentations for the options
##' \dontrun{
##' rgl.triangles(ps[ts.surf,1],ps[ts.surf,2],ps[ts.surf,3],col="blue",alpha=.2)
##' for(i in 1:(8*360)) rgl.viewpoint(i/8)
##' }
##'
##' ## Square
##' pq <- rbox(0, C=0.5, D=2)
##' # Return indices only
##' convhulln(pq)
##' # Return convhulln object with normals, generalised area and volume
##' ch <- convhulln(pq, output.options=TRUE)
##' plot(ch)
##'
##' ## Cube
##' pc <- rbox(0, C=0.5, D=3)
##' # Return indices of triangles on surface
##' convhulln(pc)
##' # Return indices of squares on surface
##' convhulln(pc, return.non.triangulated.facets=TRUE)
##' @export
##' @useDynLib geometry
convhulln <- function (p, options = "Tv", output.options=NULL, return.non.triangulated.facets = FALSE) {
  tmp_stdout <- tempfile("Rf")
  tmp_stderr <- tempfile("Rf")
  on.exit(unlink(c(tmp_stdout, tmp_stderr)))
  
  ## Combine and check options
  options <- tryCatch(qhull.options(options, output.options, supported_output.options  <- c("n", "FA")), error=function(e) {stop(e)})

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
  
  if (!return.non.triangulated.facets){
    ## It is essential that delaunayn is called with either the QJ or Qt
    ## option. Otherwise it may return a non-triangulated structure, i.e
    ## one with more than dim+1 points per structure, where dim is the
    ## dimension in which the points p reside.
    if (!grepl("Qt", options) & !grepl("QJ", options)) {
      options <- paste(options, "Qt")
    }
  }
  out <- .Call("C_convhulln", p, as.character(options), as.integer(return.non.triangulated.facets), tmp_stdout, tmp_stderr, PACKAGE="geometry")

  # Remove NULL elements
  out[which(sapply(out, is.null))] <- NULL
  if (is.null(out$area) & is.null(out$vol) & is.null(out$normals)) {
    attr(out$hull, "convhulln") <- attr(out, "convhulln")
    return(out$hull)
  }
  class(out) <- "convhulln"
  out$p <- p
  return(out)
}

##' @importFrom graphics plot
##' @method plot convhulln
##' @export 
plot.convhulln <- function(x, y, ...) {
  if (ncol(x$p) < 2 || ncol(x$p) > 3)
    stop("Only 2D and 3D convhullns can be plotted")
  args <- list(...)
  add <- FALSE
  if ("add" %in% names(args)) {
    add <- args$add
    args$add <- NULL
  }
  if (ncol(x$p) == 2) {
    if (!add) {
      plot(x$p[,1], x$p[,2], ...)      
    }
    m <- x$hull
    p <- x$p
    do.call(segments, c(list(p[m[,1],1],p[m[,1],2],p[m[,2],1],p[m[,2],2]),
                        args))
  }
  if (ncol(x$p) == 3) {
    if(requireNamespace("rgl") == FALSE)
      stop("The rgl package is required for tetramesh")
    if (!add) rgl::rgl.clear()
    if (ncol(x$hull) == 3) {
      do.call(rgl::rgl.triangles,
              c(list(x$p[t(x$hull),1], x$p[t(x$hull),2], x$p[t(x$hull),3]),
                args))
    } else {
      stop("At present only convhullns with triangulated facets can be plotted")
    }
  }
}

##' Convert convhulln object to RGL mesh
##'
##' @param x \code{\link{convhulln}} object
##' @param ... Arguments to \code{\link[rgl]{qmesh3d}} or
##'   \code{\link[rgl]{tmesh3d}}
##' @return \code{\link[rgl]{mesh3d}} object, which can be displayed
##'   in RGL with \code{\link[rgl]{dot3d}}, \code{\link[rgl]{wire3d}}
##'   or \code{\link[rgl]{shade3d}}
##' 
##' @seealso \code{\link[rgl]{as.mesh3d}}
##' @export
to.mesh3d <- function(x, ...) UseMethod("to.mesh3d")

##' @importFrom graphics plot
##' @method to.mesh3d convhulln
##' @export 
to.mesh3d.convhulln <- function(x, ...) {
  if(requireNamespace("rgl") == FALSE) 
    stop("The rgl package is required for as.mesh.convhulln")
  if (ncol(x$p) != 3) {
    stop("Only convex hulls of points in 3D can be turned into meshes")
  }
  if (ncol(x$hull) == 4) {
    stop("At present only convhulls with triangulated facets can be converted to mesh3d")
    ## return(rgl::qmesh3d(t(x$p), t(x$hull), homogeneous=FALSE, ...))
  }
  if (ncol(x$hull) == 3) {
    return(rgl::tmesh3d(t(x$p), t(x$hull), homogeneous=FALSE, ...))
  }
  stop("Facets of hull must be triangles or quadrilaterals")
}


##  LocalWords:  dQuote Qhull param itemize Kai Habel delaunayn Pavlo
##  LocalWords:  Grasman Gramacy Mozharovskyi Sterratt seealso tri ps
##  LocalWords:  tripack distmesh intersectn Dobkin Huhdanpaa emph Tv
##  LocalWords:  Quickhull ACM dplot convhulln qhull rnorm ncol sqrt
##  LocalWords:  dontrun useDynLib tmp_stdout tmp_stderr tempdir sanitisation NAs na
##  LocalWords:  QJ grepl importFrom convhulls args requireNamespace
##  LocalWords:  rgl tetramesh eqn href sQuote hyperplane rbox
##  LocalWords:  convulln convhullns
