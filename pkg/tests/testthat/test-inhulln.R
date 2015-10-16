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

  ## Test cube
  p <- rbox(3, B=1)
  ch <- convhulln(p)
  tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0)
  pin <- inhulln(ch, tp)
  ## Points on x-axis should be in box only between -1 and 1
  expect_that(pin, equals(tp[,1] < 1 & tp[,1] > -1))

  ## Test hypercube
  p <- rbox(4, B=1)
  ch <- convhulln(p)
  tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0, 0)
  pin <- inhulln(ch, tp)
  ## Points on x-axis should be in box only between -1 and 1
  expect_that(pin, equals(tp[,1] < 1 & tp[,1] > -1))

})



