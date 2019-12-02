/* This file is included via Makevars in all C files */
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

/* The following fixes a problem R check has with stderr. I tried
   redefining as NULL to prevent output, but a FILE handle is needed
   by qh_new_qhull() due to a call to freopen() somewhere in the
   library. Qhull already defines a dummy stderr qh_FILEstderr in
   libqhull_r.h */
#undef stderr
#define stderr qh_FILEstderr

/* PI has been defined by the R header files, but the Qhull package
   defines it again, so undefine it here. */
#undef PI

/* Size of error string to pass back to R from QH */
#define ERRSTRSIZE 1000

#include "qhull_ra.h"

void freeQhull(qhT *qh);
void qhullFinalizer(SEXP ptr);
boolT hasPrintOption(qhT *qh, qh_PRINT format);
int qhullNewQhull(qhT *qh, const SEXP p, char* cmd, const SEXP options, const SEXP tmp_stdout, const SEXP tmp_stderr, unsigned int* pdim, unsigned int* pn, char errstr[1000]);
