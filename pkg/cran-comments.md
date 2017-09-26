From the NEWS file

CHANGES IN VERSION 0.4.0 - Released 2017/09/26

API CHANGES

* Default options to delaunayn have been changed
  https://github.com/davidcsterratt/geometry/issues/4
  The Qc and Qz or Qx options have been added as defaults, making the
  default options "Qbb Qc Qt Qz" for 3 dimensions or less and "Qbb Qc
  Qt Qx" for 4 or more dimensions. This brings the R implementation
  into line with Octave, and very similar to matlab and
  scipy.spatial.Delaunayn .

* distmesh2d() has a plot option
  https://github.com/davidcsterratt/geometry/issues/15
  The new plot option (TRUE by default) allows plotting to during mesh
  generation to be suspended, which is useful for running tests. The
  use of cat() has been replaced by message(), meaning messages can be
  supressed, for example during tests.

* extprod3d() has a "drop" option
  https://github.com/davidcsterratt/geometry/issues/16
  Setting drop=FALSE guarantees that the output of extprod3d() is an
  array rather than a vector, even when presented with two vectors.

NEW FUNCTIONS

* New function inhulln() to test if points are in a hull
  https://github.com/davidcsterratt/geometry/issues/1

* Functions cart2sph, sph2cart, cart2pol, pol2cart ported from Octave
  https://github.com/davidcsterratt/geometry/issues/14

BUG FIXES

* Fix for Issue #6072: distmesh2d - convergence problem
  (https://r-forge.r-project.org/tracker/?func=detail&atid=4552&aid=6072&group_id=1149)
  Some parts of the original Matlab implementation of distmesh2d were
  omitted during the translation to R. The effect is not obvious on
  some problems, except for long convergence times due to excessive
  iterations - some do not converge at all. Graham Griffiths made
  changes to the code which appears to have fixed the problem as
  example problems now appear to run significantly faster - even
  faster than those I have run using Matlab. Graham's example code is now included in a test.
  Thanks to Graham Griffiths for reporting this problem and supplying the fix.

CODE IMPROVEMENTS

* The 2D tsearch C code has been replaced by a much more efficient
  QuadTree algorithm written in C++ by Jean-Romain Roussel. The
  speedup with uniformly distribued mesh points and search points is
  of the order of 40x. Many thanks to Jean-Romain for the
  contribution.
  https://github.com/davidcsterratt/geometry/issues/9
  https://github.com/davidcsterratt/geometry/pull/8

* The new reentrant Qhull library is used, as a precursor to allowing
  Qhull objects to be returned and operated on
  https://github.com/davidcsterratt/geometry/issues/3

* convhulln() now returns a pointer to the qhull object representing
  the hull.
  https://github.com/davidcsterratt/geometry/issues/2
  This is used in the inhull() implementation

* delaunayn() now returns a pointer to the qhull object representing
  the triangulation
  https://github.com/davidcsterratt/geometry/issues/7

* tsearchn() can take an delaunay object, which should give fast
  performance
  https://github.com/davidcsterratt/geometry/issues/6
  NOTE: This feature is experimental and has only been tested
  on 3D triangulations

* Test added for polyarea()
  Thanks to Toby Hocking for suggesting adding one
