/* Copyright (C) 2000 Kai Habel
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
29. July 2000 - Kai Habel: first release
2002-04-22 Paul Kienzle
* Use warning(...) function rather than writing to cerr

23. May 2005 - Raoul Grasman: ported to R
* Changed the interface for R
*/

#include "Rgeometry.h"
#define qh_QHimport
#include "qhull_a.h"
#include <unistd.h>              /* For unlink() */

SEXP convhulln(const SEXP p, const SEXP options, const SEXP tmpdir)
{
  SEXP retval, area, vol, retlist, retnames;
  int curlong, totlong, i, j, retlen;
  unsigned int dim, n;
  int exitcode = 1; 
  boolT ismalloc;
  char flags[250];             /* option flags for qhull, see qh_opt.htm */
  int *idx;
  double *pt_array;

  /* Initialise return values */
  area = vol = retlist = R_NilValue;
  retlen = 1;
  retval = R_NilValue;

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
  sprintf(flags,"qhull %s", CHAR(STRING_ELT(options,0))); 
  /* sprintf(flags,"qhull Qt Tcv %s",opts); // removed by Bobby */

  /* Check input matrix */
  dim = ncols(p);
  n   = nrows(p);
  if(dim <= 0 || n <= 0){
    error("Invalid input matrix.");
  }

  j=0;
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
  exitcode = qh_new_qhull (dim,n,pt_array,ismalloc,flags,tmpstdout,errfile);
  fclose(tmpstdout);
  unlink(name);
  free((char *) name); 


  if (!exitcode) {  /* 0 if no error from qhull */

    facetT *facet;              /* set by FORALLfacets */
    vertexT *vertex, **vertexp; /* set by FORALLfacets */
    unsigned int n = qh num_facets;

    PROTECT(retval = allocMatrix(INTSXP, n, dim));
    idx = (int *) R_alloc(n*dim,sizeof(int));

    qh_vertexneighbors();

    i=0;
    FORALLfacets {
      j=0;
      /* qh_printfacet(stdout,facet); */
      FOREACHvertex_ (facet->vertices) {
        /* qh_printvertex(stdout,vertex); */
        if (j >= dim)
          warning("extra vertex %d of facet %d = %d",
                  j++,i,1+qh_pointid(vertex->point));
        else
          idx[i+n*j++] = 1 + qh_pointid(vertex->point);
      }
      if (j < dim) warning("facet %d only has %d vertices",i,j);
      i++;
    }
    j=0;
    for(i=0;i<nrows(retval);i++)
      for(j=0;j<ncols(retval);j++)
        INTEGER(retval)[i+nrows(retval)*j] = idx[i+n*j];

    /* Return area and volume */
    if (qh totarea != 0.0) {
      PROTECT(area = allocVector(REALSXP, 1));
      REAL(area)[0] = qh totarea;
      retlen++;
    }
    if (qh totvol != 0.0) {
      PROTECT(vol = allocVector(REALSXP, 1));
      REAL(vol)[0] = qh totvol;
      retlen++;
    }

    /* Make a list if there is area or volume */
    if(retlen > 1) {
      PROTECT(retlist = allocVector(VECSXP, retlen));
      PROTECT(retnames = allocVector(VECSXP, retlen));
      retlen += 2;
      SET_VECTOR_ELT(retlist, 0, retval);
      SET_VECTOR_ELT(retnames, 0, mkChar("hull"));
      SET_VECTOR_ELT(retlist, 1, area);
      SET_VECTOR_ELT(retnames, 1, mkChar("area"));
      SET_VECTOR_ELT(retlist, 2, vol);
      SET_VECTOR_ELT(retnames, 2, mkChar("vol"));
      setAttrib(retlist, R_NamesSymbol, retnames);
    } else retlist = retval;

    UNPROTECT(retlen);
  }
  qh_freeqhull(!qh_ALL);                /* free long memory */
  qh_memfreeshort (&curlong, &totlong);	/* free short memory and memory allocator */

  if (curlong || totlong) {
    warning("convhulln: did not free %d bytes of long memory (%d pieces)",
	    totlong, curlong);
  }
  if (exitcode) {
    error("Received error code %d from qhull.", exitcode);
  }
  return retlist;
}
