/* Copyright (C) 2015 David Sterratt
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
SEXP inhulln(const SEXP ch, const SEXP p)
{
  /* Get the qh object from the convhulln object */
  SEXP ptr, tag;
  qhT *qh;
  PROTECT(tag = allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("convhull"));
  PROTECT(ptr = getAttrib(ch, tag));
  qh = R_ExternalPtrAddr(ptr);
  UNPROTECT(2);
  
  /* Initialise return value */
  SEXP inside;
  inside = R_NilValue;

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

  /* Run through the matrix using qh_findbestfacet to determine
     whether in hull or not */
  PROTECT(inside = allocVector(LGLSXP, n));
  double *point;
  point = (double *) R_alloc(dim, sizeof(double));
  boolT isoutside;
  realT bestdist;
  int i, j;
  for(i=0; i < n; i++) {
    for(j=0; j < dim; j++)
      point[j] = REAL(p)[i+n*j]; /* could have been pt_array = REAL(p) if p had been transposed */
    qh_findbestfacet(qh, point, !qh_ALL, &bestdist, &isoutside);
    LOGICAL(inside)[i] = !isoutside;
  }
  UNPROTECT(1);
  
  return inside;
}
