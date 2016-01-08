context("inhull")
test_that("inhulln gives the expected output", {
  x <- c(-1, -1, 1)
  y <- c(-1, 1, -1)
  p <- cbind(x, y)
  ch <- convhulln(p)
  ## Should be in hull
  pin <- inhulln(ch, cbind(-0.5, -0.5))
  expect_that(pin, equals(TRUE))
  ## Should be outside hull
  pout <- inhulln(ch, cbind(1, 1))
  expect_that(pout, equals(FALSE))
})



