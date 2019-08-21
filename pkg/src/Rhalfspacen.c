/* Copyright (C) 2018, 2019 David Sterratt
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
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

#include "Rgeometry.h"
#include "qhull_ra.h"
#include <unistd.h>              /* For unlink() */

SEXP C_halfspacen(const SEXP p, const SEXP options, const SEXP tmp_stdout, const SEXP tmp_stderr)
{
  /* Return value*/
  SEXP retval;

  /* Run Qhull */
  qhT *qh= (qhT*)malloc(sizeof(qhT));
  char errstr[ERRSTRSIZE];
  unsigned int dim, n;
  char cmd[50] = "qhull H";
  int exitcode = qhullNewQhull(qh, p, cmd,  options, tmp_stdout, tmp_stdout, &dim, &n, errstr);

  /* If error */
  if (exitcode) {
    freeQhull(qh);
    error("Received error code %d from qhull. Qhull error:\n%s", exitcode, errstr);
  }

  if (!qh->feasible_point) {
    freeQhull(qh);
    error("qhull input error (qh_printafacet): option 'Fp' needs qh->feasible_point");
  }
  
  /* Extract information from output */
  int i;
  facetT *facet;
  boolT zerodiv;
  coordT *point, *normp, *coordp, *feasiblep;
    
  /* Count facets. Perhaps a better way of doing this is: 
     int numfacets, numsimplicial, numridges, totneighbors, numcoplanars, numtricoplanars;
     int num;
     qh_countfacets(qh, NULL, facets, printall, &numfacets, &numsimplicial,
     &totneighbors, &numridges, &numcoplanars, &numtricoplanars); */
  int nf = 0;
  FORALLfacets {
    nf++;
  }

  /* Output of intersections based on case qh_PRINTpointintersect:
     qh_printafacet() in io_r.c . This corresponds to the "Fp"
     option to the qhull program */
  retval = PROTECT(allocMatrix(REALSXP, nf, dim-1));
  int k;
  i=0; /* Facet counter */
  FORALLfacets {
    point = coordp = (coordT*)qh_memalloc(qh, qh->normal_size);
    if (facet->offset > 0) {
      for (k=qh->hull_dim; k--; ) {
        point[k] = R_PosInf;
      }
    } else {
      normp = facet->normal;
      feasiblep = qh->feasible_point;
      if (facet->offset < -qh->MINdenom) {
        for (k=qh->hull_dim; k--; )
          *(coordp++) = (*(normp++) / - facet->offset) + *(feasiblep++);
      } else {
        for (k=qh->hull_dim; k--; ) {
          *(coordp++) = qh_divzero(*(normp++), facet->offset, qh->MINdenom_1,
                                   &zerodiv) + *(feasiblep++);
          if (zerodiv) {
            for (k=qh->hull_dim; k--; ) {
              point[k] = R_PosInf;
            }
          }
        }
      }
    }
    /* qh_printpoint(qh, fp, NULL, point); */
    for (k=0; k<qh->hull_dim; k++) {
      REAL(retval)[i + k*nf] = point[k];
    }
    qh_memfree(qh, point, qh->normal_size);
    i++; /* Increment facet counter */
  }

  freeQhull(qh);
  UNPROTECT(1);

  return retval;
}
