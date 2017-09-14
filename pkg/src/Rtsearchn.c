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
  if (dim != qh->hull_dim)
    error("Invalid input matrix.");
  
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
  SEXP retlist, retnames;       /* Return list and names */
  int retlen = 2;               /* Length of return list */
  SEXP idx, points;
  PROTECT(idx = allocVector(INTSXP, n));
  int *iidx = INTEGER(idx);
  PROTECT(points = allocMatrix(REALSXP, qh->num_points, dim - 1));

  int j, k;

  /* Output points */
  pointT *point;
  pointT *pointtemp;
  printf("%d POINTS\n", qh->num_points);
  i = 0;
  FORALLpoints {
    for (k=0; k<(dim - 1); k++) {
      REAL(points)[i+k*qh->num_points] = point[k];
      printf("%f ", point[k]);
    }
    i++;
    printf("\n");
  }
  
  /* Run through the matrix using qh_findbestfacet to determine
     whether in hull or not */
  boolT isoutside;
  realT bestdist;
  vertexT *vertex, **vertexp;

  /* The name point is reserved for use with FORALLpoints */
  coordT *testpoint;
  testpoint = (coordT *) R_alloc(dim, sizeof(coordT));
  
  for(i=0; i < n; i++) {
    for(k=0; k < (dim - 1); k++) {
      testpoint[k] = REAL(p)[i+n*k]; /* could have been pt_array = REAL(p) if p had been transposed */
      printf(" %f", testpoint[k]);
    }
    printf("\n");
    qh_setdelaunay(qh, dim, 1, testpoint);
    facet = qh_findbestfacet(qh, testpoint, qh_ALL, &bestdist, &isoutside);
    if (facet->tricoplanar) {
      exitcode = 1;
      break;
    }
    /* printf(": Facet id %d; index %d\n;", facet->id, idmap[facet->id]); */
    /* Convert facet id to id of triangle */
    iidx[i] = idmap[facet->id];
    /* /\* Return vertices of triangle *\/ */
    /* j = 0; */
    /* FOREACHvertex_ (facet->vertices) { */
    /*   if ((i + nf*j) >= nf*(dim+1)) */
    /*     error("Trying to write to non-existent area of memory i=%i, j=%i, nf=%i, dim=%i", i, j, nf, dim); */
    /*   REAL(vertices)[i + nf*j] = 1 + qh_pointid(qh, vertex->point); */
    /*   j++; */
    /* } */
  }

  UNPROTECT(2);

  
  PROTECT(retlist = allocVector(VECSXP, retlen));
  PROTECT(retnames = allocVector(VECSXP, retlen));
  SET_VECTOR_ELT(retlist, 0, idx);
  SET_VECTOR_ELT(retnames, 0, mkChar("idx"));
  SET_VECTOR_ELT(retlist, 1, points);
  SET_VECTOR_ELT(retnames, 1, mkChar("P"));
  setAttrib(retlist, R_NamesSymbol, retnames);
  UNPROTECT(2);
  
  if (exitcode)
    error("findDelaunay: not implemented for triangulated, non-simplicial Delaunay regions (tricoplanar facet, f%d).", facet->id);
  
  return retlist;
}
