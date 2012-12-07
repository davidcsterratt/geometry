<!-- This is the project specific website template -->
<!-- It can be changed as liked or replaced by other content -->
<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='http://r-forge.r-project.org/themes/rforge/'; ?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
<meta name="generator" content=
"HTML Tidy for Linux (vers 25 March 2009), see www.w3.org" />
<meta http-equiv="Content-Type" content=
"text/html; charset=us-ascii" />
<title><?php echo $group_name; ?></title>
<link href="%3C?php%20echo%20$themeroot;%20?%3Estyles/estilo1.css"
rel="stylesheet" type="text/css" />
<style type='text/css'>
  /*<![CDATA[*/
/*]]>*/
</style>
</head>

<body>
<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
<td><a href="http://r-forge.r-project.org/"><img src=
    <?php echo '"' . $themeroot . '/images/logo.png"'; ?>
border="0" alt="R-Forge Logo" /></a></td>
</tr>
</table>

<h1>The R geometry package: Mesh generation and surface tesselation</h1>

<p>The geometry package provides <a href=
"http://www.r-project.org/">
R</a> with several geometry functions available in Octave, Matlab and
the like. In particular, it provides an interface to the <a href=
"http://www.qhull.org/">qhull</a> library (which also underlies the
corresponding Matlab and Octave functions). Currently only part of the
qhull library is accessible and the interface for Delaunay
triangulation differs from more modern versions of Matlab.</p>

<p>The geometry package also implements a simple technique to
refine a given mesh and generate high quality meshes and surface
triangulations. A description of the technique and a number of
examples can be found at the site of its inventors <a href=
"http://persson.berkeley.edu/distmesh/">
Per-Olof Persson and Gilbert Strang</a>.</p>

<h2>Downloads</h2>

<ul>
<li>The latest stable version is available from <a href="http://cran.r-project.org/web/packages/geometry/index.html">CRAN</a>.</li>
<li>The latest development version is available from <a href="https://r-forge.r-project.org/R/?group_id=1149">R-Forge project page</a>.</li>
</ul>

<p>Original qhull sources are included in the distribution. The
distribution is subject to <a href=
"http://www.qhull.org/COPYING.txt">
this license</a>. The non-qhull sources are subject to the GPL version
2 or higher.</p>

<h2>Bugs and other issues</h2>

<p>Please look at <a href="https://r-forge.r-project.org/tracker/?group_id=1149">
geometry's R-forge tracker</a> to view known bugs and to report 
bugs and feature requests.</p>

<h2>Using the Qhull options</h2>

<p>Qhull provides many options. For instance you may request the
volume of a convex hull and its surface area by specifying the <tt>FS</tt>
option. Currently the output cannot be accessed directly. However,
Qhull has the option <tt>TO</tt> <em>filename</em> which can be used to write
the output to a file which can then be parsed into R again. For
instance, if you want to compute the volume of a convex hull of a set
of points, if you have a matrix with 3 columns, 

<pre>
&gt; ps &lt;-matrix(rnorm(30),,3)
</pre> 

say, that might be something like:

<pre>
&gt; x &lt;- convhulln(ps,"FS TO 'bla.txt'"); # use of the 'TO filename' option 
</pre> 

This command created the text file <tt>bla.txt</tt> that contains the
requested output (i.e. the output specified by the Qhull options).
For the Qhull option <tt>FS</tt> this is the following: [<a href=
"http://www.qhull.org/html/qh-optf.htm#FS">from
the doc</a>] "The first line consists of the number of integers
("0"). The second line consists of the number of reals ("2"), followed
by the total facet area, and the total volume. Later versions of Qhull
may produce additional integers or reals." You can then parse the text
in the file according to your needs; in your case it will be something
like:

<pre>
&gt; qh.outp &lt;- scan("bla.txt")
&gt; volume &lt;- qh.outp[4]
</pre> 

</p>

<h2>Contribute</h2>

<p>If you have ideas for functions, or functions you made and think
would be of value to include in the geometry package (take into
account that the package is called <code>geometry</code> and
restricts itself to functions directly related to computational
geometry), you can e-mail me <a href="mailto:david.c.sterratt@ed.ac.uk">david.c.sterratt@ed.ac.uk</a>.</p>

</body>
</html>
