#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#ifdef WIN32
/* There doesn't seem to be a Windows header file that includes these
   definitions - Rinterface.h is not available.  */
extern FILE * R_Consolefile;
extern FILE * R_Outputfile;
#else
#include <Rinterface.h>
#endif
#undef stderr
#define stderr R_Consolefile
#undef stdout
#define stdout R_Outputfile
#undef PI
