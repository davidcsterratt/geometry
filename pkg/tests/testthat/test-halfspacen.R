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
  expect_equal(ts$area, 6)
  expect_equal(ts$vol, 1)

  ## If the feasible point is outwith the normlas to the cube, an
  ## error should be thrown
  expect_error(halfspacen(ch$normals, c(1, 1, 1)))
  
})

test_that("halfspacen works on a cube with non triangulated facets", {
  ## Cube with unit length edges, centred on the origin
  ps <- rbox(0, C=0.5)
  ## Convex hull. When "n" is specified normals should be returned
  ch <- convhulln(ps, "n", return.non.triangulated.facets=TRUE)
  ## Intersections of half planes
  ## These points should be the same as the orginal points
  pn <- halfspacen(ch$normals, c(0, 0, 0))

  ## Convex hull of these points should have same characteristics as original cube
  ts <- convhulln(pn, "FA")
  expect_equal(ts$area, 6)
  expect_equal(ts$vol, 1)

  ## If the feasible point is outwith the normlas to the cube, an
  ## error should be thrown
  expect_error(halfspacen(ch$normals, c(1, 1, 1)))
})

test_that("halfspacen can compute volume of intersection of halfspaces", {
  ## Cube with unit length edges, centred on the origin
  ps1 <- rbox(0, C=0.5)

  ## Cube with unit length edges, centred on the (0.5, 0.5, 0.5)
  ps2 <- rbox(0, C=0.5) + 0.5

  ## Convex hulls with normals
  ch1 <- convhulln(ps1, "n", return.non.triangulated.facets=TRUE)
  ch2 <- convhulln(ps2, "n", return.non.triangulated.facets=TRUE)

  ## Intersection of merged halfspaces
  pn <- halfspacen(rbind(ch1$normals, ch2$normals), c(0.25, 0.25, 0.25))

  ## Convex hull of these points should be cube with vertices at
  ## intersection of cubes, i.e. a cube of length 0.5
  ts <- convhulln(pn, "FA")
  expect_equal(ts$area, 6*0.5^2)
  expect_equal(ts$vol, 1*0.5^3)
})

test_that("halfspacen can do the round trip on an example with 3000 points",
{
  set.seed(1)
  ps <- matrix(rnorm(3000), ncol=3)
  ps <- sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1,3)))
  ch <- convhulln(ps, "n FA")
  
  pn <- halfspacen(ch$normals, c(0, 0, 0))
  chn <- convhulln(pn, "n FA")
  
  expect_equal(ch$area, chn$area)
  expect_equal(ch$vol, chn$vol)
})

test_that("halfspacen throws an error when the feasible point is not clearly inside the halfspace",
{
  load(file.path(system.file(package="geometry"), "extdata", "halfspacen.RData"))
  expect_error(halfspacen(normals, fp), "QH6023 qhull input error")
})

