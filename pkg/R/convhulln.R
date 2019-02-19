##' Compute smallest convex hull that encloses a set of points
##' 
##' Returns an index matrix to the points of simplices
##' (\dQuote{triangles}) that form the smallest convex simplical
##' complex of a set of input points in \eqn{N}-dimensional space. This
##' function interfaces the Qhull library.
##' 
##' For silent operation, specify the option \code{Pp}.
##'
##' @param p An \eqn{M}-by-\eqn{N} matrix. The rows of \code{p}
##'   represent \eqn{M} points in \eqn{N}-dimensional space.
##'
##' @param options String containing extra options for the underlying
##'   Qhull command; see details below and Qhull documentation at
##'   \url{../doc/qhull/html/qconvex.html#synopsis}.
##'
##' @param output.options String containing Qhull options to control
##'   output. Currently \code{n} (normals) and \code{FA} (generalised
##'   areas and volumes) are supported. Causes an object of return
##'   value for details. If \code{output.options} is \code{TRUE},
##'   select all supported options.
##' 
##' @param return.non.triangulated.facets logical defining whether the
##'   output facets should be triangulated; \code{FALSE} by default.
##' 
##' @return If \code{return.non.triangulated.facets} is \code{FALSE}
##'   (default), return an \eqn{M}-by-\eqn{N} index matrix of which
##'   each row defines an \eqn{N}-dimensional \dQuote{triangle}.
##'
##'   If \code{return.non.triangulated.facets} is \code{TRUE} then the
##'   number of columns equals the maximum number of vertices in a
##'   facet, and each row defines a polygon corresponding to a facet
##'   of the convex hull with its vertices followed by \code{NA}s
##'   until the end of the row. The indices refer to the rows in
##'   \code{p}.
##'
##'   If the \code{output.options} or \code{options} argument contains
##'   \code{FA} or \code{n}, return a list with class \code{convhulln}
##'   comprising the named elements:
##'   \describe{
##'     \item{\code{hull}}{The convex hull, represented as a matrix, as
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
##' @note This is a port of the Octave's (\url{http://www.octave.org})
##' geometry library. The Octave source was written by Kai Habel.
##' 
##' See further notes in \code{\link{delaunayn}}.
##' 
##' @author Raoul Grasman, Robert B. Gramacy, Pavlo Mozharovskyi and David Sterratt
##' \email{david.c.sterratt@@ed.ac.uk}
##' @seealso \code{\link[tripack]{convex.hull}}, \code{\link{delaunayn}},
##' \code{\link{surf.tri}}, \code{\link{distmesh2d}}, \code{\link{intersectn}}
##' @references \cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T.,
##' \dQuote{The Quickhull algorithm for convex hulls,} \emph{ACM Trans. on
##' Mathematical Software,} Dec 1996.}
##' 
##' \url{http://www.qhull.org}
##' @keywords math dplot graphs
##' @examples
##' # example convhulln
##' # ==> see also surf.tri to avoid unwanted messages printed to the console by qhull
##' ps <- matrix(rnorm(3000), ncol=3)  # generate points on a sphere
##' ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1, 3)))
##' ts.surf <- t(convhulln(ps))  # see the qhull documentations for the options
##' \dontrun{
##' rgl.triangles(ps[ts.surf,1],ps[ts.surf,2],ps[ts.surf,3],col="blue",alpha=.2)
##' for(i in 1:(8*360)) rgl.viewpoint(i/8)
##' }
##'
##' @export
##' @useDynLib geometry
convhulln <- function (p, options = "Tv", output.options=NULL, return.non.triangulated.facets = FALSE) {
  ## Check directory writable
  tmpdir <- tempdir()
  ## R should guarantee the tmpdir is writable, but check in any case
  if (file.access(tmpdir, 2) == -1) {
    stop("Unable to write to R temporary directory ", tmpdir, "\n",
         "Try setting the permissions on this directory so it is writable.")
  }
  
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
  out <- .Call("C_convhulln", p, as.character(options), as.integer(return.non.triangulated.facets), tmpdir, PACKAGE="geometry")

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
##  LocalWords:  dontrun useDynLib tmpdir tempdir sanitisation NAs na
##  LocalWords:  QJ grepl importFrom convhulls args requireNamespace
##  LocalWords:  rgl tetramesh
