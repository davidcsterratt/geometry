/* Copyright (C) 2000, 2013, 2015, 2017 Kai Habel
** Copyright R-version (c) 2005 Raoul Grasman
**                     (c) 2013-2014 David Sterratt
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
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
#include "qhull_ra.h"
#include <unistd.h>              /* For unlink() */

/* Finalizer which R will call when garbage collecting. This is
   registered at the end of delaunaynn() */
static void delaunaynFinalizer(SEXP ptr)
{
  int curlong, totlong;
  if(!R_ExternalPtrAddr(ptr)) return;
  qhT *qh;
  qh = R_ExternalPtrAddr(ptr);

  qh_freeqhull(qh, !qh_ALL);                /* free long memory */
  qh_memfreeshort (qh, &curlong, &totlong);	/* free short memory and memory allocator */
  if (curlong || totlong) {
    warning("delaunaynn: did not free %d bytes of long memory (%d pieces)",
	    totlong, curlong);
  }
  qh_free(qh);
  R_ClearExternalPtr(ptr); /* not really needed */
}

SEXP C_delaunayn(const SEXP p, const SEXP options, SEXP tmpdir)
{
  SEXP retlist, retnames;       /* Return list and names */
  int retlen = 3;               /* Length of return list */
	SEXP tri;                     /* The triangulation */
  SEXP neighbour, neighbours;   /* List of neighbours */
  SEXP areas;                    /* Facet areas */
	int i, j;
	unsigned dim, n;
  int exitcode = 1;
	boolT ismalloc;
	char flags[250];             /* option flags for qhull, see qh_opt.htm */
	double *pt_array;

  /* Initialise return values */
	tri = neighbours = retlist = areas = R_NilValue;

  /* We cannot print directly to stdout in R, and the alternative of
     using R_Outputfile does not seem to work for all
     architectures. Setting outfile to NULL, is not an option, as an
     open file handle is required for a call to freopen in the Qhull
     code when qh_new_qhull() is called. Therefore use the ersatz
     stdout, tmpstdout (see below). */
  /* FILE *outfile = NULL; */
  /* qh_fprintf() in userprint.c has been redefined so that a NULL
     errfile results in printing via REprintf(). */
  FILE *errfile = NULL;       

	if(!isString(options) || length(options) != 1){
		error("Second argument must be a single string.");
	}
	if(!isMatrix(p) || !isReal(p)){
		error("First argument should be a real matrix.");
	}
  
  /* Read options into command */
	i = LENGTH(STRING_ELT(options,0)); 
  if (i > 200) 
    error("Option string too long");
  sprintf(flags,"qhull d Qbb T0 Fn %s", CHAR(STRING_ELT(options,0))); 

  /* Check input matrix */
	dim = ncols(p);
	n   = nrows(p);
	if(dim <= 0 || n <= 0){
		error("Invalid input matrix.");
	}
  if (n <= dim) {
    error("Number of points is not greater than the number of dimensions.");
  }

  i = 0, j = 0;
  pt_array = (double *) R_alloc(n*dim, sizeof(double)); 
  for(i=0; i < n; i++)
    for(j=0; j < dim; j++)
      pt_array[dim*i+j] = REAL(p)[i+n*j];
  ismalloc = False;   /* True if qhull should free points in qh_freeqhull() or reallocation */

  /* Jiggery-pokery to create and destroy the ersatz stdout, and the
     call to qhull itself. */    
  const char *name;
  name = R_tmpnam("Rf", CHAR(STRING_ELT(tmpdir, 0)));
  tmpstdout = fopen(name, "w");
  qhT *qh= (qhT*)malloc(sizeof(qhT));
  qh_zero(qh, errfile);
  exitcode = qh_new_qhull(qh, dim, n, pt_array, ismalloc, flags, tmpstdout, errfile); 
  fclose(tmpstdout);
  unlink(name);
  free((char *) name); 

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
    PROTECT(neighbours = allocVector(VECSXP, nf));
    PROTECT(areas = allocVector(REALSXP, nf));

    /* Iterate through facets to extract information */
    int i=0;
    FORALLfacets {
      if (!facet->upperdelaunay) {
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

        /* Neighbours */
        PROTECT(neighbour = allocVector(INTSXP, qh_setsize(qh, facet->neighbors)));
        j=0;
        FOREACHneighbor_(facet) {
          INTEGER(neighbour)[j] = neighbor->visitid ? neighbor->visitid: 0 - neighbor->id;
          j++;
        }
        SET_VECTOR_ELT(neighbours, i, neighbour);
        UNPROTECT(1);
          
        /* Area. Code modified from qh_getarea() in libquhull/geom2.c */
        if ((facet->normal) && !(facet->upperdelaunay && qh->ATinfinity)) {
          if (!facet->isarea) {
            facet->f.area= qh_facetarea(qh, facet);
            facet->isarea= True;
          }
          REAL(areas)[i] = facet->f.area;
        }

        i++;
      }
    }
    UNPROTECT(3);
  } else { /* exitcode != 1 */
    /* There has been an error; Qhull will print the error
       message */
    PROTECT(tri = allocMatrix(INTSXP, 0, dim+1)); 
    UNPROTECT(1);
    /* If the error been because the points are colinear, coplanar
       &c., then avoid mentioning an error by setting exitcode=2*/
    /* Rprintf("dim %d; n %d\n", dim, n); */
    if ((dim + 1) == n) {
      exitcode = 2;
    }
  }

  PROTECT(retlist = allocVector(VECSXP, retlen));
  PROTECT(retnames = allocVector(VECSXP, retlen));
  SET_VECTOR_ELT(retlist, 0, tri);
  SET_VECTOR_ELT(retnames, 0, mkChar("tri"));
  SET_VECTOR_ELT(retlist, 1, neighbours);
  SET_VECTOR_ELT(retnames, 1, mkChar("neighbours"));
  SET_VECTOR_ELT(retlist, 2, areas);
  SET_VECTOR_ELT(retnames, 2, mkChar("areas"));
  setAttrib(retlist, R_NamesSymbol, retnames);
  UNPROTECT(2);

  /* Register delaunaynFinalizer() for garbage collection and attach a
     pointer to the hull as an attribute for future use. */
  SEXP ptr, tag;
  PROTECT(tag = allocVector(STRSXP, 1));
  SET_STRING_ELT(tag, 0, mkChar("delaunayTriangulation"));
  PROTECT(ptr = R_MakeExternalPtr(qh, tag, R_NilValue));
  if (exitcode) {
    delaunaynFinalizer(ptr);
  } else {
    R_RegisterCFinalizerEx(ptr, delaunaynFinalizer, TRUE);
    setAttrib(retlist, tag, ptr);
  }
  UNPROTECT(2);
  
  if (exitcode & (exitcode != 2)) {
    error("Received error code %d from qhull.", exitcode);
  } 

  
	return retlist;
}


