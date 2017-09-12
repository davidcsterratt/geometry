## Based on Octave tests for cross.m
## http://hg.savannah.gnu.org/hgweb/octave/file/c2ef0eddf6bc/scripts/linear-algebra/cross.m

context("extprod3d")
test_that("extprod3d gives the expected output", {
  
  x <- c(1, 0, 0)
  y <- c(0, 1, 0)
  r <- c(0, 0, 1)
  expect_equal(extprod3d(x, y), r)
  expect_equal(extprod3d(x, y, drop=FALSE), t(r))
  
  x <- c(1, 2, 3)
  y <- c(4, 5, 6)
  r <- c((2*6-3*5), (3*4-1*6), (1*5-2*4))
  expect_equal(extprod3d(x, y), r)

  x <- rbind(c(1, 0, 0),
             c(0, 1, 0),
             c(0, 0, 1))
  y <- rbind(c(0, 1, 0),
             c(0, 0, 1),
             c(1, 0, 0))
  r <- rbind(c(0, 0, 1),
             c(1, 0, 0),
             c(0, 1, 0))
  expect_equal(extprod3d(x, y), r)

  ##error extprod3d (0,0)
  ##error extprod3d ()
})



















