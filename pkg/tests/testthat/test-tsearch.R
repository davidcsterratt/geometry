context("tsearch")
test_that("tsearch gives the expected output", {
  x <- c(-1, -1, 1)
  y <- c(-1, 1, -1)
  p <- cbind(x, y)
  tri <- matrix(c(1, 2, 3), 1, 3)
  ## Should be in triangle #1
  ts <- tsearch(x, y, tri, -1, -1)
  expect_that(ts, equals(1))
  ## Should be in triangle #1
  ts <- tsearch(x, y, tri, 1, -1)
  expect_that(ts, equals(1))
  ## Should be in triangle #1
  ts <- tsearch(x, y, tri, -1, 1)
  expect_that(ts, equals(1))
  ## Centroid
  ts <- tsearch(x, y, tri, -1/3, -1/3)
  expect_that(ts, equals(1))
  ## Should be outside triangle #1, so should return NA
  ts <- tsearch(x, y, tri, 1, 1)
  expect_true(is.na(ts))
})

test_that("tsearch can deal with faulty input", {
  x <- c(-1, -1, 1)
  y <- c(-1, 1, -1)
  p <- cbind(x, y)
  tri <- matrix(c(1, 2, 3), 1, 3)

  ## NULLs and NAs
  ## expect_error(tsearch(x, y, tri, NA, NA))
  expect_error(tsearch(x, y, NA, -1, 1))
  expect_error(tsearch(NA, NA, tri, -1, 1))
  expect_error(tsearch(x, y, tri, NULL, NULL))
  expect_error(tsearch(x, y, NULL, -1, 1))
  expect_error(tsearch(NULL, NULL, tri, -1, 1))

  ## Wrong number of columns
  expect_error(tsearch(p, 0, tri, -1, 1))

  ## Non-integer triangulation
  expect_error(tsearch(x, y, matrix(runif(15), 5, 3), -1, 1), regexp="does not have integer elements")

  ## Wrong number of columns in triangulation
  expect_error(tsearch(x, y, matrix(1:4, 4, 2), -1, 1))

  ## Mismatch in x and y lengths
  expect_error(tsearch(x, y[-1], tri, -1, 1))

  ## Mismatch in xi and yi lengths
  expect_error(tsearch(x, y, tri, c(-1, 1), 1))

  ## A subtle one! This gives numeric(0) as the final arguments and
  ## should give idx with no elements and a 0x3 matrix for p
  ps <- matrix(0, 0, 2)
  expect_equal(tsearch(x, y, tri, ps[,1], ps[,2], bary=TRUE),
               list(idx=integer(0), p=matrix(0, 0, 3)))
  
})

## See
## http://totologic.blogspot.co.uk/2014/01/accurate-point-in-triangle-test.html
## for inspiration for the test below

test_that("tsearch gives the expected output when computer precision problem arise", {
  
  # ==== Hand made test ====
  
  x1 <- 1/10
  y1 <- 1/9
  x2 <- 100/8
  y2 <- 100/3
  P <- rbind(c(x1, y1),  c(x2, y2),  c(100/4, 100/9), c(-100/8, 100/6))
  
  # And a single point p(x, y) lying exactly on the segment [p1, p2] :
  xi <- x1 + (3/7)*(x2 - x1)
  yi <- y1 + (3/7)*(y2 - y1)
  
  # Should always give triangle 2 since this is the lastest tested
  
  tri1 <- rbind(1:3, c(1, 2, 4))
  ts <- tsearch(P[,1], P[,2], tri1, xi, yi)
  expect_equal(ts, 2)
  
  tri2 <- rbind(c(1, 2, 4), 1:3)
  ts <- tsearch(P[,1], P[,2], tri2, xi, yi)
  expect_equal(ts, 2)
  
  # The same but with only one triangle
  P <- rbind(c(x1, y1),  c(x2, y2),  c(100/4, 100/9))
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(P[,1], P[,2], tri, xi, yi)
  expect_that(ts, equals(1))
  
  tri <- matrix(c(3, 2, 1), 1, 3)
  ts <- tsearch(P[,1], P[,2], tri, xi, yi)
  expect_that(ts, equals(1))
  
  # The same but with the other triangle
  P <- rbind(c(x2, y2),  c(100/4, 100/9), c(-100/8, 100/6))
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(P[,1], P[,2], tri, xi, yi)
  expect_that(ts, equals(1))
  
  tri <- matrix(c(3, 2, 1), 1, 3)
  ts <- tsearch(P[,1], P[,2], tri, xi, yi)
  expect_that(ts, equals(1))
  
  # Another test
  x <- c(6.89, 7.15, 7.03)
  y <- c(7.76, 7.75, 8.35)
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(x, y, tri, 7.125, 7.875)
  expect_that(ts, equals(1))
  
  # ==== Test known to bug in former code ====
  
  x <- c(278287.03, 278286.89, 278287.15, 278287.3)
  y <- c(602248.35, 602247.76, 602247.75, 602248.35)
  
  xi = 278287.125
  yi = 602247.875  
  
  # Should always give triangle 2 but here it does not work
  
  tri = rbind(c(3,1,4), c(3,1,2))
  ts <- tsearch(x, y, tri, xi, yi)
  expect_that(ts, equals(2))
  
  tri = rbind(c(1,2,3), c(1,3,4))
  ts <- tsearch(x, y, tri, xi, yi)
  expect_that(ts, equals(1))
  
  # This is because the buffer epsilon is 1.0e-12.
  
  x <- c(278287.03, 278287.15, 278287.3)
  y <- c(602248.35, 602247.75, 602248.35)
  
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(x, y, tri, xi, yi)
  expect_true(is.na(ts))
  
  #expect_that(ts, equals(1)))  #With epsilon = 1.0e-10 it works.
})
