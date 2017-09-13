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
  dim = ncols(p) + 1;
  n   = nrows(p);
  if(dim <= 0 || n <= 0){
    error("Invalid input matrix.");
  }

  /* Construct map from facet id to index */ 
  facetT *facet;

  /* Count the number of facets so we know how much space to
     allocate in R */
  int nf = 0;                   /* Number of facets */
  int max_facet_id = 0;
  int exitcode = 0;
  FORALLfacets {
    if (!facet->upperdelaunay) {
      nf++;
      if (facet->id > max_facet_id)
        max_facet_id = facet->id;

      /* Double check. Non-simplicial facets will cause segfault
         below */
      if (!facet->simplicial) {
        Rprintf("Qhull returned non-simplicial facets -- try delaunayn with different options");
        exitcode = 1;
        break;
      }
    }
  }

  int *idmap = (int *) R_alloc(max_facet_id, sizeof(int));
  int i = 0;
  FORALLfacets {
    if (!facet->upperdelaunay) {
      i++;
      printf("Facet id %d; index %d\n;", facet->id, i);
      idmap[facet->id] = i;
    }
  }
    
  /* Make space for output */
  SEXP values;
  PROTECT(values = allocVector(INTSXP, n));
  int *ivalues = INTEGER(values);
  
  /* Run through the matrix using qh_findbestfacet to determine
     whether in hull or not */
  coordT *testpoint;
  testpoint = (coordT *) R_alloc(dim, sizeof(coordT));
  /* coordT testpoint[100]; */
  boolT isoutside;
  realT bestdist;
  vertexT *vertex, **vertexp;

  int k;
  for(i=0; i < n; i++) {
    for(k=0; k < (dim - 1); k++) {
      testpoint[k] = 0.4; /* REAL(p)[i+n*k]; /* could have been pt_array = REAL(p) if p had been transposed */
      printf(" %f", testpoint[k]);
    }
    printf("\n");
    qh_setdelaunay(qh, dim, 1, testpoint);
    facet = qh_findbestfacet(qh, testpoint, qh_ALL, &bestdist, &isoutside);
    if (facet->tricoplanar) {
      exitcode = 1;
      break;
    }
    printf(": Facet id %d; index %d\n;", facet->id, idmap[facet->id]);
    ivalues[i] = idmap[facet->id];
  }
  UNPROTECT(1);

  if (exitcode)
    error("findDelaunay: not implemented for triangulated, non-simplicial Delaunay regions (tricoplanar facet, f%d).", facet->id);
  
  return values;
}
