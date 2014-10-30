/*

  Copyright (C) 2002-2011 Andreas Stahel
  Copyright (C) 2011,2014 David Sterratt

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the
  Free Software Foundation; either version 3 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see
  <http://www.gnu.org/licenses/>.

*/

/* Originally written for Octave */
/* Author: Andreas Stahel <Andreas.Stahel@hta-bi.bfh.ch> */
/* 19 August 2011: Ported to R by David Sterratt <david.c.sterratt@ed.ac.uk> */

#include <R.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>

static inline double max (double a, double b, double c)
{
  if (a < b)
    return (b < c ? c : b);
  else
    return (a < c ? c : a);
}

static inline double min (double a, double b, double c)
{
  if (a > b)
    return (b > c ? c : b);
  else
    return (a > c ? c : a);
}

#define REF(x,k,i) x[ielem[k + i*nelem] - 1]

/* for large data set the algorithm is very slow one should presort
 (how?) either the elements of the points of evaluation to cut down
 the time needed to decide which triangle contains the given point

 e.g., build up a neighbouring triangle structure and use a simplex-like
 method to traverse it
*/

SEXP tsearch(SEXP x,  SEXP y, SEXP elem, 
             SEXP xi, SEXP yi,
             SEXP bary)
{
  int ibary = 0;
  if (isLogical(bary)) 
    if (*LOGICAL(bary) == TRUE) 
      ibary = 1;

  /* printf("Here 1\n"); */
  double *rx = REAL(x);
  double *ry = REAL(y);
  int nelem = nrows(elem);
  int *ielem = INTEGER(elem);
  double *rxi = REAL(xi);
  double *ryi = REAL(yi);
  int np = LENGTH(xi);
  /* printf("%i points\n", np); */
  SEXP minx, maxx, miny, maxy;
  PROTECT(minx = allocVector(REALSXP, nelem));
  PROTECT(maxx = allocVector(REALSXP, nelem));
  PROTECT(miny = allocVector(REALSXP, nelem));
  PROTECT(maxy = allocVector(REALSXP, nelem));
  double *rminx = REAL(minx);
  double *rmaxx = REAL(maxx);
  double *rminy = REAL(miny);
  double *rmaxy = REAL(maxy);

  /* Find bounding boxes of each triangle */
  for (int k = 0; k < nelem; k++) {
    /* printf("X[T[%i, 1]] = %f; T[%i, 1] = %i\n", k+1, REF(rx, k, 0), k+1, ielem[k + 0*nelem]); */
    rminx[k] = min(REF(rx, k, 0), REF(rx, k, 1), REF(rx, k, 2)) - DOUBLE_EPS;
    rmaxx[k] = max(REF(rx, k, 0), REF(rx, k, 1), REF(rx, k, 2)) + DOUBLE_EPS;
    rminy[k] = min(REF(ry, k, 0), REF(ry, k, 1), REF(ry, k, 2)) - DOUBLE_EPS;
    rmaxy[k] = max(REF(ry, k, 0), REF(ry, k, 1), REF(ry, k, 2)) + DOUBLE_EPS;
    /* printf("%f %f %f %f\n", rminx[k], rmaxx[k], rminy[k], rmaxy[k]); */
  }

  /* Make space for output */
  SEXP values;
  PROTECT(values = allocVector(INTSXP, np));
  int *ivalues = INTEGER(values);
  SEXP p = NULL;
  double *rp = NULL;
  if (ibary) {
    PROTECT(p = allocMatrix(REALSXP, np, 3));
    rp = REAL(p);
    for (int k = 0; k < 3*np; k++)
      rp[k] = NA_REAL;
  }

  double x0 = 0.0, y0 = 0.0;
  double a11 = 0.0, a12 = 0.0, a21 = 0.0, a22 = 0.0, det = 0.0;

  double xt, yt;
  double dx1, dx2, c1, c2;
  int k = nelem; // k is a counter of elements
  for (int kp = 0; kp < np; kp++) {
    xt = rxi[kp];
    yt = ryi[kp];

    /* check if last triangle contains the next point */
    if (k < nelem) {
      dx1 = xt - x0;
      dx2 = yt - y0;
      c1 = ( a22 * dx1 - a21 * dx2) / det;
      c2 = (-a12 * dx1 + a11 * dx2) / det;
      if ((c1 >= -DOUBLE_EPS) && (c2 >= -DOUBLE_EPS) && ((c1 + c2) <= (1 + DOUBLE_EPS))) {
        ivalues[kp] = k+1;
        if (ibary) {
          rp[kp] = 1 - c1 - c2;
          rp[kp+np] = c1; 
          rp[kp+2*np] = c2;
        }
        continue;
      }
    }

    // it doesn't, so go through all elements
    for (k = 0; k < nelem; k++) {
      /* OCTAVE_QUIT; */
      if (xt >= rminx[k] && xt <= rmaxx[k] && yt >= rminy[k] && yt <= rmaxy[k]) {
        /* printf("Point %i (%1.3f, %1.3f) could be in triangle %i (%1.3f, %1.3f) (%1.3f, %1.3f)\n",  */
        /*        kp+1, xt, yt, k+1, rminx[k], rminy[k], rmaxx[k], rmaxy[k]); */
        // element inside the minimum rectangle: examine it closely
        x0  = REF(rx, k, 0);
        y0  = REF(ry, k, 0);
        /* printf("Triangle %i: x0=%f, y0=%f\n", k+1, x0, y0); */
        a11 = REF(rx, k, 1) - x0;
        a12 = REF(ry, k, 1) - y0;
        a21 = REF(rx, k, 2) - x0;
        a22 = REF(ry, k, 2) - y0;
        det = a11 * a22 - a21 * a12;

        // solve the system
        dx1 = xt - x0;
        dx2 = yt - y0;
        c1 = ( a22 * dx1 - a21 * dx2) / det;
        c2 = (-a12 * dx1 + a11 * dx2) / det;
        if ((c1 >= -DOUBLE_EPS) && (c2 >= -DOUBLE_EPS) && ((c1 + c2) <= (1 + DOUBLE_EPS))) {
          /* printf("Setting point %i's triangle to %i\n", kp+1, k+1);  */
          ivalues[kp] = k+1;
          if (ibary) {
            rp[kp] = 1 - c1 - c2;
            rp[kp+np] = c1; 
            rp[kp+2*np] = c2;
          }
          break;
        }
      } //endif # examine this element closely
    } //endfor # each element
    /* printf("%i\n", kp); */
    if (k == nelem) {
      ivalues[kp] = NA_INTEGER;
    }
  } //endfor # kp

  SEXP ans;
  if (ibary) {
    PROTECT(ans = allocVector(VECSXP, 2));
    SET_VECTOR_ELT(ans, 0, values);
    SET_VECTOR_ELT(ans, 1, p);
    UNPROTECT(7);
    return(ans);
  } else {
    UNPROTECT(5);
    return(values);
  }
}
