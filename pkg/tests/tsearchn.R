library(geometry)
x <- c(-1, -1, 1)
y <- c(-1, 1, -1)
p <- cbind(x, y)
tri <- matrix(c(1, 2, 3), 1, 3)
# Should be in triangle #1
tsearchn(p, tri, cbind(-1, -1),fast=FALSE)
# Should be in triangle #1
tsearchn(p, tri, cbind(1, -1), fast=FALSE)
# Should be in triangle #1
tsearchn(p, tri, cbind(-1, 1), fast=FALSE)
# Should be in triangle #1
tsearchn(p, tri, cbind(-1/3, -1/3), fast=FALSE)
# Should be outside triangle #1, so should return NA
tsearchn(p, tri, cbind(1, 1), fast=FALSE)

