context("delaunayn")
test_that("delaunayn produces the correct output", {
  ## Create points that, when passed to Qhull with the Qt option,
  ## would give degenerate simplices - thanks to Bill Denney for
  ## example
  ps <- as.matrix(rbind(data.frame(a=0, b=0, d=0),
                        merge(merge(data.frame(a=c(-1, 1)),
                                    data.frame(b=c(-1, 1))),
                              data.frame(d=c(-1, 1)))))
  ts <- delaunayn(ps)
  expect_type(ts, "integer")
  expect_identical(dim(ts), c(12L, 4L))

  ## With output.options=TRUE, there should be a trinagulation, areas and
  ## neighbours and the sum of the ares should be 8
  ts.full <- delaunayn(ps, output.options=TRUE)
  expect_equal(ts, ts.full$tri, check.attributes=FALSE)
  expect_equal(length(ts.full$areas), nrow(ts.full$tri))
  expect_equal(length(ts.full$neighbours), nrow(ts.full$tri))
  expect_equal(sum(ts.full$area), 8)

  ## With full output, there should be a trinagulation, areas and
  ## neighbours and the sum of the ares should be 8
  ## full will be deprecated in a future version
  ts.full <- delaunayn(ps, full=TRUE)
  expect_equal(ts, ts.full$tri, check.attributes=FALSE)
  expect_equal(length(ts.full$areas), nrow(ts.full$tri))
  expect_equal(length(ts.full$neighbours), nrow(ts.full$tri))
  expect_equal(sum(ts.full$area), 8)

  ## tsearchn shouldn't return a "degnerate simplex" error.
  expect_silent(tsearchn(ps, ts, cbind(1, 2, 4)))

  ## If the input matrix contains NAs, delaunayn should return an error
  ps <- rbind(ps, NA)
  expect_error(delaunayn(ps))

})

test_that("In the case of just one triangle, delaunayn returns a matrix", {
  pc  <- rbind(c(0, 0), c(0, 1), c(1, 0))
  pct <- delaunayn(pc)
  expect_type(pct, "integer")
  expect_identical(dim(pct), c(1L, 3L))
  ## With no options it should also produce a triangulation. This
  ## mirrors the behaviour of octave and matlab
  pct <- delaunayn(pc, "")
  expect_type(pct, "integer")
  expect_identical(dim(pct), c(1L, 3L))

  pct.full <- delaunayn(pc, output.options=TRUE)
  expect_equal(pct.full$areas, 0.5)
})

test_that("In the case of a degenerate triangle, delaunayn returns a matrix with zero rows", {
  pc  <- rbind(c(0, 0), c(0, 1), c(0, 2))
  pct <- delaunayn(pc)
  expect_type(pct, "integer")
  expect_identical(dim(pct), c(0L, 3L))
  pct.full <- delaunayn(pc, output.options=TRUE)
  expect_equal(length(pct.full$areas), 0)
  expect_equal(length(pct.full$neighbours), 0)
})

test_that("In the case of just one tetrahaedron, delaunayn returns a matrix", {
  pc  <- rbind(c(0, 0, 0), c(0, 1, 0), c(1, 0, 0), c(0, 0, 1))
  pct <- delaunayn(pc)
  expect_type(pct, "integer")
  expect_identical(dim(pct), c(1L, 4L))
  pct.full <- delaunayn(pc, output.options=TRUE)
   expect_equal(pct.full$areas, 1/6)
})

test_that("Output to file works", {
  ps <-  matrix(rnorm(3000), ncol=3)
  ps <-  sqrt(3)*ps/drop(sqrt((ps^2) %*% rep(1, 3)))
  fname <- path.expand(file.path(tempdir(), "test1.txt"))
  pst <- delaunayn(ps, paste0("QJ TO '", fname, "'"))
  expect_true(file.exists(fname))
})

test_that("The QJ option can give degenerate simplices", {
  ## Create degenerate simplex - thanks to Bill Denney for example
  ps <- as.matrix(rbind(data.frame(a=0, b=0, d=0),
                        merge(merge(data.frame(a=c(-1, 1)),
                                    data.frame(b=c(-1, 1))),
                              data.frame(d=c(-1, 1)))))

  ## The QJ option leads to on simplex being very small
  ts <- delaunayn(ps, "QJ")
  expect_warning(tsearchn(ps, ts, cbind(1, 2, 4)))
})

test_that("A square is triangulated", {
  ## This doesn't work if the Qz option isn't supplied
  square <- rbind(c(0, 0), c(0, 1), c(1, 0), c(1, 1))
  expect_equal(delaunayn(square), rbind(c(4, 2, 1),
                                        c(4, 3, 1)),
               check.attributes=FALSE)
  expect_error(delaunayn(square, ""), "QH6239 Qhull precision error: initial Delaunay input sites are cocircular or cospherical")
})

test_that("No regression on issue 11: All points in a box far from the origin are triangulated", {
  ## Generate set of randomly generated points in a 40 unit square,
  ## 250,000 from the origin
  set.seed(2)
  p <- geometry::rbox(4000, D=2, 20) + 250000

  ## Triangulate
  t <- delaunayn(p)

  ## Count how many of the points aren't in the triangulation - should be zero
  expect_equal(length(setdiff(seq(1,nrow(p)), unique(c(t[,1], t[,2], t[,3])))),
               0)

  ## Plotting: in the plot below, untriangulated points appear in red
  ## Basted on Jean-Romain's example in https://github.com/davidcsterratt/geometry/issues/11
  ## x <- p[,1]
  ## y <- p[,2]
  ## plot(x, y, cex = 0.1, col = "red")
  ## trimesh(t, x, y, add = T)
})

test_that("No regression on issue 12: All points in a small box with different x and y distances to the origin are triangulated", {
  ## Generate set of randomly generated points in a 40 unit square,
  ## with x distance of 5E5 from the origin and y distance 5E6 from
  ## the orgin. Note that the mean x and y values relative to the
  ## width of the window are quite different to each other.
  set.seed(2)
  p <- geometry::rbox(4000, D=2, 20) + 5E5
  p[,2] <- p[,2] + 5E6

  ## Expect warnings without the correct options
  expect_warning(delaunayn(p), "points missing from triangulation")
  expect_warning(delaunayn(p, options="Qt Qc Qz Qbb"), "points missing from triangulation")
  expect_warning(delaunayn(p, options="Qt Qc Qz QbB"), "points missing from triangulation")

  ## Centring the points does allow triangulation
  p.centred <- cbind(p[,1] - mean(p[,1]),
                     p[,2] - mean(p[,2]))
  delaunayn(p.centred)
})
