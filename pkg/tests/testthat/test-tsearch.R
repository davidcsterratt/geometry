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
  x <- c(6.89, 7.15, 7.03)
  y <- c(7.76, 7.75, 8.35)
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(x, y, tri, 7.125, 7.875)
  expect_that(ts, equals(1))
  
  x <- c(278287.03, 278286.89, 278287.15)
  y <- c(602248.35, 602247.76, 602247.75)
  
  tri = matrix(c(1,2,3), 1,3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
  
  tri = matrix(c(3,2,1), 1,3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
  tri = matrix(c(2,3,1), 1,3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
  
  tri = matrix(c(2,1,3), 1,3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
  
  tri = matrix(c(3,1,2), 1,3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
  
  tri <- matrix(c(1, 2, 3), 1, 3)
  ts <- tsearch(x, y, tri, 278287.125, 602247.875)
  expect_that(ts, equals(1))
})
