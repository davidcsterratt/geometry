context("convhulln")
test_that("convhulln works on a cube", {
  ## Cube with unit length edges, centred on the origin
  ps <- rbox(0, C=0.5)
  ts <- convhulln(ps)
  ## Expect 12 facets, since faceted output is produced by default
  expect_equal(nrow(ts), 12)
  ## When "FA" is specified area and volume should be returned
  ts <- convhulln(ps, "FA")
  expect_equal(length(ts), 4)
  expect_equal(ts$area, 6)
  expect_equal(ts$vol, 1)
  ## When "n" is specified normals should be returned
  ts <- convhulln(ps, "n")
  expect_equal(length(ts), 3)
  ## There are 12 normals, one for each facet. There are 6 *unique*
  ## normals, since for each face of the cube there are two triangular
  ## facets with the same normal
  expect_equal(ts$normals,
               rbind(c(  0,   0,   -1, -0.5),
                     c(  0,   0,   -1, -0.5),
                     c(  0,  -1,    0, -0.5),
                     c(  0,  -1,    0, -0.5),
                     c(  1,   0,    0, -0.5),
                     c(  1,   0,    0, -0.5),
                     c( -1,   0,    0, -0.5),
                     c( -1,   0,    0, -0.5),
                     c(  0,   1,    0, -0.5),
                     c(  0,   1,    0, -0.5),
                     c(  0,   0,    1, -0.5),
                     c(  0,   0,    1, -0.5)))

})

test_that("convhulln works on a cube with output.options", {
  ## Cube with unit length edges, centred on the origin
  ps <- rbox(0, C=0.5)
  ts <- convhulln(ps)
  ## Expect 12 facets, since faceted output is produced by default
  expect_equal(nrow(ts), 12)
  ## When "FA" is specified area and volume should be returned
  ts <- convhulln(ps, output.options="FA")
  expect_equal(length(ts), 4)
  expect_equal(ts$area, 6)
  expect_equal(ts$vol, 1)
  ## When "n" is specified normals should be returned
  ts <- convhulln(ps, output.options="n")
  expect_equal(length(ts), 3)
  ## There are 12 normals, one for each facet. There are 6 *unique*
  ## normals, since for each face of the cube there are two triangular
  ## facets with the same normal
  expect_equal(ts$normals,
               rbind(c(  0,   0,   -1, -0.5),
                     c(  0,   0,   -1, -0.5),
                     c(  0,  -1,    0, -0.5),
                     c(  0,  -1,    0, -0.5),
                     c(  1,   0,    0, -0.5),
                     c(  1,   0,    0, -0.5),
                     c( -1,   0,    0, -0.5),
                     c( -1,   0,    0, -0.5),
                     c(  0,   1,    0, -0.5),
                     c(  0,   1,    0, -0.5),
                     c(  0,   0,    1, -0.5),
                     c(  0,   0,    1, -0.5)))


  ts <- convhulln(ps, output.options=TRUE)
  expect_equal(length(ts), 5)
})


test_that("convhulln can run on an example with 3000 points", {
  set.seed(1)
  ps <- matrix(rnorm(3000), ncol=3)
  ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1,3)))
  ts <- convhulln(ps)
  expect_that(nrow(ts), equals(1996))
  ts.full <- convhulln(ps, "FA")
  expect_that(ts.full$area, equals(37.47065, tolerance=0.001))
  expect_that(ts.full$vol, equals(21.50165, tolerance=0.001))
})

test_that("convhulln throws an error with duplicated points", {
  load(file.path(system.file(package="geometry"), "extdata", "ordination.Rdata"))
  expect_error(out <- convhulln(ordination), "QH6114 qhull precision error: initial simplex is not convex")

})

test_that("If the input matrix contains NAs, convhulln should return an error", {
  ps <- matrix(rnorm(999), ncol=3)
  ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1,3)))
  ps <- rbind(ps, NA)
  expect_error(convhulln(ps))
})

test_that("If there are not enough points to construct a simplex, an error is thrown", {         
  expect_error(convhulln(diag(4)))
})

test_that("Output to file works", {
  ## To prevent regression in package betapart
  fname <- path.expand(file.path(tempdir(), "vert.txt"))
  unlink(fname)
  tr <- rbind(c(3,1),c(2,1),c(4,3),c(4,2))
  convhulln(tr, paste0("Fx TO '", fname, "'"))
  expect_true(file.exists(fname))
  vert <- scan(fname, quiet=TRUE)
  expect_equal(vert, c(4, 2, 1, 0, 3))
})

test_that("Output of non-triangulated facets works", {
  X1 <- matrix(c( 1,  1,  1, 
                  1,  1, -1,
                  1, -1,  1,
                  1, -1, -1,
                 -1,  1,  1,
                 -1,  1, -1,
                 -1, -1,  1,
                 -1, -1, -1, 
                  3,  0,  0), ncol=3, byrow = TRUE)
  ts1 <- convhulln(X1, return.non.triangulated.facets = TRUE)
  tbl1 <- table(rowSums(!is.na(ts1)))
  expect_equal(names(tbl1), c("3", "4"))
  expect_equal(as.numeric(tbl1), c(4, 5))
})
