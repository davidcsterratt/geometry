library(geometry)
x <- c(-1, -1, 1)
y <- c(-1, 1, -1);
tri <- matrix(c(1, 2, 3), 1, 3);
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

