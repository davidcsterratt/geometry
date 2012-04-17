library(geometry)
set.seed(1)
ps <- matrix(rnorm(3000),ncol=3)
ps <- sqrt(3) * ps / drop(sqrt((ps^2) %*% rep(1,3)))
ts <- convhulln(ps, "QJ")
print(ts)

## This should throw an error, but not segfault
try(convhulln(diag(4)))
