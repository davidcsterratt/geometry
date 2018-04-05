##' Compute convex hull of intersection of two sets of points
##' @param ps1 First set of points
##' @param ps2 Second set of points
##' @return List containing named elements: \code{ch1}, the convex
##'   hull of the first set of points, with volumes, areas and normals
##'   (see \code{\link{convhulln}}; \code{ch2}, the convex hull of the
##'   first set of points, with volumes, areas and normals; \code{ps},
##'   the intersection points of convex hulls \code{ch1} and
##'   \code{ch2}; and \code{ch}, the convex hull of the intersection
##'   points, with volumes, areas and normals.
##' @export
##' @examples
##' # Two overlapping boxes
##' ps1 <- rbox(0, C=0.5)
##' ps2 <- rbox(0, C=0.5) + 0.5
##' out <- intersectn(ps1, ps2)
##' message(paste("Volume of 1st convex hull:", out$ch1$vol))
##' message(paste("Volume of 2nd convex hull:", out$ch2$vol))
##' message(paste("Volume of intersection convex hull:", out$ch$vol))
##' @author David Sterratt
##' @seealso convhulln, halfspacen, inhulln
intersectn <- function(ps1, ps2) {
  ## Check there are overlaps
  ch1 <- convhulln(ps1, "n FA")
  ch2 <- convhulln(ps2, "n FA")

  in2 <- inhulln(ch2, ps1)
  if (all(in2 == FALSE)) {
    stop("Convex hulls of ps1 and ps2 do not overlap.")
  }
  in1 <- inhulln(ch1, ps2)

  ## Find feasible point
  fp <- colMeans(rbind(ps2[in1,], ps1[in2,]))

  ## Find intesections of halfspaces about feasible point
  ps <- halfspacen(rbind(ch1$normals, ch2$normals), fp)
  ch <- convhulln(ps, "n FA")
  
  return(list(ch1=ch1, ch2=ch2, ps=ps, ch=ch))
}
