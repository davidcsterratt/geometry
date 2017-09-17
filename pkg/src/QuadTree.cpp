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
// 3 may 2017: copy from package lidR to package geometry by Jean-Romain Roussel to operate in fast tsearch funtion

#include "QuadTree.h"
#include <cmath>
#include <limits>

Point::Point(){}
Point::Point(const double x, const double y) : x(x), y(y), id(0) {}
Point::Point(const double x, const double y, const int id) : x(x), y(y), id(id) {}

BoundingBox::BoundingBox(){}
BoundingBox::BoundingBox(const Point center, const Point half_res) : center(center), half_res(half_res) {}

bool BoundingBox::contains(const Point& p)
{
  if(p.x >= center.x - half_res.x && p.x <= center.x + half_res.x &&	p.y >= center.y - half_res.y && p.y <= center.y + half_res.y)
    return true;
  else
    return false;
}

bool BoundingBox::intersects(const BoundingBox& b)
{
  
  if(center.x - half_res.x <= b.center.x + b.half_res.x &&
     center.x + half_res.x >= b.center.x - b.half_res.x &&
     center.y - half_res.y <= b.center.y + b.half_res.y &&
     center.y + half_res.y >= b.center.y - b.half_res.y)
  {
    return true;
  }
  else
    return false;
}

QuadTree::QuadTree(const double cx, const double cy, const double range)
{
  MAX_DEPTH = 6;
  
  boundary = BoundingBox(Point(cx, cy), Point(range, range));
  depth = 1;
  
  NE = 0;
  NW = 0;
  SE = 0;
  SW = 0;
}

QuadTree::QuadTree(const BoundingBox boundary, const int parent_depth) : boundary(boundary)
{
  MAX_DEPTH = 6;
  
  depth = parent_depth + 1;
  
  NE = 0;
  NW = 0;
  SE = 0;
  SW = 0;
}

QuadTree::~QuadTree()
{
  delete NE;
  delete NW;
  delete SE;
  delete SW;
}

QuadTree* QuadTree::create(const std::vector<double> x, const std::vector<double> y)
{
  int n = x.size();
  
  double xmin = x[0];
  double ymin = y[0];
  double xmax = x[0];
  double ymax = y[0];
  
  for(int i = 0 ; i < n ; i++)
  {
    
    if(x[i] < xmin)
      xmin = x[i];
    else if(x[i] > xmax)
      xmax = x[i];
    
    if(y[i] < ymin)
      ymin = y[i];
    else if(y[i] > ymax)
      ymax = y[i];
  }
  
  double xrange = xmax - xmin;
  double yrange = ymax - ymin;
  double range = xrange > yrange ? xrange/2 : yrange/2;
  
  QuadTree *tree = new QuadTree( (xmin+xmax)/2, (ymin+ymax)/2, range);
  
  for(int i = 0 ; i < n ; i++)
  {
    Point p(x[i], y[i], i);
    tree->insert(p);
  }
  
  return tree;
}

bool QuadTree::insert(const Point& p)
{
  if(!boundary.contains(p))
    return false;
  
  if(depth == MAX_DEPTH)
  {
    points.push_back(p);
    return true;
  }
  
  if(NW == 0)
    subdivide();
  
  if(NW->insert(p))
    return true;
  if(NE->insert(p))
    return true;
  if(SW->insert(p))
    return true;
  if(SE->insert(p))
    return true;
  
  return false;
}

void QuadTree::subdivide()
{
  double half_res_half = boundary.half_res.x * 0.5;
  
  Point p(half_res_half, half_res_half);
  Point pNE(boundary.center.x + half_res_half, boundary.center.y + half_res_half);
  Point pNW(boundary.center.x - half_res_half, boundary.center.y + half_res_half);
  Point pSE(boundary.center.x + half_res_half, boundary.center.y - half_res_half);
  Point pSW(boundary.center.x - half_res_half, boundary.center.y - half_res_half);
  
  NE = new QuadTree(BoundingBox(pNE, p), depth);
  NW = new QuadTree(BoundingBox(pNW, p), depth);
  SE = new QuadTree(BoundingBox(pSE, p), depth);
  SW = new QuadTree(BoundingBox(pSW, p), depth);
}

void QuadTree::range_lookup(const BoundingBox bb, std::vector<Point*>& res, const int method)
{
  if(!boundary.intersects(bb))
    return;
  
  if(depth == MAX_DEPTH)
  {
    switch(method)
    {
    case 1: getPointsSquare(bb, points, res);
      break;
      
    case 2: getPointsCircle(bb, points, res);
      break;
    }
  }
  
  if(NW == 0)
    return;
  
  NE->range_lookup(bb, res, method);
  NW->range_lookup(bb, res, method);
  SE->range_lookup(bb, res, method);
  SW->range_lookup(bb, res, method);
  
  return;
}

void QuadTree::rect_lookup(const double xc, const double yc, const double half_width, const double half_height, std::vector<Point*>& res)
{
  range_lookup(BoundingBox(Point(xc, yc), Point(half_width, half_height)), res, 1);
  return;
}


void QuadTree::circle_lookup(const double cx, const double cy, const double range, std::vector<Point*>& res)
{
  range_lookup(BoundingBox(Point(cx, cy), Point(range, range)), res, 2);
  return;
}

void QuadTree::getPointsSquare(const BoundingBox bb, std::vector<Point>& points, std::vector<Point*>& res)
{
  for(std::vector<Point>::iterator it = points.begin(); it != points.end(); it++)
  {
    if(in_rect(bb, *it))
      res.push_back(&(*it));
  }
  return;
}

void QuadTree::getPointsCircle(const BoundingBox bb, std::vector<Point>& points, std::vector<Point*>& res)
{
  for(std::vector<Point>::iterator it = points.begin(); it != points.end(); it++)
  {
    if(in_circle(bb.center, (*it), bb.half_res.x))
      res.push_back(&(*it));
  }
  return;
}

bool QuadTree::in_circle(const Point& p1, const Point& p2, const double r)
{
  double A = p1.x - p2.x;
  double B = p1.y - p2.y;
  double d = sqrt(A*A + B*B);
  
  return(d <= r);
}

bool QuadTree::in_rect(const BoundingBox& bb, const Point& p)
{
  double A = bb.center.x - p.x;
  double B = bb.center.y - p.y;
  A = A < 0 ? -A : A;
  B = B < 0 ? -B : B;
  
  return(A <= bb.half_res.x && B <= bb.half_res.y);
}