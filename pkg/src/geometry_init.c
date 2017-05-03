#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP C_convhulln(SEXP, SEXP, SEXP);
extern SEXP C_delaunayn(SEXP, SEXP, SEXP);
extern SEXP C_inhulln(SEXP, SEXP);
extern SEXP C_tsearch(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP C_tsearchn(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"C_convhulln", (DL_FUNC) &C_convhulln, 3},
    {"C_delaunayn", (DL_FUNC) &C_delaunayn, 3},
    {"C_inhulln",   (DL_FUNC) &C_inhulln,   2},
    {"C_tsearch",   (DL_FUNC) &C_tsearch,   6},
    {"C_tsearchn",   (DL_FUNC) &C_tsearchn, 2},
    {NULL, NULL, 0}
};

void R_init_geometry(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
