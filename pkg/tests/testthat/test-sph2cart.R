context("sph2cart")
test_that("sph2cart works correctly", {
  t <- c(0, 0, 0)
  p <- c(0, 0, 0)
  r <- c(0, 1, 2)
  C <- sph2cart (t, p, r)
  expect_equal(C[,"x"], r)
  expect_equal(C[,"y"], c(0, 0, 0))
  expect_equal(C[,"z"], c(0, 0, 0))

  t <- 0
  p <- c(0, 0, 0)
  r <- c(0, 1, 2)
  C <- sph2cart(t, p, r)
  expect_equal(C[,"x"], r)
  expect_equal(C[,"y"], c(0, 0, 0))
  expect_equal(C[,"z"], c(0, 0, 0))

  t <- c(0, 0, 0)
  p <- 0
  r <- c(0, 1, 2)
  C <- sph2cart (t, p, r)
  expect_equal(C[,"x"], r)
  expect_equal(C[,"y"], c(0, 0, 0))
  expect_equal(C[,"z"], c(0, 0, 0))

  t <- c(0, 0.5, 1)*pi
  p <- c(0, 0, 0)
  r <- 1
  C <- sph2cart(t, p, r)
  expect_equal(C[,"x"], c(1, 0, -1))
  expect_equal(C[,"y"], c(0, 1, 0))
  expect_equal(C[,"z"], c(0, 0, 0))

  C <- sph2cart(c(0, 0, 0), 0, 1)
  expect_equal(C[,"x"], c(1, 1, 1))
  expect_equal(C[,"y"], c(0, 0, 0))
  expect_equal(C[,"z"], c(0, 0, 0))

  S <- rbind(c(0, 0, 1),
             c(0.5*pi, 0, 1),
             c(pi, 0, 1))
  C <- rbind(c(x=1, y=0, z=0),
             c(0, 1, 0),
             c(-1, 0, 0))
  expect_equal(sph2cart(S), C)
})
  
# FIXME: to implement
#! c(t, p, r) <- meshgrid (c(0, pi/2), c(0, pi/2), c(0, 1))
#! c(x, y, z) <- sph2cart (t, p, r)
#! X <- zeros(2, 2, 2)
#! X(1, 1, 2) <- 1
#! Y <- zeros(2, 2, 2)
#! Y(1, 2, 2) <- 1
#! Z <- zeros(2, 2, 2)
#! Z(2, :, 2) <- c(1 1)
#! expect_equal(x, X, eps)
#! expect_equal(y, Y, eps)
#! expect_equal(z, Z)
  
test_that("sph2cart error validation works correctly", {
  expect_error(sph2cart())
  expect_error(sph2cart(1,2))
  expect_error(sph2cart(1,2,3,4))
  expect_error(sph2cart(list(1, 2, 3)), regexp="input must be matrix with 3 columns")
  expect_error(sph2cart(array(1, c(3,3,2))), regexp="matrix input must have 3 columns")
  expect_error(sph2cart(cbind(1,2,3,4)), regexp=c("matrix input must have 3 columns"))
  expect_error(sph2cart(list(1,2,3), c(1,2,3), c(1,2,3)), regexp="numeric arrays of the same size")
  expect_error(sph2cart(c(1,2,3), list(1,2,3), c(1,2,3), regexp="numeric arrays of the same size"))
  expect_error(sph2cart(c(1,2,3), c(1,2,3), list(1,2,3)), regexp="numeric arrays of the same size")
  expect_error(sph2cart(array(1, c(3, 3, 3)), 1, array(1, c(3,3,2))), regexp="matrices of the same size")
  expect_error(sph2cart(array(1, c(3, 3, 3)), array(1, c(3,3,2)), 1), regexp="matrices of the same size")
})


