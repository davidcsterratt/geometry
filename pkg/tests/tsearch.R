library(geometry)
x <- c(-1, -1, 1)
y <- c(-1, 1, -1)
tri <- matrix(c(1, 2, 3), 1, 3)
# Should be in triangle #1
tsearch(x, y, tri, -1, -1)
# Should be in triangle #1
tsearch(x, y, tri,  1, -1)
# Should be in triangle #1
tsearch(x, y, tri, -1, 1)
# Should be in triangle #1
tsearch(x, y, tri, -1/3, -1/3)
# Should be outside triangle #1, so should return NA
tsearch(x, y, tri, 1, 1)

## Create degenerate simplex - thanks to Bill Denney for example
ps <- as.matrix(rbind(data.frame(a=0, b=0, d=0),
                      merge(merge(data.frame(a=c(-1, 1)),
                                  data.frame(b=c(-1, 1))),
                            data.frame(d=c(-1, 1)))))

## The Qt option leads to the degnerate simplices
ts <- delaunayn(ps, "Qt")
## tsearchn should return a "degnerate simplex" error here
tsearchn(ps, ts, cbind(1, 2, 4))
## Encasing this in a try() statement shouldn't make a difference
try(tsearchn(ps, ts, cbind(1, 2, 4)))

## The QJ option should lead to no degnerate simplex
ts <- delaunayn(ps, "QJ")
## tsearchn shouldn't return a "degnerate simplex" error. FIXME: But
## it does.
tsearchn(ps, ts, cbind(1, 2, 4))
## Encasing this in a try() statement shouldn't make a difference
try(tsearchn(ps, ts, cbind(1, 2, 4)))
