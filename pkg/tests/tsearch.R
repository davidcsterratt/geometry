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

## Create degenerate simplex
ps <- as.matrix(rbind(data.frame(a=0, b=0, d=0),
                      merge(merge(data.frame(a=c(-1, 1)),
                                  data.frame(b=c(-1, 1))),
                            data.frame(d=c(-1, 1)))))
## The Qt option leads to the degnerate simplex
ts <- delaunayn(ps, "Qt")
## tsearchn should return a "degnerate simplex" error.
try(tsearchn(ps[ts[1,],], ts, cbind(1, 2, 4)))
