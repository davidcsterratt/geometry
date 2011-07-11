"distmesh2d" <-
function(fd, fh, h0, bbox, p=NULL, pfix=array(0,dim=c(0,2)),
  ..., dptol=.001, ttol=.1, Fscale=1.2, deltat=.2,
  geps=.001*h0, deps=sqrt(.Machine$double.eps)*h0,
  maxiter=1000){

  rownorm2 = function(x) drop(sqrt((x^2)%*%c(1,1)))

  if(any(apply(bbox,2,diff)==0))
     stop("Supplied bounding box has zero area.")

  if(is.null(p)){
    #%1 generate initial grid
    y = seq(bbox[1,2],bbox[2,2], by=h0*sqrt(3)/2)
    x = seq(bbox[1,1], bbox[2,1], by=h0)
    x = matrix(x,length(y),length(x),byrow=TRUE)
    x[seq(2,length(y),by=2),] = x[seq(2,length(y),by=2),] + h0/2
    p = cbind(c(x),y)

    #%2 remove nodes outside boundary specified by fd (points evaluated negative are
    # considered to lie inside the boundary)
    p = p[fd(p,...)<geps,]
  }

  r0 = 1 / fh(p,...)^2                           # acceptance probability
  p = rbind(pfix, p[runif(nrow(p))<r0/max(r0),]) # rejection sampling
  N = nrow(p)
  if(N<=3)
    stop("Not enough starting points inside boundary (is h0 too large?).")

  on.exit(return(invisible(p)));                 # in case we need to stop earlier
  cat("Press esc if the mesh seems fine but the algorithm hasn't converged.\n")
  flush.console();

  #%3 main loop: iterative improvement of points
  pold = 1.0/.Machine$double.eps;
  iter = 0
  while(TRUE){
    if( max( rownorm2(p-pold)/h0 )>ttol ){
        pold = p;

        T = delaunayn(p)                           # generate a Delaunay triangulation

        pmid = (p[T[,1],] + p[T[,2],] + p[T[,3],])/3          # calculate average of node locations as centers
        T  = T[fd(pmid, ...) < (-geps),1:3];                  # remove triangles with center outside region

        #%4 describe edges by uniqe pairs of nodes
        #bars = unique(rbind(T[,-1],T[,-2],T[,-3]),MARGIN=1);
        #bars = bars[order(bars[,1],bars[,2]),];

        bars = rbind(T[,-3],T[,-2],T[,-1])                    # select unique edges
        #too slow: bars = unique(matsort(bars), MARGIN=1)
        bars = Unique(matsort(bars))                          # order the edges according to the node indices

        #%5 Graphical display
        trimesh(T,p)         # a la Matlab
    }

    #%6 compute force F on the basis of edge lenghts
    barvec = p[bars[,1],] - p[bars[,2],]                      # bar vectors
    L = rownorm2(barvec)                                      # their lengths

    # calculate desired lengths L0 by use of fh
    hbars = fh((p[bars[,1],]+p[bars[,2],])/2, ...)
    L0 = hbars * Fscale * sqrt(sum(L^2)/sum(hbars^2));
    F = drop(L0-L); F[F<0] = 0;                               # the forces on the edges = max(L0-L,0)


    Fvec = barvec * (F/L)
    Ftot = matrix(0,N,2);
    ii = bars[,c(1,1,2,2)]
    jj = rep(1,length(F)) %o% c(1,2,1,2)
    s  = c(cbind(Fvec,-Fvec))
#    for(k in 1:length(s))                                     # sum all forces on each node
#        Ftot[ii[k],jj[k]] = Ftot[ii[k],jj[k]] + s[k];
    ns = length(s)
    Ftot[1:(2*N)] = rowsum(s,ii[1:ns]+ns*(jj[1:ns]-1))  # sum all forces on each node
    if(nrow(pfix)>0) Ftot[1:nrow(pfix),] = 0;                 # Force = 0 at fixed points
    p = p + deltat*Ftot;

    #%7 excercise normal force at boundary: move overshoot points to nearest boundary point
    d = fd(p);
    ix= d>0;                                                  # find points outside
    dgradx= (fd(cbind(p[ix,1]+deps, p[ix,2]),...) - d[ix])/deps;  # Numerical
    dgrady= (fd(cbind(p[ix,1], p[ix,2]+deps),...) - d[ix])/deps;  #    gradient
    p[ix,] = p[ix,] - cbind(d[ix]*dgradx, d[ix]*dgrady);      # Project back to boundary

    #%8 test for convergence
    if(max(rownorm2(deltat*Ftot[d < (-geps),])/h0) < dptol | iter>=maxiter) break;
    iter = iter + 1
  }
  if(iter>=maxiter)
    warning(" Maximum iterations reached. Relaxation process not \n completed")
  return(p);
}
