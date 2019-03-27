context("inhulln")
test_that("inhulln gives the expected output", {
  ## Basic test
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

  ## Erroneous input is caught safely
  expect_error(inhulln(1, 2), "Convex hull has no convhulln attribute")
  expect_error(inhulln(ch, rbind(1, 1)), "Number of columns in test points p (1) not equal to dimension of hull (2).", fixed=TRUE)
  expect_error(inhulln(ch, cbind(1, 1, 1)), "Number of columns in test points p (3) not equal to dimension of hull (2).", fixed=TRUE)
  
  ## Test cube
  p <- rbox(n=0, D=3, C=1)
  ch <- convhulln(p)
  tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0)
  pin <- inhulln(ch, tp)
  ## Points on x-axis should be in box only between -1 and 1
  expect_that(pin, equals(tp[,1] < 1 & tp[,1] > -1))

  ## Test hypercube
  p <- rbox(n=0, D=4, C=1)
  ch <- convhulln(p)
  tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0, 0)
  pin <- inhulln(ch, tp)
  ## Points on x-axis should be in box only between -1 and 1
  expect_that(pin, equals(tp[,1] < 1 & tp[,1] > -1))

})
