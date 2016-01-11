context("polyarea")
test_that("ployarea computes the area of two identical squares", {
  x <- c(1, 1, 3, 3, 1)
  y <- c(1, 3, 3, 1, 1)

  expect_that(polyarea(cbind(x, x), cbind(y, y)), equals(c(4, 4)))
  expect_that(polyarea(cbind(x, x), cbind(y, y), 1), equals(c(4, 4)))
  expect_that(polyarea(rbind(x, x), rbind(y, y), 2), equals(c(4, 4)))
})
