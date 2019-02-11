##' Compute halfspace intersection about a point
##' 
##' @param p An \code{n}-by-\code{dim+1} matrix. Each row of \code{p}
##'   represents a halfspace by a \code{dim}-dimensional normal to a
##'   hyperplane and the offset of the hyperplane.
##' @param fp A \dQuote{feasible} point that is within the space
##'   contained within all the halfspaces.
##' @param options String containing extra options, separated by
##'   spaces, for the underlying Qhull command; see details below and
##'   Qhull documentation at
##'   \url{http://www.qhull.org/html/qhalf.htm}.
##' 
##' @return A \code{dim}-column matrix containing the intersection
##'   points of the hyperplanes \url{../doc/qhull/html/qhalf.html}. These
##'   points 
##' 
##' @author David Sterratt \email{david.c.sterratt@ed.ac.uk}
##' @seealso \code{\link{convhulln}}
##' @references \cite{Barber, C.B., Dobkin, D.P., and Huhdanpaa, H.T.,
##'   \dQuote{The Quickhull algorithm for convex hulls,} \emph{ACM
##'   Trans. on Mathematical Software,} Dec 1996.}
##' 
##' \url{http://www.qhull.org}
##' @examples
##' p <- rbox(0, C=0.5)  # Generate points on a unit cube centered around the origin
##' ch <- convhulln(p, "n") # Generate convex hull, including normals to facets, with "n" option
##' # Intersections of half planes
##' # These points should be the same as the orginal points
##' pn <- halfspacen(ch$normals, c(0, 0, 0)) 
##' 
##' @export
##' @useDynLib geometry
halfspacen <- function (p, fp, options = "Tv") {
  ## Check directory writable
  tmpdir <- tempdir()
  ## R should guarantee the tmpdir is writable, but check in any case
  if (file.access(tmpdir, 2) == -1) {
    stop(paste("Unable to write to R temporary directory", tmpdir, "\n",
               "Try setting the permissions on this directory so it is writable."))
  }
  
  ## Input sanitisation
  options <- paste(options, collapse=" ")
  
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

  ## Check dimensions
  if (ncol(p) - 1 != length(as.vector(fp))) {
    stop(paste("Dimension of hyperspace is", ncol(p) - 1, "but dimension of fixed point is", length(as.vector(fp))))
  }
  

  ## This is ugly - if halspacen fails because of similar hyperplanes,
  ## remove the most similar ones
  ## The fixed point is passed as an option
  out <- tryCatch(.Call("C_halfspacen", p,
                        as.character(paste(options, paste0("H",paste(fp, collapse=",")))),
                        tmpdir,
                        PACKAGE="geometry"),
                  error=function(e) {
                    if (grepl("^Received error code 2 from qhull.", e$message)) {
                      dpmax <- 0
                      for (i in 1:(nrow(p)-1)) {
                        for (j in (i+1):nrow(p)) {
                          dp <- abs(dot(p[i,-ncol(p)], p[j,-ncol(p)]))
                          if (dp > dpmax) {
                            imax <- i
                            jmax <- j
                            dpmax <- dp
                          }
                        }
                      }
                      return(halfspacen(p[-imax,], fp, options))
                    }
                    return(e)
                  })
  if (inherits(out, "error")) {
    stop(out$message)
  }
  return(out)
}

## If there is an error, it could be because of two very similar halfspaces.
## n1 = ch1$normals[1,1:3]
## n2 = ch2$normals[1,1:3]
## d1 = ch1$normals[1,4]
## d2 = ch2$normals[1,4]
## solve(rbind(n1, n2, extprod3d(n1, n2)), c(d1, d2, 0))
## sqrt(sum(solve(rbind(n1, n2, extprod3d(n1, n2)), c(-d1, -d2, 0))^2))
## dot(n1+ n2, extprod3d(n1, n2))

