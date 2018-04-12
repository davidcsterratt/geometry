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

  fp <- NA
  ## Find feasible point
  in2 <- inhulln(ch2, ps1)
  in1 <- inhulln(ch1, ps2)
  if (any(in2) & any(in2)) {
    fp <- colMeans(rbind(ps2[in1,], ps1[in2,]))
  } else {
    fp <- feasible.point(ps1, ps2)
    if (all(is.na(fp))) {
      return(list(ch1=ch1, ch2=ch2, ch=list(vol=0)))
    }
    fp <- fp$fp
  }

  
  ## Find intesections of halfspaces about feasible point
  ps <- halfspacen(rbind(ch1$normals, ch2$normals), fp)
  ch <- convhulln(ps, "n FA")
  out <- list(ch1=ch1, ch2=ch2, ps=ps, ch=ch)
  class(out) <- "intersectn"
  return(out)
}

separating.axis <- function(ch1, ch2) {
  d <- ncol(ch1$p)
  ps1 <- ch1$p
  ps2 <- ch2$p
  message("Normals of ch1")
  for (i in 1:nrow(ch1$hull)) {
    ## message("Points in plane")
    ## ps1 <- ch1$p[ch1$hull[i,],,drop=FALSE]
    ## print(ps)
    ## print(t(ps))
    ## print(ch1$normals[i,1:d])
    ## print(colSums(t(ps1) * ch1$normals[i,1:d]) + ch1$normals[i,d + 1])
    ## message("Points not in plane")          
    ## ps1 <- ch1$p[-ch1$hull[i,],,drop=FALSE]
    ## print(colSums(t(ps1) * ch1$normals[i,1:d]) + ch1$normals[i,d + 1])
    message("Range of all points in ch1")
    proj1 <- range(colSums(t(ps1) * ch1$normals[i,1:d]) + ch1$normals[i,d + 1])
    print(proj1)
    message("Range of all points in ch2")
    proj2 <- range(colSums(t(ps2) * ch1$normals[i,1:d]) + ch1$normals[i,d + 1])
    print(proj2)
    if ((max(proj1) <= min(proj2)) | (max(proj2) <= min(proj1))) {
      message("No overlap")
      return(TRUE)
    }
  }
  message("Normals of ch2")
  for (i in 1:nrow(ch2$hull)) {
    message("Range of all points in ch1")
    proj1 <- range(colSums(t(ps1) * ch2$normals[i,1:d]) + ch2$normals[i,d + 1])
    print(proj1)
    message("Range of all points in ch2")
    proj2 <- range(colSums(t(ps2) * ch2$normals[i,1:d]) + ch2$normals[i,d + 1])
    print(proj2)
    if ((max(proj1) <= min(proj2)) | (max(proj2) <= min(proj1))) {
      message("No overlap")
      return(TRUE)
    }
  }
  return(FALSE)
}

##' @export
feasible.point <- function(ps1, ps2) {
  ## Make sure all coordinates are positive
  pmin <- apply(rbind(ps1, ps2), 2, min)
  ps1 <- t(t(ps1) - pmin)
  ps2 <- t(t(ps2) - pmin)
  ch1 <- convhulln(ps1, "n")
  ch2 <- convhulln(ps2, "n")
  d <- ncol(ps1)
  n1 <- nrow(ch1$hull)
  n2 <- nrow(ch2$hull)
  
  Amat <- matrix(NA, 2*(n1 + n2), d)
  bvec <- rep(NA, 2*(n1 + n2))
  Dmat <- matrix(0, d, d)
  dvec <- rep(0, d)
  message("Normals of ch1")
  for (i in 1:n1) {
    message("Range of all points in ch1")
    proj1 <- range(colSums(t(ps1) * ch1$normals[i,1:d]))
    print(proj1)
    message("Range of all points in ch2")
    proj2 <- range(colSums(t(ps2) * ch1$normals[i,1:d]))
    print(proj2)
    if ((max(proj1) <= min(proj2)) | (max(proj2) <= min(proj1))) {
      message("No overlap")
      return(NA)
    }
    ## Normals point outwards. Inside convhull it is true that
    ## r dot n + d <=0 , i.e. r dot n <= -d
    ##
    ## The maxium project of the convex hull onto its normal is
    ## therefore 0. If there is overlap with the second hull, the
    ## projection d2 onto the normal will be negative. To have points
    ## that have a more positive projection we need:
    ##
    ## r dot n >= d2
    ## 
    ## or
    ##
    ## r dot -n <= -d2
    ## The feasible point has to be in the convex hull itself
    ## FIXME - put in epsilon?
    Amat[2*i-1,] <- ch1$normals[i,1:d]
    bvec[2*i-1]  <- -ch1$normals[i,d+1]
    Dmat <- Dmat + outer(ch1$normals[i,1:d], ch1$normals[i,1:d])
    dvec <- dvec + ch1$normals[i,1:d] * ch1$normals[i,d+1]
    ## The feasible point has to lie withing the projection of the second 
    Amat[2*i,]   <- -ch1$normals[i,1:d]
    bvec[2*i]    <- -min(proj2)
    Dmat <- Dmat + outer(ch2$normals[i,1:d], ch2$normals[i,1:d])
    dvec <- dvec + ch2$normals[i,1:d] * ch2$normals[i,d+1]
  }
  message("Normals of ch2")
  for (i in 1:n2) {
    message("Range of all points in ch1")
    proj1 <- range(colSums(t(ps1) * ch2$normals[i,1:d]))
    print(proj1)
    message("Range of all points in ch2")
    proj2 <- range(colSums(t(ps2) * ch2$normals[i,1:d]))
    print(proj2)
    if ((max(proj1) <= min(proj2)) | (max(proj2) <= min(proj1))) {
      message("No overlap")
      return(NA)
    }
    Amat[2*n1 + 2*i - 1,] <- ch2$normals[i,1:d]
    bvec[2*n1 + 2*i - 1]  <- -ch2$normals[i,d+1]
    ## The feasible point has to lie withing the projection of the second 
    Amat[2*n1 + 2*i,]   <- -ch2$normals[i,1:d]
    bvec[2*n1 + 2*i]    <- -min(proj1)
  }
  xmax <- linprog::solveLP(cve=c(1, 1), bvec=bvec, Amat=Amat, maximum=TRUE)$solution
  xmin <- linprog::solveLP(cve=c(1, 1), bvec=bvec, Amat=Amat, maximum=FALSE)$solution
  print("xmax")
  print(xmax)
  print("xmin")
  print(xmin)
  print("pmin")
  print(pmin)
  print(rbind(xmax + pmin, xmin + pmin))
  fp <- colMeans(rbind(xmax + pmin, xmin + pmin))
  fp <- quadprog::solve.QP(Dmat=Dmat, dvec=dvec, Amat=t(Amat), bvec=bvec)
  print(fp)
  print(paste(n1, n2))
  return(list(Amat=Amat, bvec=bvec, Dmat=Dmat, dvec=dvec, ch1=ch1, ch2=ch2, fp=fp))
  
}


