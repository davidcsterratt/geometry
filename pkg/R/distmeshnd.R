"distmeshnd"  <-
function (fdist, fh, h, box, pfix = array(dim = c(0, ncol(box))),
    ..., ptol = 0.001, ttol = 0.1, deltat = 0.1, geps = 0.1 *
        h, deps = sqrt(.Machine$double.eps) * h)
{
# %DISTMESHND N-D Mesh Generator using Distance Functions.
    dim = ncol(as.matrix(box))
    L0mult = 1 + 0.4/2^(dim - 1)
    rownorm2 = function(x) drop(sqrt((x^2) %*% rep(1, ncol(x))))

    # %1. Create initial distribution in bounding box
    if (dim == 1) {
        p = seq(box[1], box[2], by = h)
    }
    else {
        cbox = lapply(1:dim, function(ii) seq(box[1, ii], box[2,
            ii], by = h))
        p = do.call("expand.grid", cbox)
        p = as.matrix(p)
    }

    # %2. Remove points outside the region, apply the rejection method
    p = p[fdist(p, ...) < geps, ]
    r0 = fh(p, ...)
    p = rbind(pfix, p[runif(nrow(p)) < min(r0)^dim/r0^dim, ])
    N = nrow(p)
    if (N <= dim + 1)
        stop("Not enough starting points inside boundary (is h0 too large?).")
    on.exit(return(invisible(p)))

    cat("Press esc if the mesh seems fine but the algorithm hasn't converged.\n")
    flush.console()
    count = 0

    p0 = 1/.Machine$double.eps

    # mimick Matlab call ``localpairs=nchoosek(1:dim+1,2)'':
    localpairs = as.matrix(expand.grid(1:(dim + 1), 1:(dim + 1)))
    localpairs = localpairs[lower.tri(matrix(TRUE, dim + 1, dim + 1)), 2:1]

    while (TRUE) {
        if (max(rownorm2(p - p0)) > ttol * h) {
            # %3. Retriangulation by Delaunay:

            p0 = p
            t = delaunayn(p)
            pmid = matrix(0, nrow(t), dim)
            for (ii in 1:(dim + 1)) pmid = pmid + p[t[, ii],
                ]/(dim + 1)
            t = t[fdist(pmid, ...) < (-geps), ]
            pair = array(dim = c(0, 2))
            for (ii in 1:nrow(localpairs)) {
                pair = rbind(pair, t[, localpairs[ii, ]])
            }

            # %4. Describe each edge by a unique pair of nodes
            pair = Unique(pair, TRUE); # base-function `unique' is way too slow
            if (dim == 2) {
                trimesh(t, p[, 1:2])
            }
            else if (dim == 3) {
                if (count%%5 == 0) {
                  tetramesh(t, p)
                }
            }
            else {
                cat("Retriangulation #", 15, "\n")
                flush.console()
            }
            count = count + 1
        }
        bars = p[pair[, 1], ] - p[pair[, 2], ]
        L = rownorm2(bars)
        L0 = fh((p[pair[, 1], ] + p[pair[, 2], ])/2, ...)
        L0 = L0 * L0mult * (sum(L^dim)/sum(L0^dim))^(1/dim)
        F = L0 - L
        F[F < 0] = 0
        Fbar = cbind(bars, -bars) * matrix(F/L, nrow = nrow(bars),
            ncol = 2 * dim)
        ii = pair[, t(matrix(1:2, 2, dim))]
        jj = rep(1, nrow(pair)) %o% c(1:dim, 1:dim)
        s = c(Fbar)
        ns = length(s)
        dp = matrix(0, N, dim)
        dp[1:(dim * N)] = rowsum(s, ii[1:ns] + ns * (jj[1:ns] -
            1))
        if (nrow(pfix) > 0)
            dp[1:nrow(pfix), ] = 0
        p = p + deltat * dp
        d = fdist(p, ...)
        ix = d > 0
        gradd = matrix(0, sum(ix), dim)
        for (ii in 1:dim) {
            a = rep(0, dim)
            a[ii] = deps
            d1x = fdist(p[ix, ] + rep(1, sum(ix)) %o% a, ...)
            gradd[, ii] = (d1x - d[ix])/deps
        }
        p[ix, ] = p[ix, ] - (d[ix] %o% rep(1, dim)) * gradd
        maxdp = max(deltat * rownorm2(dp[d < (-geps), ]))
        if (maxdp < ptol * h)
            break
    }
}
