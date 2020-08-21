context("polyarea")
test_that("ployarea computes the area of two identical squares", {
  x <- c(1, 1, 3, 3, 1)
  y <- c(1, 3, 3, 1, 1)

  expect_equal(polyarea(cbind(x, x), cbind(y, y)), c(4, 4))
  expect_equal(polyarea(cbind(x, x), cbind(y, y), 1), c(4, 4))
  expect_equal(polyarea(rbind(x, x), rbind(y, y), 2), c(4, 4))
})