##' @export
feasible.point1 <- function(ps1, ps2) {
  ## Make sure all coordinates are positive
  ch1 <- convhulln(ps1, "n")
  ch2 <- convhulln(ps2, "n")
  d <- ncol(ps1)
  n1 <- nrow(ch1$hull)
  n2 <- nrow(ch2$hull)
  
  Amat <- matrix(NA, n1 + n2, d)
  bvec <- rep(NA, n1 + n2)
  Dmat <- matrix(0, d, d)
  dvec <- rep(0, d)
  message("Normals of ch1")
  for (i in 1:n1) {
    ## Normals point outwards. Inside convhull it is true that
    ## r dot n + d <=0 , i.e. r dot n <= -d
    ##
    ## The maxium project of the convex hull onto its normal is
    ## therefore 0. If there is overlap with the second hull, the
    ## projection d2 onto the normal will be negative. To have points
    ## that have a more positive projection we need:
    ##
    ## r dot n >= d2
    ## 
    ## or
    ##
    ## r dot -n <= -d2
    ## The feasible point has to be in the convex hull itself
    ## FIXME - put in epsilon?
    Amat[i,] <-  ch1$normals[i,1:d]
    bvec[i]  <- -ch1$normals[i,d+1]
    ## Want to minimise the sum of squares of distances from the
    ## feasible point to the hyperplanes of each side
    ## For each side this is ( r dot n + d )^2
    Dmat <- Dmat + outer(ch1$normals[i,1:d], ch1$normals[i,1:d])
    dvec <- dvec + ch1$normals[i,1:d]*ch1$normals[i,d+1]
  }
  message("Normals of ch2")
  for (i in 1:n2) {
    Amat[n1 + i,] <- ch2$normals[i,1:d]
    bvec[n1 + i] <- -ch2$normals[i,d+1]
    Dmat <- Dmat + outer(ch2$normals[i,1:d], ch2$normals[i,1:d])
    dvec <- dvec + ch2$normals[i,1:d]*ch2$normals[i,d+1]
  }
  fp <- quadprog::solve.QP(Dmat=Dmat, dvec=-dvec, Amat=t(-Amat), bvec=-bvec)$solution
  ## fp <- NULL
  return(list(Amat=-Amat, bvec=-bvec, Dmat=Dmat, dvec=dvec, ch1=ch1, ch2=ch2, fp=fp))
  
}



##' @method plot intersectn
##' @export 
plot.intersectn <- function(x, y, ...) {
  args <- list(...)
  add <- FALSE
  if ("add" %in% names(args)) {
    add <- args$add
    args$add <- NULL
  }
  xlim <- ylim <- NULL
  if ("xlim" %in% names(args)) {
    xlim <- args$xlim
    args$xlim <- NULL
  }
  if ("ylim" %in% names(args)) {
    ylim <- args$ylim
    args$xlim <- NULL
  }
  if (ncol(x$p) == 2) {
    if (!add) {
      p <- rbind(x$ch1$p, x$ch2$p)
      if (is.null(xlim)) xlim <- range(p[,1])
      if (is.null(ylim)) ylim <- range(p[,2])
      plot.new()
      do.call(plot.window, c(list(xlim=xlim, ylim=ylim), args))
    }
    plot(x$ch1, add=TRUE, lty=2)
    plot(x$ch2, add=TRUE, lty=2)
    plot(x$ch, add=TRUE, lwd=2)
  }
}


