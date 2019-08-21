/* Copyright (C) 2000 Kai Habel
** Copyright R-version (C) 2005 Raoul Grasman 
**                     (C) 2013-2015, 2017-2019 David Sterratt
**                     (C) 2018 Pavlo Mozharovskyi
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

/*
29. July 2000 - Kai Habel: first release
2002-04-22 Paul Kienzle
* Use warning(...) function rather than writing to cerr

23. May 2005 - Raoul Grasman: ported to R
* Changed the interface for R

02. February 2018 - Pavlo Mozharovskyi: added non-triangulated output
*/

#include "Rgeometry.h"

SEXP C_convhulln(const SEXP p, const SEXP options, const SEXP returnNonTriangulatedFacets, const SEXP tmp_stdout, const SEXP tmp_stderr)
{
  /* Initialise return values */
  SEXP retval, area, vol, normals, retlist, retnames;
  retval = area = vol = normals = retlist = R_NilValue;

  /* Run Qhull */
  qhT *qh= (qhT*)malloc(sizeof(qhT));
  char errstr[ERRSTRSIZE];
  unsigned int dim, n;
  char cmd[50] = "qhull";
  int exitcode = qhullNewQhull(qh, p, cmd,  options, tmp_stdout, tmp_stderr, &dim, &n, errstr);

  /* Error handling */
  if (exitcode) {
    freeQhull(qh);
    error("Received error code %d from qhull. Qhull error:\n%s", exitcode, errstr);
  }
  
  /* Extract information from output */
  int i, j, *idx;
  facetT *facet;              /* set by FORALLfacets */
  vertexT *vertex, **vertexp; /* set by FORALLfacets */
  unsigned int nf = qh->num_facets;
  unsigned int nVertexMax = 0;

  /* If parameter (flag) returnNonTriangulatedFacets is set, count the
     number of columns in the output matrix of vertices as the maximal
     number of vertices in a facet, then allocate the matrix. */
  if (INTEGER(returnNonTriangulatedFacets)[0] > 0){
    i = 0;
    FORALLfacets {
      j = 0;
      FOREACHvertex_ (facet->vertices) {
        j++;
      }
      if (j > nVertexMax){
        nVertexMax = j;
      }
    }
  } else {
    /* If parameter (flag) returnNonTriangulatedFacets is not set, the
       number of columns equals dimension. */
    nVertexMax = dim;
  }
  retval = PROTECT(allocMatrix(INTSXP, nf, nVertexMax));
  idx = (int *) R_alloc(nf*nVertexMax,sizeof(int));

  if (hasPrintOption(qh, qh_PRINTnormals)) {
    normals = PROTECT(allocMatrix(REALSXP, nf, dim+1));
  } else {
    normals = PROTECT(R_NilValue);
  }

  qh_vertexneighbors(qh);

  i = 0; /* Facet counter */
  FORALLfacets {
    j = 0;
    /* qh_printfacet(stdout,facet); */
    FOREACHvertex_ (facet->vertices) {
      /* qh_printvertex(stdout,vertex); */
      if (INTEGER(returnNonTriangulatedFacets)[0] == 0 && j >= dim)
        warning("extra vertex %d of facet %d = %d",
                j++, i, 1+qh_pointid(qh, vertex->point));
      else
        idx[i + nf*j++] = 1 + qh_pointid(qh, vertex->point);
    }
    if (j < dim) warning("facet %d only has %d vertices",i,j);
    while (j < nVertexMax){
      idx[i + nf*j++] = 0; /* Fill with zeros for the moment */
    }

    /* Output normals */
    if (hasPrintOption(qh, qh_PRINTnormals)) {
      if (facet->normal) {
        for (j=0; j<dim; j++) {
          REAL(normals)[i + nrows(normals)*j] = facet->normal[j];
        }
        REAL(normals)[i + nrows(normals)*dim] = facet->offset;
      } else {
        for (j=0; j<=dim; j++) {
          REAL(normals)[i + nrows(normals)*j] = 0;
        }
      }
    }
    i++; /* Increment facet counter */
  }
  j = 0;
  for(i = 0; i<nrows(retval); i++)
    for(j = 0; j<ncols(retval); j++)
      if (idx[i + nf*j] > 0){
        INTEGER(retval)[i + nrows(retval)*j] = idx[i + nf*j];
      } else {
        INTEGER(retval)[i + nrows(retval)*j] = NA_INTEGER;
      }

  /* Return area and volume - will be there when option "FA" is provided */
  if (qh->totarea != 0.0) {
    area = PROTECT(allocVector(REALSXP, 1));
    REAL(area)[0] = qh->totarea;
  } else {
    area = PROTECT(R_NilValue);
  }
  if (qh->totvol != 0.0) {
    vol = PROTECT(allocVector(REALSXP, 1));
    REAL(vol)[0] = qh->totvol;
  } else {
    vol = PROTECT(R_NilValue);
  }

  /* Set up output structure */
  retlist =  PROTECT(allocVector(VECSXP, 4));
  retnames = PROTECT(allocVector(VECSXP, 4));
  SET_VECTOR_ELT(retlist,  0, retval);
  SET_VECTOR_ELT(retnames, 0, mkChar("hull"));
  SET_VECTOR_ELT(retlist,  1, area);
  SET_VECTOR_ELT(retnames, 1, mkChar("area"));
  SET_VECTOR_ELT(retlist,  2, vol);
  SET_VECTOR_ELT(retnames, 2, mkChar("vol"));
  SET_VECTOR_ELT(retlist,  3, normals);
  SET_VECTOR_ELT(retnames, 3, mkChar("normals"));
  setAttrib(retlist, R_NamesSymbol, retnames);

  /* Register qhullFinalizer() for garbage collection and attach a
     pointer to the hull as an attribute for future use. */
  SEXP ptr, tag;
  tag = PROTECT(allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("convhulln"));
  ptr = PROTECT(R_MakeExternalPtr(qh, tag, R_NilValue));
  R_RegisterCFinalizerEx(ptr, qhullFinalizer, TRUE);
  setAttrib(retlist, tag, ptr);

  UNPROTECT(8); /* ptr, tag, retnames, retlist, normals, vol, area, retval */

  return retlist;
}
