test_that("delaunayn produces the correct output", {
  ## Create points that, when passed to Qhull with the Qt option,
  ## would give degenerate simplices - thanks to Bill Denney for
  ## example
  ps <- as.matrix(rbind(data.frame(a=0, b=0, d=0),
                        merge(merge(data.frame(a=c(-1, 1)),
                                    data.frame(b=c(-1, 1))),
                              data.frame(d=c(-1, 1)))))
  ts <- delaunayn(ps)

  ## With full output, there should be a trinagulation, areas and
  ## neighbours and the sum of the ares should be 8
  ts.full <- delaunayn(ps, full=TRUE)
  expect_that(ts, equals(ts.full$tri))
  expect_that(length(ts.full$areas), equals(nrow(ts.full$tri)))
  expect_that(length(ts.full$neighbours), equals(nrow(ts.full$tri)))
  expect_that(sum(ts.full$area), equals(8))
  
  ## tsearchn shouldn't return a "degnerate simplex" error. 
  expect_that(tsearchn(ps, ts, cbind(1, 2, 4)), not(gives_warning("Degenerate simplices")))
})
