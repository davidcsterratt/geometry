##' Compute halfspace intersection about a point
##' 
##' @param p An \eqn{M}-by-\eqn{N+1} matrix. Each row of \code{p}
##'   represents a halfspace by a \eqn{N}-dimensional normal to a
##'   hyperplane and the offset of the hyperplane.
##' @param fp A \dQuote{feasible} point that is within the space
##'   contained within all the halfspaces.
##' @param options String containing extra options, separated by
##'   spaces, for the underlying Qhull command; see Qhull
##'   documentation at \url{../doc/qhull/html/qhalf.html}.
##' 
##' @return A \eqn{N}-column matrix containing the intersection
##'   points of the hyperplanes \url{../doc/qhull/html/qhalf.html}.
##' 
##' @author David Sterratt
##' @note \code{halfspacen} was introduced in geometry 0.4.0, and is
##'   still under development. It is worth checking results for
##'   unexpected behaviour.
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
  tmp_stdout <- tempfile("Rf")
  tmp_stderr <- tempfile("Rf")
  on.exit(c(tmp_stdout, tmp_stderr))
  
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
    stop("Dimension of hyperspace is ", ncol(p) - 1, " but dimension of fixed point is ", length(as.vector(fp)))
  }
  

  ## In geometry 0.4.0, we tried to get around halspacen fails because
  ## of similar hyperplanes, by removing the most similar ones (i.e.
  ## those that had very acute angles to one another). However, this
  ## was ugly and turned out to unreliable , so it has been removed in
  ## geometry 0.4.1 and above. Users are recommended to supply the
  ## QJ option in 
  
  ## The fixed point is passed as an option
  out <- tryCatch(.Call("C_halfspacen", p,
                        as.character(paste(options, paste0("H",paste(fp, collapse=",")))),
                        tmp_stdout, tmp_stderr,
                        PACKAGE="geometry"),
                  error=function(e) {
                    if (grepl("^Received error code 2 from qhull.", e$message)) {
                      e$message <- paste(e$message, "\nTry calling halfspacen with options=\"Tv QJ\"")
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

