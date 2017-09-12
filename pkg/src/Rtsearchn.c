/*

  Copyright (C) 2017 Andreas Stahel

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the
  Free Software Foundation; either version 3 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see
  <http://www.gnu.org/licenses/>.

*/

#include <R.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include "Rgeometry.h"
#include "qhull_ra.h"

/* This works on n-dimensional delaunay triangulations */

SEXP C_tsearchn(const SEXP dt, const SEXP p)
{
  /* Get the qh object from the delaunayTriangulation object */
  SEXP ptr, tag;
  qhT *qh;
  PROTECT(tag = allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("delaunayTriangulation"));
  PROTECT(ptr = getAttrib(dt, tag));
  qh = R_ExternalPtrAddr(ptr);
  UNPROTECT(2);

  /* Check input matrix */
  if(!isMatrix(p) || !isReal(p)){
    error("Second argument should be a real matrix.");
  }
  unsigned int dim, n;
  dim = ncols(p);
  n   = nrows(p);
  if(dim <= 0 || n <= 0){
    error("Invalid input matrix.");
  }

  /* Make space for output */
  SEXP values;
  PROTECT(values = allocVector(INTSXP, n));
  int *ivalues = INTEGER(values);
  
  /* Run through the matrix using qh_findbestfacet to determine
     whether in hull or not */
  coordT *point;
  point = (coordT *) R_alloc(dim, sizeof(coordT));
  boolT isoutside;
  realT bestdist;
  facetT *facet;
  vertexT *vertex, **vertexp;
  int exitcode = 0;

  int i, j;
  for(i=0; i < n; i++) {
    for(j=0; j < dim; j++) {
      point[j] = REAL(p)[i+n*j]; /* could have been pt_array = REAL(p) if p had been transposed */
    }
    qh_setdelaunay(qh, dim, 1, point);
    facet = qh_findbestfacet(qh, point, qh_ALL, &bestdist, &isoutside);
    if (facet->tricoplanar) {
      exitcode = 1;
      break;
    }
    ivalues[i] = facet->id;
  }
  UNPROTECT(1);

  if (exitcode)
    error("findDelaunay: not implemented for triangulated, non-simplicial Delaunay regions (tricoplanar facet, f%d).", facet->id);
  
  return values;
}
