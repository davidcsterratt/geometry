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

test_that("tsearch gives the expected output when computer precision problem arise", {
  ## http://totologic.blogspot.co.uk/2014/01/accurate-point-in-triangle-test.html

  x1 <- 1/10
  y1 <- 1/9
  x2 <- 100/8
  y2 <- 100/3
  ## x3 = 100/4
  ## y3 = 100/9
  ## x1p = x1
  ## y1p = y1
  ## x2p = x2
  ## y2p = y2
  ## x3p = -100/8
  ## y3p = 100/6

  P <- rbind(c(x1, y1),
             c(x2, y2),
             c(100/4, 100/9),
             c(-100/8, 100/6))
  ## and a single point p(x, y) lying exactly on the segment [p1, p2] :
  xi <- x1 + (3/7)*(x2 - x1)
  yi <- y1 + (3/7)*(y2 - y1)

  tri1 <- rbind(1:3, c(1, 2, 4))
  tsearch(P[,1], P[,2], tri1, xi, yi)

  tri2 <- rbind(c(1, 2, 4), 1:3)
  tsearch(P[,1], P[,2], tri2, xi, yi)
})

## test_that("tsearch gives the expected output when computer precision problem arise", {
##   x <- c(6.89, 7.15, 7.03)
##   y <- c(7.76, 7.75, 8.35)
##   tri <- matrix(c(1, 2, 3), 1, 3)
##   ts <- tsearch(x, y, tri, 7.125, 7.875)
##   expect_that(ts, equals(1))

##   x <- c(278287.03, 278286.89, 278287.15)
##   y <- c(602248.35, 602247.76, 602247.75)

##   tri = matrix(c(1,2,3), 1,3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))

##   tri = matrix(c(3,2,1), 1,3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))
##   tri = matrix(c(2,3,1), 1,3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))

##   tri = matrix(c(2,1,3), 1,3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))

##   tri = matrix(c(3,1,2), 1,3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))

##   tri <- matrix(c(1, 2, 3), 1, 3)
##   ts <- tsearch(x, y, tri, 278287.125, 602247.875)
##   expect_that(ts, equals(1))
## })
