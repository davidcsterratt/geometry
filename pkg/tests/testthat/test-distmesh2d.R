context("distmesh2d")
test_that("distmesh2d can create a mesh on an ellipse", {
  bbox <- 2*matrix(c(-1,1,-1/2,1/2),2,2)
  ## Ellipse
  fd1 <- function(p,ra2=1/1.,rb2=1/2,xc2=0,yc2=0, ...){
    if (!is.matrix(p)) 
      p <- t(as.matrix(p))
    return(sqrt(((p[,1]-xc2)/ra2)^2+((p[,2]-yc2)/rb2)^2)-1)
  }
  ## Solve using distmesh2d()
  fh <- function(p,...)  rep(1,nrow(p))
  ## This is the original line, which throws a warning. New one does
  ## too, but runs faster p <-
  ## distmesh2d(fd=fd1,fh=fh,p=NULL,h0=0.05,bbox=bbox,maxiter=1000,
  ## plot=FALSE)
  expect_warning(p <- distmesh2d(fd=fd1,fh=fh,p=NULL,h0=0.05,bbox=bbox,maxiter=10, plot=FALSE))
})
