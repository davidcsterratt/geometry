/* Copyright (C) 2000, 2013 Kai Habel
** Copyright R-version (c) 2005 Raoul Grasman
**                     (c) 2013 David Sterratt
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
#define qh_QHimport
#include "qhull_a.h"
#include <unistd.h>              /* For unlink() */

SEXP delaunayn(const SEXP p, const SEXP options)
{
  SEXP retlist, retnames;       /* Return list and names */
  int retlen = 2;               /* Length of return list */
	SEXP tri;                     /* The triangulation */
  SEXP neighbour, neighbours;   /* List of neighbours */
	int i;
	unsigned dim, n;
	boolT ismalloc;
	char flags[250];             /* option flags for qhull, see qh_opt.htm */
	double *pt_array;

  /* Initialise return values */
	tri = neighbours = retlist = R_NilValue;

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

	if (n > dim+1) {

		int i, j;
		int exitcode = 1;
		int curlong, totlong;

		i=0,j=0;
		pt_array = (double *) R_alloc(n*dim, sizeof(double)); 
		for(i=0; i < n; i++)
			for(j=0; j < dim; j++)
				pt_array[dim*i+j] = REAL(p)[i+n*j];
		ismalloc = False;   /* True if qhull should free points in qh_freeqhull() or reallocation */

    /* Jiggery-pokery to create and destroy the ersatz stdout, and the
       call to qhull itself. */    
    const char *name;
    name = R_tmpnam("Rf", ".");
    tmpstdout = fopen(name, "w");
		exitcode = qh_new_qhull(dim, n, pt_array, ismalloc, flags, tmpstdout, errfile); 
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

			int nf=0;                 /* Number of facets */
			FORALLfacets {
				if (!facet->upperdelaunay) {
          nf++;
          /* int nv=0;
          FOREACHvertex_ (facet->vertices) {
            nv++;
          }
          printf("Facet %i: %i vertices\n", nf, nv); */
        }
        /* Double check. Non-simplicial facets will cause segfault
           below */
        if (! facet->simplicial) {
          error ("Qhull returned non-simplicial facets -- try delaunayn with different options");
          exitcode = 1;
          break;
        }
			}

      PROTECT(tri = allocMatrix(INTSXP, nf, dim+1));
      PROTECT(neighbours = allocVector(VECSXP, nf));
      int i=0;
			FORALLfacets {
				if (!facet->upperdelaunay) {
          if (i >= nf) {
            error("Trying to access non-existent facet %i", i);
          }
					int j=0;
					FOREACHvertex_ (facet->vertices) {
            if ((i + nf*j) >= nf*(dim+1))
              error("Trying to write to non-existent area of memory i=%i, j=%i, nf=%i, dim=%i", i, j, nf, dim);
            INTEGER(tri)[i + nf*j] = 1 + qh_pointid(vertex->point);
            j++;
					}
          /* printf("Facet %d: ", i); */
          /* printf("%d", qh_setsize(facet->neighbors)); */
          PROTECT(neighbour = allocVector(INTSXP, qh_setsize(facet->neighbors)));
          j=0;
          FOREACHneighbor_(facet) {
            INTEGER(neighbour)[j] = neighbor->visitid ? neighbor->visitid: 0 - neighbor->id;
            j++;
            /* printf(" %d", */
            /*        neighbor->visitid ? neighbor->visitid: 0 - neighbor->id); */
          }
          SET_VECTOR_ELT(neighbours, i, neighbour);
          UNPROTECT(1);
          /* printf("\n"); */
					i++;
				}
			}
      UNPROTECT(2);
		} 
    
    /* Do cleanup regardless of whether there is an error */
		qh_freeqhull(!qh_ALL);                  /* free long memory */
		qh_memfreeshort (&curlong, &totlong);   /* free short memory and memory allocator */

		if (curlong || totlong) {
			warning("delaunay: did not free %d bytes of long memory (%d pieces)", totlong, curlong);
		}
    if (exitcode) {
			error("Received error code %d from qhull.", exitcode);
		}
	} else if (n == dim + 1) {
    /* Number of points is one more than the number of dimensions. */
		/* FIXME. Need to check if nx points span a simplex. */
    PROTECT(tri = allocMatrix(INTSXP, 1, dim+1));
		for (int i=0; i<n; i++) {
			INTEGER(tri)[i] = i + 1;
		}
		UNPROTECT(1);
	}
  PROTECT(retlist = allocVector(VECSXP, retlen));
  PROTECT(retnames = allocVector(VECSXP, retlen));
  SET_VECTOR_ELT(retlist, 0, tri);
  SET_VECTOR_ELT(retnames, 0, mkChar("tri"));
  SET_VECTOR_ELT(retlist, 1, neighbours);
  SET_VECTOR_ELT(retnames, 1, mkChar("neighbours"));
  setAttrib(retlist, R_NamesSymbol, retnames);
  UNPROTECT(2);

	return retlist;
}


