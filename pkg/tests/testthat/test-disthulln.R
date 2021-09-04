context("disthulln")
test_that("disthulln gives the expected output", {
  ## Basic test
  x <- c(-1, -1, 1)
  y <- c(-1, 1, -1)
  p <- cbind(x, y)
  ch <- convhulln(p, "FA")

  ## Erroneous input is caught safely
  expect_error(disthulln(1, 2), "Convex hull has no convhulln attribute")
  expect_error(disthulln(ch, rbind(1, 1)), "Number of columns in test points p (1) not equal to dimension of hull (2).", fixed=TRUE)
  expect_error(disthulln(ch, cbind(1, 1, 1)), "Number of columns in test points p (3) not equal to dimension of hull (2).", fixed=TRUE)

  ## Should be in hull, hence negative distance
  dh <- disthulln(ch, cbind(-0.5, -0.5))
  expect_equal(dh$distances, -0.5)
  expect_equal(dh$intersections, c(0, 0))
  ## expect_setequal(ch$p[ch$hull[dh$idx]], c(0, 0))

  ## Should be outside hull
  dh <- disthulln(ch, cbind(1, 1))
  expect_equal(dh$distances, sqrt(2))
  expect_equal(dh$intersections, c(0, 0))


  ## Test cube
  ## p <- rbox(n=0, D=3, C=1)
  ## ch <- convhulln(p)
  ## tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0)
  ## pin <- disthulln(ch, tp)
  ## ## Points on x-axis should be in box only between -1 and 1
  ## expect_equal(pin, tp[,1] < 1 & tp[,1] > -1)

  ## ## Test hypercube
  ## p <- rbox(n=0, D=4, C=1)
  ## ch <- convhulln(p)
  ## tp <-  cbind(seq(-1.9, 1.9, by=0.2), 0, 0, 0)
  ## pin <- disthulln(ch, tp)
  ## ## Points on x-axis should be in box only between -1 and 1
  ## expect_equal(pin, tp[,1] < 1 & tp[,1] > -1)

})
