#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include "qhull_ra.h"

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
