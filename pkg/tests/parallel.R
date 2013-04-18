library(geometry)
library(parallel)

## mc.cores must be 1 on Windows. Otherwise use only 2 cores to comply
## with CRAN guidelines.
mc.cores <- ifelse(Sys.info()[1] == "Windows", 1, 2)

## Set seed for replicability
set.seed(1)

## Create points and try standard Delaunay Triangulation
N <- 100000
P <- matrix(runif(2*N), N, 2)
T <- delaunayn(P)
print(nrow(T))

## Now try out the parallel version. 
Ts <- mclapply(list(P, P, P, P), delaunayn, mc.cores=mc.cores)
print(length(Ts))
print(nrow(Ts[[1]]))
