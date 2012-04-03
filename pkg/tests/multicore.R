library(geometry)
## multicore isn't available on all operating systems, e.g. Windows
if (library(multicore, logical.return=TRUE)) {
  ## Set seed for replicability
  set.seed(1)

  ## Create points and try standard Delaunay Triangulation
  N <- 100000
  P <- matrix(runif(2*N), N, 2)
  T <- delaunayn(P)
  print(nrow(T))

  ## Now try out the parallel version
  Ts <- mclapply(list(P, P, P, P), delaunayn)
  print(length(Ts))
  print(nrow(Ts[[1]]))
}
