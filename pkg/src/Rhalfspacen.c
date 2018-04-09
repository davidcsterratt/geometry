/* Copyright (C) 2018 David Sterratt
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
#include <unistd.h>              /* For unlink() */

SEXP C_halfspacen(const SEXP p, const SEXP options, const SEXP tmpdir)
{
  SEXP retval;
  int i, j;
  unsigned int dim, n;
  int exitcode = 1; 
  boolT ismalloc;
  char flags[250];             /* option flags for qhull, see qh_opt.htm */
  double *pt_array;

  /* We cannot print directly to stdout in R, and the alternative of
     using R_Outputfile does not seem to work for all
     architectures. Setting outfile to NULL, is not an option, as an
     open file handle is required for a call to freopen in the Qhull
     code when qh_new_qhull() is called. Therefore use the ersatz
     stdout, tmpstdout (see below). */
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
  /* H specifies the halfspace method */
  sprintf(flags,"qhull H %s", CHAR(STRING_ELT(options,0))); 

  /* Check input matrix */
  dim = ncols(p);
  n   = nrows(p);
  if(dim <= 0 || n <= 0){
    error("Invalid input matrix.");
  }

  pt_array = (double *) R_alloc(n*dim, sizeof(double)); 
  for(i=0; i < n; i++)
    for(j=0; j < dim; j++)
      pt_array[dim*i+j] = REAL(p)[i+n*j]; /* could have been pt_array = REAL(p) if p had been transposed */

  ismalloc = False; /* True if qhull should free points in qh_freeqhull() or reallocation */

  /* Jiggery-pokery to create and destroy the ersatz stdout, and the
     call to qhull itself. */    
  const char *name;
  name = R_tmpnam("Rf", CHAR(STRING_ELT(tmpdir, 0)));
  tmpstdout = fopen(name, "w");
  qhT *qh = (qhT*)malloc(sizeof(qhT));
  qh_zero(qh, errfile);
  exitcode = qh_new_qhull (qh, dim, n, pt_array, ismalloc, flags, tmpstdout, errfile);
  fclose(tmpstdout);
  unlink(name);
  free((char *) name); 

  facetT *facet;
  boolT zerodiv;
  coordT *point, *normp, *coordp, *feasiblep;

  if (!exitcode) {  /* 0 if no error from qhull */
    if (!qh->feasible_point) {
      freeQhull(qh);
      error("qhull input error (qh_printafacet): option 'Fp' needs qh->feasible_point");
    }
    
    /* Count facets. Perhaps a better way of doing this is: 
       int numfacets, numsimplicial, numridges, totneighbors, numcoplanars, numtricoplanars;
       int num;
       qh_countfacets(qh, NULL, facets, printall, &numfacets, &numsimplicial,
       &totneighbors, &numridges, &numcoplanars, &numtricoplanars); */
    int nf = 0;
    FORALLfacets {
      nf++;
    }

    /* Output of intersections based on case qh_PRINTpointintersect:
       qh_printafacet() in io_r.c . This corresponds to the "Fp"
       option to the qhull program */
    retval = PROTECT(allocMatrix(REALSXP, nf, dim-1));
    int k;
    i=0; /* Facet counter */
    FORALLfacets {
      point = coordp = (coordT*)qh_memalloc(qh, qh->normal_size);
      if (facet->offset > 0) {
        for (k=qh->hull_dim; k--; ) {
          point[k] = R_PosInf;
        }
      } else {
        normp = facet->normal;
        feasiblep = qh->feasible_point;
        if (facet->offset < -qh->MINdenom) {
          for (k=qh->hull_dim; k--; )
            *(coordp++) = (*(normp++) / - facet->offset) + *(feasiblep++);
        } else {
          for (k=qh->hull_dim; k--; ) {
            *(coordp++) = qh_divzero(*(normp++), facet->offset, qh->MINdenom_1,
                                    &zerodiv) + *(feasiblep++);
            if (zerodiv) {
              for (k=qh->hull_dim; k--; ) {
                point[k] = R_PosInf;
              }
            }
          }
        }
      }
      /* qh_printpoint(qh, fp, NULL, point); */
      for (k=0; k<qh->hull_dim; k++) {
        REAL(retval)[i + k*nf] = point[k];
      }
      qh_memfree(qh, point, qh->normal_size);
      i++; /* Increment facet counter */
    }
  }

  freeQhull(qh);
  UNPROTECT(1);

  if (exitcode) {
    error("Received error code %d from qhull.", exitcode);
  }
  return retval;
}
