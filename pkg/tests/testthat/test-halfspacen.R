context("halfspacen")
test_that("halfspacen works on a cube", {
  ## Cube with unit length edges, centred on the origin
  ps <- rbox(0, C=0.5)
  ## Convex hull. When "n" is specified normals should be returned
  ch <- convhulln(ps, "n")
  ## Intersections of half planes
  ## These points should be the same as the orginal points
  pn <- halfspacen(ch$normals, c(0, 0, 0))

  ## Convex hull of these points should have same characteristics as original cube
  ts <- convhulln(pn, "FA")
  expect_equal(length(ts), 3)
  expect_equal(ts$area, 6)
  expect_equal(ts$vol, 1)

  ## If the feasible point is outwith the normlas to the cube, an
  ## error should be thrown
  expect_error(halfspacen(ch$normals, c(1, 1, 1)))
  
})

test_that("convhulln can run on an example with 3000 points", {
  set.seed(1)
  ps <- matrix(rnorm(3000), ncol=3)
  ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1,3)))
  ch <- convhulln(ps, "n FA")

  pn <- halfspacen(ch$normals, c(0, 0, 0))
  chn <- convhulln(pn, "n FA")

  
  expect_equal(ch$area, chn$area)
  expect_equal(ch$vol, chn$vol)
})


