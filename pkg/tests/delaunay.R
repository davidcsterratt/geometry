d <- c(-1,1)
pc <- as.matrix(rbind(expand.grid(d,d,d),0))
print(delaunayn(pc))
