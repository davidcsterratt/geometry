/* This file is included via Makevars in all C files */
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <Rembedded.h>
/* R check doesn't like stderr and stdout. They can be redefined to
   NULL to prevent output. The alternative approach of trying to use
   R_Outputfile and R_Consolefile doesn't seem to work across also
   architectures. */
/*#undef stderr
  #define stderr NULL */
FILE * tmpstdout;
#undef stdout
#define stdout tmpstdout
/* PI has been defined by the R header files, but the Qhull package
   defines it again, so undefine it here. */
#undef PI
