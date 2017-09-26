# The R geometry package: Mesh generation and surface tessellation

The geometry package provides <a href= "http://www.r-project.org/">
R</a> with several geometry functions available in Octave, Matlab and
SciPy. In particular, it provides an interface to the <a href=
"http://www.qhull.org/">qhull</a> library (which also underlies the
corresponding Matlab and Octave functions). Currently only part of the
qhull library is accessible and the interface for Delaunay
triangulation differs from more modern versions of Matlab.

The geometry package also implements a simple technique to refine a
given mesh and generate high quality meshes and surface
triangulations. A description of the technique and a number of
examples can be found at the site of its inventors <a href=
"http://persson.berkeley.edu/distmesh/"> Per-Olof Persson and Gilbert
Strang</a>.

## Downloads

* The latest stable version is available from <a href="http://cran.r-project.org/web/packages/geometry/index.html">CRAN</a>.

* The latest development version is available on Github <a
href="https://github.com/davidcsterratt/geometry">davidcsterratt/geometry</a>.

Original qhull sources are included in the distribution. The
distribution is subject to <a href=
"http://www.qhull.org/COPYING.txt">
this license</a>. The non-qhull sources are subject to the GPL version
2 or higher.

## Bugs and other issues

Please look at <a
href="https://github.com/davidcsterratt/geometry/issues"> geometry's
Github tracker</a> to view known bugs and to report bugs and feature
requests.

## Contribute

If you have ideas for functions, or functions you made and think would
be of value to include in the geometry package (take into account that
the package is called <code>geometry</code> and restricts itself to
functions directly related to computational geometry), you can e-mail
me <a
href="mailto:david.c.sterratt@ed.ac.uk">david.c.sterratt@ed.ac.uk</a>.

## Tips and wrinkles

### Obtaining volume and area of convex hulls

In older versions of the package, to obtain the volume and area of
  a convex hull, the procedure outlined in the next section had to be
  followed. Now it is possible to recover the area as follows:
```
> ps <-matrix(rnorm(30),,3)
> convhulln(ps, "FA")
> x
$hull
     [,1] [,2] [,3]
[1,]    6    9   10
[2,]    6    2    9
[3,]    7    6   10
[4,]    7    6    2
[5,]    1    9   10
[6,]    1    2    9
[7,]    1    7   10
[8,]    1    7    2

$area
[1] 32.55313

$vol
[1] 11.3083
```

### Using the Qhull options

Qhull provides many options. For instance you may request the
volume of a convex hull and its surface area by specifying the `FS`
option. Currently the output cannot be accessed directly. However,
Qhull has the option `TO` <em>filename</em> which can be used to write
the output to a file which can then be parsed into R again. For
instance, if you want to compute the volume of a convex hull of a set
of points, if you have a matrix with 3 columns, 

```
> ps <-matrix(rnorm(30),,3)
```

say, that might be something like:

```
> x <- convhulln(ps,"FS TO 'bla.txt'"); # use of the 'TO filename' option 
```

This command created the text file `bla.txt` that contains the
requested output (i.e. the output specified by the Qhull options).
For the Qhull option `FS` this is the following: [<a href=
"http://www.qhull.org/html/qh-optf.htm#FS">from
the doc</a>] "The first line consists of the number of integers
("0"). The second line consists of the number of reals ("2"), followed
by the total facet area, and the total volume. Later versions of Qhull
may produce additional integers or reals." You can then parse the text
in the file according to your needs; in your case it will be something
like:

```
> qh.outp <- scan("bla.txt")
> volume <- qh.outp[4]
```

<!--  LocalWords:  href Matlab SciPy qhull Olof Persson Strang CRAN
 -->
<!--  LocalWords:  davidcsterratt GPL ps rnorm convhulln FS bla txt
 -->
<!--  LocalWords:  qh outp
 -->
