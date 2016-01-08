/* This file is included via Makevars in all C files */
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
/* R check doesn't like stderr and stdout. I tried redefining as NULL
   to prevent output, but a FILE handle is needed by qh_new_qhull()
   due to a call to freopen() somewhere in the library.The alternative
   approach of trying to use R_Outputfile and R_Consolefile doesn't
   work for Rgui. Hence the creation of this dummy stdout, which is
   pointed to a temporary file in the code. */
FILE * tmpstdout;
#undef stdout
#define stdout tmpstdout

/* For stderr, qhull already defines a dummy stderr qh_FILEstderr in
   libqhull_r.h */
#undef stderr
#define stderr qh_FILEstderr

/* PI has been defined by the R header files, but the Qhull package
   defines it again, so undefine it here. */
#undef PI
