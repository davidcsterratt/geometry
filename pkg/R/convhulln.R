##' Compute smallest convex hull that encloses a set of points
##' 
##' Returns an index matrix to the points of simplices (\dQuote{triangles})
##' that form the smallest convex simplicial complex of a set of input points
##' in N-dimensional space.
##' 
##' This function interfaces the qhull library, and intends to be a port from
##' Octave to R.
##' 
##' The input \code{n}-by-\code{dim} matrix contains \code{n} points
##' of dimension \code{dim}. If a second optional argument is given,
##' it must be a string containing extra options for the underlying
##' qhull command.  The \code{options} always include
##' \code{"Qt"}. (See the Qhull documentation for the available
##' options -- refer to \link{delaunayn}.)
##' 
##' @param p An \code{n}-by-\code{dim} matrix.  The rows of \code{p} represent
##' \code{n} points in \code{dim}-dimensional space.
##' @param options Optional options, see details below and Qhull documentation.
##' @return An \code{m}-by-\code{dim} index matrix of which each row defines a
##' \code{dim}-dimensional \dQuote{triangle}. The indices refer to the rows in
##' \code{p}.  If the option \code{"FA"} is provided, then the output is a
##' \code{list} with entries \code{$hull} containing the matrix mentioned
##' above, and \code{$area} and \code{$vol} with the area and volume of the
##' hull described by the matrix.
##' @note This intents to be a port of the Octave's
##' (\url{http://www.octave.org}) geometry library. The sources originals were
##' from Kai Habel.
##'
##' To get the usual progress-related output specify the R-specific
##' option \code{"Pp Ps"}. The option \code{"FA"} results in the area
##' and volume of the convex hull to be included in the output list.
##' 
##' See further notes in \link{delaunayn}.
##' @author Raoul Grasman and Robert B. Gramacy
##' \email{bobby@@statslab.cam.ac.uk}
##' @seealso \code{\link[tripack]{convex.hull}}, \code{\link{delaunayn}},
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
##' d = c(-1,1)
##' pc = as.matrix(rbind(expand.grid(d,d,d),0))
##' tc = delaunayn(pc)
##' 
##' # example tetramesh
##' \dontrun{
##' library(rgl)
##' rgl.viewpoint(60)
##' rgl.light(120,60)
##' tetramesh(tc,pc, alpha=0.9)    # render tetrahedron mesh
##' }
##' 
##' # example convhulln
##' # ==> see also surf.tri to avoid unwanted messages printed to the console by qhull
##' ps = matrix(rnorm(3000),ncol=3)                     # generate poinst on a sphere
##' ps = sqrt(3) * ps / drop(sqrt((ps^2) %*% rep(1,3)))
##' ts.surf = t( convhulln(ps,"QJ") ) # see the qhull documentations for the options
##' \dontrun{
##' rgl.triangles(ps[ts.surf,1],ps[ts.surf,2],ps[ts.surf,3],col="blue",alpha=.2)
##' for(i in 1:(8*360)) rgl.viewpoint(i/8)
##' }
##'
##' @export
##' @useDynLib geometry
"convhulln" <-
function (p, options = "Tv") 
.Call("convhulln", as.matrix(p), as.character(options), PACKAGE="geometry")
