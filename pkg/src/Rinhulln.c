/* Copyright (C) 2015, 2017, 2019, 2021 David Sterratt
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
*/

#include "Rgeometry.h"
#include "qhull_ra.h"

/*  ch is the hull object produced by convhulln()
    p are the test points */
SEXP C_inhulln(const SEXP ch, const SEXP p)
{
  int debug = 0;
  /* Get the qh object from the convhulln object */
  SEXP ptr, tag;
  qhT *qh;
  PROTECT(tag = allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("convhulln"));
  PROTECT(ptr = getAttrib(ch, tag));
  if (ptr == R_NilValue) {
    error("Convex hull has no convhulln attribute");
  }
  qh = R_ExternalPtrAddr(ptr);
  UNPROTECT(2);
  
  /* Initialise return value */
  SEXP inside, idx, distances, retlist, retnames;
  inside = idx = distances = retlist = retnames = R_NilValue;

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
  if(dim != qh->hull_dim){
    error("Number of columns in test points p (%d) not equal to dimension of hull (%d).", dim, qh->hull_dim);
  }

  int max_facet_id, nf;
  int exitcode = qhullFacetCount(qh, &nf, &max_facet_id);

  facetT *facet;
  int *idmap = (int *) R_alloc(max_facet_id + 1, sizeof(int));
  int i = 0;
  FORALLfacets {
    if (!facet->upperdelaunay) {
      i++;
      if (debug & 1) Rprintf("Facet id %d; index %d\n", facet->id, i);
      if (facet->id < 1 || facet->id > max_facet_id) {
        Rf_error("facet_id %d (at index %d) is not in {1,...,%d}", facet->id, i, max_facet_id);
      }
      idmap[facet->id] = i;
    }
  }

  /* Run through the matrix using qh_findbestfacet to determine
     whether in hull or not */
  PROTECT(inside = allocVector(LGLSXP, n));
  PROTECT(idx = allocVector(INTSXP, n));
  PROTECT(distances = allocVector(REALSXP, n));

  vertexT *vertex;
  double *point;
  point = (double *) R_alloc(dim, sizeof(double));
  boolT isoutside;
  realT bestdist, bestvertexdist;
  int j;
  for(i=0; i < n; i++) {
    for(j=0; j < dim; j++)
      point[j] = REAL(p)[i+n*j]; /* could have been pt_array = REAL(p) if p had been transposed */
    facet = qh_findbestfacet(qh, point, qh_ALL, &bestdist, &isoutside);
    vertex = qh_nearvertex(qh, facet, point, &bestvertexdist);
    LOGICAL(inside)[i] = !isoutside;
    REAL(distances)[i] = bestdist; /*(bestdist < bestvertexdist ? bestvertexdist : bestdist); */
    /* Rprintf("Best vertex distance: %2.3f (%2.3f, %2.3f)\n", bestvertexdist, vertex->point[0], vertex->point[1]); */
    /* Find index of bestfacet */
    INTEGER(idx)[i] = idmap[facet->id];
    if (debug & 1) Rprintf("Found: Facet id %d; index %d; distance %2.3f\n", facet->id, idmap[facet->id], bestdist);
  }

  /* Set up output structure */
  retlist =  PROTECT(allocVector(VECSXP, 3));
  retnames = PROTECT(allocVector(VECSXP, 3));
  SET_VECTOR_ELT(retlist,  0, inside);
  SET_VECTOR_ELT(retnames, 0, mkChar("inside"));
  SET_VECTOR_ELT(retlist,  1, distances);
  SET_VECTOR_ELT(retnames, 1, mkChar("distances"));
  SET_VECTOR_ELT(retlist,  2, idx);
  SET_VECTOR_ELT(retnames, 2, mkChar("idx"));

  setAttrib(retlist, R_NamesSymbol, retnames);

  UNPROTECT(5);
  return retlist;
}
