/* Copyright (C) 2000  Kai Habel
** Copyright R-version (c) 2005 Raoul Grasman
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


#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <R_ext/Riconv.h>
#ifdef WIN32
/* There doesn't seem to be a Windows header file that includes these
   definitions - Rinterface.h is not available.  */
extern FILE * R_Consolefile;
extern FILE * R_Outputfile;
#else
#include <Rinterface.h>
#endif
#define qh_QHimport
#include "qhull_a.h"

/*
DEFUN_DLD (delaunayn, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{T}=} delaunayn (@var{P}[, @var{opt}])\n\
Form the Delaunay triangulation for a set of points.\n\
The Delaunay trianugulation is a tessellation of the convex hull of the\n\
points such that no n-sphere defined by the n-triangles contains\n\
any other points from the set.\n\n\
The input matrix of size [n, dim] contains n points of dimension dim.\n\
The return matrix @var{T} has the size [m, dim+1]. It contains for\n\
each row a set of indices to the points, which describes a simplex of\n\
dimension dim.  The 3d simplex is a tetrahedron.\n\n\
If a second optional argument is given, it must be a string containing\n\
extra options for the underlying qhull command.  In particular, \"Qt\"\n\
may be useful for joggling the input to cope with non-simplicial cases.\n\
(See the Qhull documentation for the available options.) @end deftypefn")
*/


SEXP delaunayn(const SEXP p, const SEXP options)
{
	SEXP retval;
	int i;
	unsigned dim, n;
	boolT ismalloc;
	char flags[250];             /* option flags for qhull, see qh_opt.htm */
	double *pt_array;

  /* output from qh_produce_output() use stdout to produce
     qh_produce_output() or try */
  /* FILE outfile = fopen("qhull_out.txt", "a"); */
  FILE *outfile = NULL;
  FILE *errfile = R_Consolefile; /* error messages from qhull code */
	retval = R_NilValue;

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
  sprintf(flags,"qhull d Qbb T0 %s", CHAR(STRING_ELT(options,0))); 

  /* Check input matrix */
	dim = ncols(p);
	n   = nrows(p);
	if(dim <= 0 || n <= 0){
		error("Invalid input matrix.");
	}

	if (n > dim+1) {

		int i, j;
		int exitcode;
		int curlong, totlong;

		i=0,j=0;
		pt_array = (double *) R_alloc(n*dim, sizeof(double)); 
		for(i=0; i < n; i++)
			for(j=0; j < dim; j++)
				pt_array[dim*i+j] = REAL(p)[i+n*j];
		ismalloc = False;   /* True if qhull should free points in qh_freeqhull() or reallocation */

		exitcode = qh_new_qhull(dim, n, pt_array, ismalloc, flags, outfile, errfile); 
		if (!exitcode) {                    /* 0 if no error from qhull */

			facetT *facet;                  /* set by FORALLfacets */
			vertexT *vertex, **vertexp;

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
			}

      PROTECT(retval = allocMatrix(INTSXP, nf, dim+1));
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
            INTEGER(retval)[i + nf*j] = 1 + qh_pointid(vertex->point);
            j++;
					}
					i++;
				}
			}
      UNPROTECT(1);
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
		/* one should check if nx points span a simplex
		// I will look at this later.
		*/
		int i;
		PROTECT(retval = allocVector(REALSXP, n));
		for (i=0;i<n;i++) {
			REAL(retval)[i] = i + 1.0;
		}
		UNPROTECT(1);
	}

	/* fclose(outfile); */
	return retval;
}


