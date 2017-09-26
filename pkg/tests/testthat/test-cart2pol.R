context("cart2pol")
test_that("cart2pol works correctly", {
  x <- c(0, 1, 2)
  y <- 0
  P <- cart2pol (x, y)
  expect_equal (P[,"theta"], c(0, 0, 0))
  expect_equal (P[,"r"], x)

  x <- c(0, 1, 2)
  y <- c(0, 1, 2)
  P <- cart2pol(x, y)
  expect_equal (P[,"theta"], c(0, pi/4, pi/4))
  expect_equal (P[,"r"], sqrt (2)*c(0, 1, 2))

  x <- c(0, 1, 2)
  y <- c(0, 1, 2)
  z <- c(0, 1, 2)
  P <- cart2pol (x, y, z)
  expect_equal (P[,"theta"], c(0, pi/4, pi/4))
  expect_equal (P[,"r"], sqrt (2)*c(0, 1, 2))
  expect_equal (P[,"z"], z)

  x <- c(0, 1, 2)
  y <- 0
  z <- 0
  P <- cart2pol (x, y, z)
  expect_equal (P[,"theta"], c(0, 0, 0))
  expect_equal (P[,"r"], x)
  expect_equal (P[,"z"], c(0, 0, 0))

  x <- 0
  y <- c(0, 1, 2)
  z <- 0
  P <- cart2pol (x, y, z)
  expect_equal (P[,"theta"], c(0, 1, 1)*pi/2)
  expect_equal (P[,"r"], y)
  expect_equal (P[,"z"], c(0, 0, 0))

  x <- 0
  y <- 0
  z <- c(0, 1, 2)
  P <- cart2pol (x, y, z)
  expect_equal (P[,"theta"], c(0, 0, 0))
  expect_equal (P[,"r"], c(0, 0, 0))
  expect_equal (P[,"z"], z)

  C <- rbind(c(x=0, y=0), c(1, 1), c( 2, 2))
  P <- rbind(c(theta=0, r=0), c(pi/4, sqrt(2)), c(pi/4, 2*sqrt(2)))
  expect_equal(cart2pol(C), P)

## %!test
## %! C <- c(0, 0, 0 1, 1, 1 2, 2, 2)
## %! P <- c(0, 0, 0 pi/4, sqrt(2), 1 pi/4, 2*sqrt(2), 2)
## %! expect_equal (cart2pol (C), P)

## %!test
## %! x <- zeros (1, 1, 1, 2)
## %! x(1, 1, 1, 2) <- sqrt (2)
## %! y <- x
## %! c(P[,"theta"], r) <- cart2pol (x, y)
## %! T <- zeros (1, 1, 1, 2)
## %! T(1, 1, 1, 2) <- pi/4
## %! R <- zeros (1, 1, 1, 2)
## %! R(1, 1, 1, 2) <- 2
## %! expect_equal (P[,"theta"], T)
## %! expect_equal (P[,"r"], R)

## %!test
## %! c(x, y, Z) <- meshgrid (c(0, 1), c(0, 1), c(0, 1))
## %! c(t, r, z) <- cart2pol (x, y, Z)
## %! T(:, :, 1) <- c(0, 0 pi/2, pi/4)
## %! T(:, :, 2) <- T(:, :, 1)
## %! R <- sqrt (x.^2 + y.^2)
## %! expect_equal (t, T)
## %! expect_equal (P[,"r"], R)
## %! expect_equal (z, Z)

  ## Test input validation
  expect_error(cart2pol())
  expect_error(cart2pol(1,2,3,4))
  expect_error(cart2pol(list(1,2,3)), regexp="input must be matrix with 2 or 3 columns")
## expect_error <matrix input must have 2 or 3 columns> cart2pol (ones (3,3,2))
## expect_error <matrix input must have 2 or 3 columns> cart2pol (c(1))
## expect_error <matrix input must have 2 or 3 columns> cart2pol (c(1,2,3,4))
## expect_error <numeric arrays of the same size> cart2pol ({1,2,3}, c(1,2,3))
## expect_error <numeric arrays of the same size> cart2pol (c(1,2,3), {1,2,3})
## expect_error <numeric arrays of the same size> cart2pol (ones (3,3,3), ones (3,2,3))
## expect_error <numeric arrays of the same size> cart2pol ({1,2,3}, c(1,2,3), c(1,2,3))
## expect_error <numeric arrays of the same size> cart2pol (c(1,2,3), {1,2,3}, c(1,2,3))
## expect_error <numeric arrays of the same size> cart2pol (c(1,2,3), c(1,2,3), {1,2,3})
## expect_error <numeric arrays of the same size> cart2pol (ones (3,3,3), 1, ones (3,2,3))
## expect_error <numeric arrays of the same size> cart2pol (ones (3,3,3), ones (3,2,3), 1)
})
