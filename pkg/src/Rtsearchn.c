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

SEXP C_tsearchn(const SEXP dt, const SEXP p)
{
  int debug = 0;
  /* Get the qh object from the delaunayn object */
  SEXP ptr, tag;
  qhT *qh;
  tag = PROTECT(allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("delaunayn"));
  ptr = PROTECT(getAttrib(dt, tag));
  if (ptr == R_NilValue) {
    error("Delaunay triangulation has no delaunayn attribute");
  }
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

  int *idmap = (int *) R_alloc(max_facet_id + 1, sizeof(int));
  int i = 0;
  FORALLfacets {
    if (!facet->upperdelaunay) {
      i++;
      if (debug & 1) Rprintf("Facet id %d; index %d\n;", facet->id, i);
       if (facet->id < 1 || facet->id > max_facet_id) {
         Rf_error("facet_id %d (at index %d) is not in {1,...,%d}", facet->id, i, max_facet_id);
       }
      idmap[facet->id] = i;
    }
  }
    
  /* Make space for output */
  SEXP retlist, retnames;       /* Return list and names */
  int retlen = 2;               /* Length of return list */
  SEXP idx, points;
  idx = PROTECT(allocVector(INTSXP, n));
  int *iidx = INTEGER(idx);
  points = PROTECT(allocMatrix(REALSXP, qh->num_points, dim - 1));

  int j, k;

  /* Output points */
  pointT *point;
  pointT *pointtemp;
  if (debug & 2) Rprintf("%d POINTS\n", qh->num_points);
  i = 0;
  FORALLpoints {
    for (k=0; k<(dim - 1); k++) {
      REAL(points)[i+k*qh->num_points] = point[k];
      if (debug & 2) Rprintf("%f ", point[k]);
    }
    i++;
    if (debug & 2) Rprintf("\n");
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
    if (debug) Rprintf("\nTestpoint\n");
    for(k=0; k < (dim - 1); k++) {
      testpoint[k] = REAL(p)[i+n*k]; /* could have been pt_array = REAL(p) if p had been transposed */
      if (debug) Rprintf(" %f", testpoint[k]);
    }
    if (debug) Rprintf("\n");
    qh_setdelaunay(qh, dim, 1, testpoint);
    facet = qh_findbestfacet(qh, testpoint, qh_ALL, &bestdist, &isoutside);
    if (facet->tricoplanar) {
      exitcode = 1;
      break;
    }
    if (debug) Rprintf("Facet id %d; index %d\n", facet->id, idmap[facet->id]);
    /* Convert facet id to id of triangle */
    iidx[i] = idmap[facet->id];
    /* /\* Return vertices of triangle *\/ */
    j = 0;
    FOREACHvertex_ (facet->vertices) {
      for (j=0; j<dim - 1; j++) {
        if (debug) Rprintf("%f ", vertex->point[j]);
      }
      if (debug) Rprintf("\n");
    }

  }

  retlist = PROTECT(allocVector(VECSXP, retlen));
  retnames = PROTECT(allocVector(VECSXP, retlen));
  SET_VECTOR_ELT(retlist, 0, idx);
  SET_VECTOR_ELT(retnames, 0, mkChar("idx"));
  SET_VECTOR_ELT(retlist, 1, points);
  SET_VECTOR_ELT(retnames, 1, mkChar("P"));
  setAttrib(retlist, R_NamesSymbol, retnames);
  UNPROTECT(4);
  
  if (exitcode)
    error("findDelaunay: not implemented for triangulated, non-simplicial Delaunay regions (tricoplanar facet, f%d).", facet->id);
  
  return retlist;
}
