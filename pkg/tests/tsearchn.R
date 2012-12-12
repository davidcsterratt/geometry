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

## Create a mesh with a zero-area element (degenerate simplex)
p <- cbind(c(-1, -1, 0, 1, 2),
           c(-1,  1, 0, 0, 0))
tri <- rbind(c(1, 2, 3),
             c(3, 4, 5))
## Look for one point in one of the simplices and a point outwith the
## simplices. This forces tsearchn to look in all simplices. It
## shouldn't fail on the degenerate simplex.
tsearchn(p, tri, rbind(c(-0.5, 0), c(3, 1)), fast=FALSE)
tsearchn(p, tri, rbind(c(-0.5, 0), c(3, 1)), fast=TRUE)

