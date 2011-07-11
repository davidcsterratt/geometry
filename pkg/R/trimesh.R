trimesh <- function(T, p, p2, add=FALSE, axis=FALSE, boxed=FALSE, ...){
  if(!is.matrix(p)){
     p = cbind(p,p2) # automatically generates error if p2 not present
  }
  xlim = range(p[,1])
  ylim = range(p[,2])
  if(!add){
    plot.new()
    plot.window(xlim, ylim, ...)
  }
  if(boxed){
    box()
  }
  if(axis) {
    axis(1)
    axis(2)
  }
  m = rbind(T[,-1], T[, -2], T[, -3])
  segments(p[m[,1],1],p[m[,1],2],p[m[,2],1],p[m[,2],2], ...)
  return(invisible(list(T = T, p = p)))
}

