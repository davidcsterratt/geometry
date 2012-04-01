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
29. July 2000 - Kai Habel: first release
2002-04-22 Paul Kienzle
* Use warning(...) function rather than writing to cerr

23. May 2005 - Raoul Grasman: ported to R
* Changed the interface for R
*/


#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <R.h>
#include <Rdefines.h>
#ifdef WIN32
#else
#include <Rinterface.h>
#endif
#define qh_QHimport
#include "qhull_a.h"

/*
DEFUN_DLD (convhulln, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{H} =} convhulln (@var{p}[, @var{opt}])\n\
Returns an index vector to the points of the enclosing convex hull.\n\
The input matrix of size [n, dim] contains n points of dimension dim.\n\n\
If a second optional argument is given, it must be a string containing\n\
extra options for the underlying qhull command.  (See the Qhull\n\
documentation for the available options.)\n\n\
@seealso{convhull, delaunayn}\n\
@end deftypefn")
*/
SEXP convhulln(const SEXP p, const SEXP options)
{
  SEXP retval, area, vol, retlist, retnames;
  int curlong, totlong, i, j, retlen;
  unsigned int dim, n;
  int exitcode; 
  boolT ismalloc;
  char flags[250];             /* option flags for qhull, see qh_opt.htm */
  char *opts;
  int *idx;
  double *pt_array;
  struct stat file_status;


  /* Bobby */
  area = vol = retlist = NULL;
  retlen = 1;

  /* output from qh_produce_output() use NULL to skip qh_produce_output() */
  FILE *outfile = NULL;          /* No output file */
  FILE *errfile = R_Consolefile; /* error messages from qhull code */
  retval = R_NilValue;

  if(!isString(options) || length(options) != 1){
    error("Second argument must be a single string.");
  }
  if(!isMatrix(p) || !isReal(p)){
    error("First argument should be a real matrix.");
  }

  i=LENGTH(STRING_ELT(options,0));
  opts = (char *) R_alloc( ((i>1)?i:1), sizeof(char) );
  strcpy(opts, " ");
  if(i>1) strcpy(opts, CHAR(STRING_ELT(options,0)));

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

  /* hmm  lot's of options for qhull here */
  /* sprintf(flags,"qhull Qt Tcv %s",opts); // removed by Bobby */
  sprintf(flags,"qhull Qt %s",opts);  // Bobby moved Tcv to default options
  exitcode = qh_new_qhull (dim,n,pt_array,ismalloc,flags,outfile,errfile);

  if (!exitcode) {  /* 0 if no error from qhull */

    facetT *facet;                  /* set by FORALLfacets */
    vertexT *vertex, **vertexp;		/* set by FORALLfacets */
    unsigned int n = qh num_facets;

    PROTECT(retval = allocMatrix(INTSXP, n, dim));
    idx = (int *) R_alloc(n*dim,sizeof(int));

    qh_vertexneighbors();

    i=0;
    FORALLfacets {
      j=0;
      /*std::cout << "Current index " << i << "," << j << std::endl << std::flush;
      // qh_printfacet(stdout,facet);
      */
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

    /* Bobby: return area and volume */
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

    /* Bobby: make a list if there is area or volume */
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

    /* Bobby */
    UNPROTECT(retlen);
    /* UNPROTECT(1); */
  }
  qh_freeqhull(!qh_ALL);					/*free long memory */
  qh_memfreeshort (&curlong, &totlong);	/* free short memory and memory allocator */

  if (curlong || totlong) {
    warning("convhulln: did not free %d bytes of long memory (%d pieces)",
	    totlong, curlong);
  }

  /* If close the outfile, and possibly remove it if it is empty */
  /* fclose(outfile); */
  /* stat("qhull_out.txt", &file_status);
     if((int) file_status.st_size == 0) unlink("qhull_out.txt"); */

  /* Bobby: */
  return retlist;
}
