context("cart2sph")
test_that("cart2sph works correctly", {
  x <- c(0, 1, 2)
  y <- c(0, 1, 2)
  z <- c(0, 1, 2)
  Ps <- cart2sph(x, y, z)
  expect_equal(Ps[,"theta"], c(0, pi/4, pi/4))
  expect_equal(Ps[,"phi"], c(0, 1, 1)*atan(sqrt(0.5)))
  expect_equal(Ps[,"r"], c(0, 1, 2)*sqrt(3))

  x <- 0
  y <- c(0, 1, 2)
  z <- c(0, 1, 2)
  Ps <- cart2sph(x, y, z)
  expect_equal(Ps[,"theta"], c(0, 1, 1)*pi/2)
  expect_equal(Ps[,"phi"], c(0, 1, 1)*pi/4)
  expect_equal(Ps[,"r"], c(0, 1, 2)*sqrt(2))

  x <- c(0, 1, 2)
  y <- 0
  z <- c(0, 1, 2)
  Ps <- cart2sph(x, y, z)
  expect_equal(Ps[,"theta"], c(0, 0, 0))
  expect_equal(Ps[,"phi"], c(0, 1, 1)*pi/4)
  expect_equal(Ps[,"r"], c(0, 1, 2)*sqrt(2))

  x <- c(0, 1, 2)
  y <- c(0, 1, 2)
  z <- 0
  Ps <- cart2sph(x, y, z)
  expect_equal(Ps[,"theta"], c(0, 1, 1)*pi/4)
  expect_equal(Ps[,"phi"], c(0, 0, 0))
  expect_equal(Ps[,"r"], c(0, 1, 2)*sqrt(2))

  C <- rbind(c(0, 0, 0),
             c(1, 0, 1),
             c(2, 0, 2))
  S <- rbind(c(theta=0, phi=0, r=0),
             c(0, pi/4, sqrt(2)),
             c(0, pi/4, 2*sqrt(2)))
  expect_equal(cart2sph(C), S)
})


test_that("cart2sph error validation works correctly", {
  expect_error(cart2sph())
  expect_error(cart2sph(1,2))
  expect_error(cart2sph(1,2,3,4))
  expect_error(cart2sph(list(1, 2, 3)), regexp="input must be matrix with 3 columns")
  expect_error(cart2sph(array(1, c(3,3,2))), regexp="matrix input must have 3 columns")
  expect_error(cart2sph(cbind(1,2,3,4)), regexp=c("matrix input must have 3 columns"))
  expect_error(cart2sph(list(1,2,3), c(1,2,3), c(1,2,3)), regexp="numeric arrays of the same size")
  expect_error(cart2sph(c(1,2,3), list(1,2,3), c(1,2,3), regexp="numeric arrays of the same size"))
  expect_error(cart2sph(c(1,2,3), c(1,2,3), list(1,2,3)), regexp="numeric arrays of the same size")
  expect_error(cart2sph(array(1, c(3, 3, 3)), 1, array(1, c(3,3,2))), regexp="matrices of the same size")
  expect_error(cart2sph(array(1, c(3, 3, 3)), array(1, c(3,3,2)), 1), regexp="matrices of the same size")
})
