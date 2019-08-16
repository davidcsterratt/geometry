/*
  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the
  Free Software Foundation; either version 3 of the License, or (at your
  option) any later version.
  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  for more details.
  You should have received a copy of the GNU General Public License
  along with this program. If not, see  <http://www.gnu.org/licenses/>.
*/

// Originally written for package lidR by Jean-Romain Roussel
// Author: Jean-Romain Roussel
//  3  may 2017: copy from package lidR to package geometry by Jean-Romain Roussel to replace former code of tsearch
//  4  may 2017: Add barycentric coordinates support to reproduce original tsearch function
// 23 sept 2017: fix bug of computeur precision by Jean-Romain Roussel


// [[Rcpp::depends(RcppProgress)]]
#include <progress.hpp>
#include <Rcpp.h>
#include "QuadTree.h"

using namespace Rcpp;

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

bool PointInTriangle(Point p0, Point p1, Point p2, Point p, Point* bary, double eps)
{
  double det = ((p1.y - p2.y)*(p0.x - p2.x) + (p2.x - p1.x)*(p0.y - p2.y));
  double a = ((p1.y - p2.y)*(p.x - p2.x) + (p2.x - p1.x)*(p.y - p2.y)) / det;
  double b = ((p2.y - p0.y)*(p.x - p2.x) + (p0.x - p2.x)*(p.y - p2.y)) / det;
  double c = 1 - a - b;
  
  bary->x = c;
  bary->y = b;
  
  return -eps <= a && a <= 1+eps && -eps <= b && b <= 1+eps && -eps <= c && c <= 1+eps;
}

//' @importFrom Rcpp sourceCpp
// [[Rcpp::export]]
SEXP C_tsearch(NumericVector x,  NumericVector y, IntegerMatrix elem, NumericVector xi, NumericVector yi, bool bary = false, double eps = 1.0e-12)
{ 
  QuadTree *tree = QuadTree::create(as< std::vector<double> >(xi),as< std::vector<double> >(yi), eps);

  int nelem = elem.nrow();
  int np = xi.size();

  // set false -> true if you want to display a progressbar
  Progress p(nelem, false);

  IntegerVector indexes(np);
  std::fill(indexes.begin(), indexes.end(), NA_INTEGER);
  
  NumericMatrix barycentric;
  
  if(bary)
  {
    barycentric = NumericMatrix(np, 3);
    std::fill(barycentric.begin(), barycentric.end(), NA_REAL);
  }

  // Loop over each triangle
  for (int k = 0; k < nelem; k++)
  {
    if (Progress::check_abort() )
    {
      delete tree;
      return indexes;
    }
    else
      p.update(k);

    // Retrieve triangle A B C coordinates

    int iA = elem(k, 0) - 1;
    int iB = elem(k, 1) - 1;
    int iC = elem(k, 2) - 1;

    Point A(x(iA), y(iA));
    Point B(x(iB), y(iB));
    Point C(x(iC), y(iC));

    // Boundingbox of A B C

    double rminx = min(A.x, B.x, C.x);
    double rmaxx = max(A.x, B.x, C.x);
    double rminy = min(A.y, B.y, C.y);
    double rmaxy = max(A.y, B.y, C.y);

    double xcenter =     (rminx + rmaxx)/2;
    double ycenter =     (rminy + rmaxy)/2;
    double half_width =  (rmaxx - rminx)/2;
    double half_height = (rmaxy - rminy)/2;

    // QuadTree search of points in enclosing boundingbox

    std::vector<Point*> points;
    tree->rect_lookup(xcenter, ycenter, half_width + eps, half_height + eps, points);

    // Compute if the points are in A B C

    for (unsigned int i = 0 ; i < points.size() ; i++)
    {
      Point pbary;
      
      if (PointInTriangle(A, B, C, *points[i], &pbary, eps))
      {
        int id = points[i]->id;
        indexes(id) = k + 1;
        
        if(bary)
        {
          barycentric(id, 0) = 1 - pbary.x - pbary.y;
          barycentric(id, 1) = pbary.y;
          barycentric(id, 2) = pbary.x;
        }
      }
    }
  }

  delete tree;
  
  if (bary)
  {
   return (List::create(indexes, barycentric));
  }
  else
    return (indexes);
}
