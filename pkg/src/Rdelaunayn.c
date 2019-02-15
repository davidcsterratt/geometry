/* Copyright (C) 2000, 2013, 2015, 2017 Kai Habel
** Copyright R-version (c) 2005 Raoul Grasman
**                     (c) 2013-2019 David Sterratt
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
16. July 2000 - Kai Habel: first release

25. September 2002 - Changes by Rafael Laboissiere <rafael@laboissiere.net>

 * Added Qbb option to normalize the input and avoid crashes in Octave.
 * delaunayn accepts now a second (optional) argument that must be a string
   containing extra options to the qhull command.
 * Fixed doc string.  The dimension of the result matrix is [m, dim+1], and
   not [n, dim-1].

20. May 2005 - Raoul Grasman: ported to R
 * Changed the interface for R
*/

#include "Rgeometry.h"
#include <unistd.h>              /* For unlink() */

SEXP C_delaunayn(const SEXP p, const SEXP options, SEXP tmpdir)
{
  /* Initialise return values */ 

  SEXP retlist, retnames;       /* Return list and names */
  int retlen = 1;               /* Length of return list */
	SEXP tri;                     /* The triangulation */
  SEXP neighbour, neighbours;   /* List of neighbours */
  SEXP areas;                   /* Facet areas */
	tri = neighbours = retlist = areas = R_NilValue;

  /* Run Qhull */
  
  qhT *qh= (qhT*)malloc(sizeof(qhT));
  char errstr1[100], errstr2[100];
  unsigned int dim, n;
  char cmd[50] = "qhull d Qbb T0";
  int exitcode = qhullNewQhull(qh, p, cmd,  options, tmpdir, &dim, &n, errstr1, errstr2);

  /* Extract information from output */
  
  if (!exitcode) {                    /* 0 if no error from qhull */
    /* Triangulate non-simplicial facets - this commented out code
       does not appear to be needed, but retaining in case useful --
       David Sterratt, 2013-04-17 */
    /* qh_triangulate (); */

    facetT *facet;                  /* set by FORALLfacets */
    vertexT *vertex, **vertexp;
    facetT *neighbor, **neighborp;

    /* Count the number of facets so we know how much space to
       allocate in R */
    int nf=0;                 /* Number of facets */
    FORALLfacets {
      if (!facet->upperdelaunay) {
        /* Remove degenerate simplicies */
        if (!facet->isarea) {
          facet->f.area= qh_facetarea(qh, facet);
          facet->isarea= True;
        }
        if (facet->f.area)
          nf++;
      }
      /* Double check. Non-simplicial facets will cause segfault
         below */
      if (! facet->simplicial) {
        Rprintf("Qhull returned non-simplicial facets -- try delaunayn with different options");
        exitcode = 1;
        break;
      }
    }
      
    /* Alocate the space in R */
    PROTECT(tri = allocMatrix(INTSXP, nf, dim+1));
    if (hasPrintOption(qh, qh_PRINTneighbors)) {
      PROTECT(neighbours = allocVector(VECSXP, nf));
      retlen++;
    }
    if (hasPrintOption(qh, qh_PRINTarea)) {
      PROTECT(areas = allocVector(REALSXP, nf));      
      retlen++;
    }
    
    /* Iterate through facets to extract information */
    int i=0;
    FORALLfacets {
      if (!facet->upperdelaunay && facet->f.area) {
        if (i >= nf) {
          error("Trying to access non-existent facet %i", i);
        }

        /* Triangulation */
        int j=0;
        FOREACHvertex_ (facet->vertices) {
          if ((i + nf*j) >= nf*(dim+1))
            error("Trying to write to non-existent area of memory i=%i, j=%i, nf=%i, dim=%i", i, j, nf, dim);
          INTEGER(tri)[i + nf*j] = 1 + qh_pointid(qh, vertex->point);
          j++;
        }

        /* Neighbours - option Fn */
        if (hasPrintOption(qh, qh_PRINTneighbors)) {
          PROTECT(neighbour = allocVector(INTSXP, qh_setsize(qh, facet->neighbors)));
          j=0;
          FOREACHneighbor_(facet) {
            INTEGER(neighbour)[j] = neighbor->visitid ? neighbor->visitid: 0 - neighbor->id;
            j++;
          }
          SET_VECTOR_ELT(neighbours, i, neighbour);
          UNPROTECT(1);
        }

        /* Areas - option Fa */
        if (hasPrintOption(qh, qh_PRINTarea)) {
          /* Area. Code modified from qh_getarea() in libquhull/geom2.c */
          if ((facet->normal) && !(facet->upperdelaunay && qh->ATinfinity)) {
            if (!facet->isarea) {
              facet->f.area= qh_facetarea(qh, facet);
              facet->isarea= True;
            }
            REAL(areas)[i] = facet->f.area;
          }
        }

        i++;
      }
    }
  } else { /* exitcode != 1 */
    /* There has been an error; Qhull will print the error
       message */
    PROTECT(tri = allocMatrix(INTSXP, 0, dim+1));
    if (hasPrintOption(qh, qh_PRINTneighbors)) {
      PROTECT(neighbours = allocVector(VECSXP, 0));
      retlen++;
    }
    if (hasPrintOption(qh, qh_PRINTarea)) {
      PROTECT(areas = allocVector(REALSXP, 0));
      retlen++;
    }

    /* If the error been because the points are colinear, coplanar
       &c., then avoid mentioning an error by setting exitcode=2*/
    /* Rprintf("dim %d; n %d\n", dim, n); */
    if ((dim + 1) == n) {
      exitcode = 2;
    }
  }

  /* Make a list if Fa or Fn specified */
  int i = 0;                      /* Output counter */
  if (retlen > 1) {
    retlist = PROTECT(allocVector(VECSXP, retlen));
    retnames = PROTECT(allocVector(VECSXP, retlen));
    SET_VECTOR_ELT(retlist, i, tri);
    SET_VECTOR_ELT(retnames, i, mkChar("tri"));
    if (hasPrintOption(qh, qh_PRINTneighbors)) {
      i++;
      SET_VECTOR_ELT(retlist, i, neighbours);
      SET_VECTOR_ELT(retnames, i, mkChar("neighbours"));
    }

    if (hasPrintOption(qh, qh_PRINTarea)) {
      i++;
      SET_VECTOR_ELT(retlist, i, areas);
      SET_VECTOR_ELT(retnames, i, mkChar("areas"));
    }
    setAttrib(retlist, R_NamesSymbol, retnames);
  } else {
    retlist = tri;
  }

  /* Register qhullFinalizer() for garbage collection and attach a
     pointer to the hull as an attribute for future use. */
  SEXP ptr, tag;
  PROTECT(tag = allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("delaunayTriangulation"));
  PROTECT(ptr = R_MakeExternalPtr(qh, tag, R_NilValue));
  if (exitcode) {
    qhullFinalizer(ptr);
  } else {
    R_RegisterCFinalizerEx(ptr, qhullFinalizer, TRUE);
    setAttrib(retlist, tag, ptr);
  }

  UNPROTECT(2);                 /* ptr and tag */
  if (retlen > 1) {
    UNPROTECT(2);               /* retnames and retlist */
  }
  if (hasPrintOption(qh, qh_PRINTneighbors)) {
    UNPROTECT(1);
  }
  if (hasPrintOption(qh, qh_PRINTarea)) {
    UNPROTECT(1);
  }
  UNPROTECT(1);                 /* tri */
  
  if (exitcode & (exitcode != 2)) {
    error("Received error code %d from qhull. Qhull error:\n    %s    %s", exitcode, errstr1, errstr2);
  } 
  
	return retlist;
}


