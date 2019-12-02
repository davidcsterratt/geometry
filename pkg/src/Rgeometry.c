#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include "qhull_ra.h"
#include <unistd.h>              /* For unlink() */

void freeQhull(qhT *qh) {
  int curlong, totlong;
  qh_freeqhull(qh, !qh_ALL);                /* free long memory */
  qh_memfreeshort (qh, &curlong, &totlong);	/* free short memory and memory allocator */
  if (curlong || totlong) {
    warning("convhulln: did not free %d bytes of long memory (%d pieces)",
	    totlong, curlong);
  }
  qh_free(qh);
}

/* Finalizer which R will call when garbage collecting. This is
   registered at the end of convhulln() */
void qhullFinalizer(SEXP ptr)
{
  if(!R_ExternalPtrAddr(ptr)) return;
  qhT *qh;
  qh = R_ExternalPtrAddr(ptr);
  freeQhull(qh);
  R_ClearExternalPtr(ptr); /* not really needed */
}

boolT hasPrintOption(qhT *qh, qh_PRINT format) {
  for (int i=0; i < qh_PRINTEND; i++) {
    if (qh->PRINTout[i] == format) {
      return(True);
    }
  }
  return(False);
}

int qhullNewQhull(qhT *qh, const SEXP p, char* cmd, const SEXP options, const SEXP tmp_stdout, const SEXP tmp_stderr, unsigned int* pdim, unsigned int* pn, char errstr[ERRSTRSIZE]) {
  unsigned int dim, n;
  int exitcode = 1; 
  boolT ismalloc;
  char flags[250];             /* option flags for qhull, see qh_opt.htm */
  double *pt_array;
  int i, j;
  
  /* We cannot print directly to stdout in R, and the alternative of
     using R_Outputfile does not seem to work for all architectures.
     Setting outfile to NULL is not an option, as an open file handle
     is required for a call to freopen in the Qhull code when
     qh_new_qhull() is called. Therefore use the ersatz stdout,
     tmpstdout (see below). */
  /* qh_fprintf() in userprint.c has been redefined so that a NULL
     errfile results in printing via REprintf(). */
  FILE *tmpstdout = NULL;
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
  sprintf(flags, "%s %s", cmd, CHAR(STRING_ELT(options,0)));

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
  const char *name, *errname;
  name = CHAR(STRING_ELT(tmp_stdout, 0));
  tmpstdout = fopen(name, "w");
  errname = CHAR(STRING_ELT(tmp_stderr, 0));
  errfile = fopen(errname, "w+");
  qh_zero(qh, errfile);
  exitcode = qh_new_qhull (qh, dim, n, pt_array, ismalloc, flags, tmpstdout, errfile);
  fclose(tmpstdout);
  unlink(name);
  rewind(errfile);
  char buf[200];
  errstr[0] = '\0';
  while(fgets(buf, sizeof(buf), errfile) != NULL &&
        (ERRSTRSIZE - strlen(errstr) - 1) > 0) {
    errstr = strncat(errstr, buf, ERRSTRSIZE - strlen(errstr) - 1);
  }
  
  fclose(errfile);
  unlink(errname);

  *pdim = dim;
  *pn = n;
  return(exitcode);
}
