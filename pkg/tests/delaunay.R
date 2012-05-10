library(geometry)
d <- c(-1,1)
pc <- as.matrix(rbind(expand.grid(d,d,d),0))
pct <- delaunayn(pc) 
print(pct)
if (!inherits(pct, "matrix"))
  stop("Output of delaunayn should be an array")

## If the input matrix contains NAs, delaunayn should return an error
pc <- rbind(pc, NA)
try(delaunayn(pc))

## In the case of just one triangle, delaunayn should still return a
## matrix
pc <- rbind(c(0, 0), c(0, 1), c(1, 0))
pct <- delaunayn(pc)
print(pct)
if (!inherits(pct, "matrix"))
  stop("Output of delaunayn should be an array")
