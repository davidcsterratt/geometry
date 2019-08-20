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

#ifndef QT_H
#define QT_H

#include <vector>

struct Point
{
  double x, y;
  int id;

  Point();
  Point(const double, const double);
  Point(const double, const double, const int);
};

struct BoundingBox
{
  Point center, half_res;

  BoundingBox();
  BoundingBox(const Point,const Point);
  bool contains(const Point&, const double);
  bool intersects(const BoundingBox&);
};

class QuadTree
{
public:
  ~QuadTree();
  static QuadTree* create(const std::vector<double>, const std::vector<double>, const double eps);
  bool insert(const Point&);
  void rect_lookup(const double, const double, const double, const double, std::vector<Point*>&);
  void circle_lookup(const double, const double, const double, std::vector<Point*>&);


private:
  int MAX_DEPTH;
  double EPSILON;
  int depth;
  BoundingBox boundary;
  std::vector<Point> points;
  QuadTree* NE;
  QuadTree* NW;
  QuadTree* SE;
  QuadTree* SW;

  QuadTree(const BoundingBox, const int, const double);

  void subdivide();
  void range_lookup(const BoundingBox, std::vector<Point*>&, const int);
  void getPointsSquare(const BoundingBox, std::vector<Point>&, std::vector<Point*>&);
  void getPointsCircle(const BoundingBox, std::vector<Point>&, std::vector<Point*>&);
  bool in_circle(const Point&, const Point&, const double);
  bool in_rect(const BoundingBox&, const Point&);
};

#endif //QT_H
