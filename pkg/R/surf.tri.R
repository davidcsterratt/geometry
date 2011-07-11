"surf.tri" <-
function(p,t){
    # original by Per-Olof Persson (c) 2005 for MATLAB
    # ported to R and modified for efficiency by Raoul Grasman (c) 2005

    # construct all faces
    faces = rbind(t[,-4], t[,-3], t[,-2], t[,-1]);
    node4 = rbind(t[, 4], t[, 3], t[, 2], t[, 1]);

#    #original translated from MATLAB:
#    # select the faces that occur only once --> these are the surface boundary faces
#    faces = t(apply(faces,1,sort));                                         # sort each row
#    foo   = apply(faces,1,function(x) do.call("paste",as.list(x,sep=" "))); # makes a string from each row
#    vec   = table(foo);                                                     # tabulates the number of occurences of each string
#    ix    = sapply(names(vec[vec==1]),function(b) which(b==foo))            # obtain indices of faces with single occurence
#    tri   = faces[ix,];
#    node4 = node4[ix];


    # we wish to achieve
    #   > faces = t(apply(faces,1,sort));
    # but this is much too slow, we therefore use max.col and the fact
    # that there are only 3 columns in faces
    i.max = 3*(1:nrow(faces)-1) + max.col(faces)
    i.min = 3*(1:nrow(faces)-1) + max.col(-faces)
    faces = t(faces)
    faces = cbind(faces[i.min], faces[-c(i.max,i.min)], faces[i.max])
    ix = order(faces[,1], faces[,2], faces[,3])

    # Next, we wish to detect duplicated rows in faces, that is,
    #   > qx = duplicated(faces[ix,],MARGIN=1)              # logical indicating duplicates
    # but this is also much to slow, we therefore use the fact that
    # faces[ix,] has the duplicate rows ordered beneath each other
    # and the fact that each row occurs exactly once or twice
    fo = apply(faces[ix,],2,diff)
    dup = (abs(fo) %*% rep(1,3)) == 0        # a row of only zeros indicates duplicate
    dup = c(FALSE,dup)                       # first is never a duplicate
    qx = diff(dup)==0                        # only zero if two consecutive elems are not duplicates
    qx = c(qx, !dup[length(dup)])            # last row is either non-duplicate or should not be selected
    tri = faces[ix[qx],]                     # ix[qx] are indices of singly occuring faces
    node4 = node4[ix[qx]]

    # compute face orientations
    v1 = p[tri[,2],] - p[tri[,1],]; # edge vectors
    v2 = p[tri[,3],] - p[tri[,1],];
    v3 = p[node4,]   - p[tri[,1],];
    ix = which( apply(extprod3d(v1,v2) * v3, 1, sum) > 0 )
    tri[ix,c(2,3)] = tri[ix,c(3,2)]
    rownames(tri) = NULL
    tri
}
