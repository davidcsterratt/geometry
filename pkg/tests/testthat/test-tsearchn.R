context("tsearchn")
test_that("tsearchn gives the expected output", {
  ## Simple example
  x <- c(-1, -1, 1)
  y <- c(-1, 1, -1)
  p <- cbind(x, y)
  tri <- matrix(c(1, 2, 3), 1, 3)
  ## Should be in triangle #1
  ts <- tsearchn(p, tri, cbind(-1, -1),fast=FALSE)
  expect_equal(ts$idx, 1)
  expect_equal(ts$p, cbind(1, 0, 0))
  ## Should be in triangle #1
  ts <- tsearchn(p, tri, cbind(1, -1), fast=FALSE)
  expect_equal(ts$idx, 1)
  expect_equal(ts$p, cbind(0, 0, 1))
  ## Should be in triangle #1
  ts <- tsearchn(p, tri, cbind(-1, 1), fast=FALSE)
  expect_equal(ts$idx, 1)
  expect_equal(ts$p, cbind(0, 1, 0))
  ## Centroid
  ts <- tsearchn(p, tri, cbind(-1/3, -1/3), fast=FALSE)
  expect_equal(ts$idx, 1)
  expect_equal(ts$p, cbind(1/3, 1/3, 1/3))
  ## Should be outside triangle #1, so should return NA
  ts <- tsearchn(p, tri, cbind(1, 1), fast=FALSE)
  expect_true(is.na(ts$idx))
  expect_true(all(is.na(ts$p)))

  ## Create a mesh with a zero-area element (degenerate simplex)
  p <- cbind(c(-1, -1, 0, 1, 2),
             c(-1,  1, 0, 0, 0))
  tri <- rbind(c(1, 2, 3),
               c(3, 4, 5))
  ## Look for one point in one of the simplices and a point outwith the
  ## simplices. This forces tsearchn to look in all simplices. It
  ## shouldn't fail on the degenerate simplex.
  expect_warning(ts <- tsearchn(p, tri, rbind(c(-0.5, 0), c(3, 1)), fast=FALSE))
  expect_equal(ts$idx, c(1, NA))
  ts <- tsearchn(p, tri, rbind(c(-0.5, 0), c(3, 1)), fast=TRUE)
  expect_equal(ts$idx, c(1, NA))
})



context("tsearchn_delaunayn")
test_that("tsearchn gives the expected output", {
  ## Erroneous input is caught safely. Force
  ## tsearchn_delaunayn to be called
  tfake <- matrix(1:3, 1, 3)
  class(tfake) <- "delaunayn"
  expect_error(suppressWarnings(tsearchn(NA, tfake, matrix(1:2, 1, 2))), "Delaunay triangulation has no delaunayn attribute")

  x <- cbind(c(-1, -1, 1),
             c(-1, 1, -1))

  dt <- delaunayn(x, output.options=TRUE)

  ## Should be in triangle #1
  xi <- cbind(-1, 1)
  expect_warning(ts <- tsearchn(NA, dt, xi))
  expect_equal(ts$idx, 1)
  expect_equal(bary2cart(x[dt$tri[ts$idx,],], ts$p), xi)

  ## Centroid
  xi <- cbind(-1/3, -1/3)
  expect_warning(ts <- tsearchn(NA, dt, xi))
  expect_equal(ts$idx, 1)
  expect_equal(ts$p, cbind(1/3, 1/3, 1/3))

  ## Should be outside triangle #1, so should return NA
  xi <- cbind(1, 1)
  expect_warning(ts <- tsearchn(NA, dt, xi))
  expect_true(is.na(ts$idx))
  expect_true(all(is.na(ts$p)))

  ## Check mutliple points work
  xi <- rbind(c(-1, 1),
              c(-1/3, -1/3))
  expect_warning(ts <- tsearchn(NA, dt, xi))
  expect_equal(ts$idx, c(1, 1))
  expect_equal(do.call(rbind, lapply(1:2, function(i) {
    bary2cart(x[dt$tri[ts$idx[i],],], ts$p[i,])
  })), xi)


  ## Test against original version
  p <- cbind(c(0, 0, 1, 1, 0.5),
             c(0, 1, 1, 0, 0.5))
  dt <- delaunayn(p, "FA") ## Interesting error, as default options are 'nixed
  dt <- delaunayn(p, output.options=TRUE)
  xi <- c(0.1, 0.5, 0.9, 0.5)
  yi <- c(0.5, 0.9, 0.5, 0.1)
  expect_warning(ts <- tsearchn(NA, dt, cbind(xi, yi)))
  expect_equal(ts$idx,
               tsearch(p[,1], p[,2], dt$tri,  xi, yi, method="orig"))

  ## 3D test
  x <- rbox(D=3, B=1)
  dt <- delaunayn(x, output.options=TRUE)

  xi <- rbind(c(0.5, 0.5, 0.5),
              c(-0.5, -0.5, -0.5),
              c(0.9, 0, 0))
  expect_warning(ts <- tsearchn(NA, dt, xi))
  expect_equal(do.call(rbind, lapply(1:3, function(i) {
    bary2cart(x[dt$tri[ts$idx[i],],], ts$p[i,])
  })), xi)

  ## 4D test
  ##
  ## This does not work yet. The "best" facet is not always the correct facet.
  ## x <- rbox(D=4, B=1)
  ## dt <- delaunayn(x, output.options=TRUE)

  ## xi <- rbind(c(0.5, 0.5, 0.5, 0.5),
  ##             c(-0.49, -0.49, -0.49, -0.49),
  ##             c(0.9, 0, 0, 0))
  ## ts <- tsearchn(dt, NA, xi)
  ## expect_equal(do.call(rbind, lapply(1:3, function(i) {
  ##   bary2cart(x[dt$tri[ts$idx[i],],], ts$p[i,])
  ## })), xi)
  
  ## We don't need to test when creating a mesh with a zero-area
  ## element (degenerate simplex), as these shouldn't be produced by
  ## qhull.

})


