\name{tsearchn}
\alias{tsearchn}
\title{Search for the enclosing Delaunay convex hull}
\usage{tsearchn(x, t, xi)}
\description{For \code{t = delaunayn(x)}, finds the index in \code{t}
containing the points \code{xi}. For points outside the convex
hull, \code{idx} is \code{NA}. \code{tsearchn} also returns the
barycentric coordinates \code{x} of the enclosing triangles.}
\value{A list containing:
\item{\code{idx}}{An \code{ni}-long
vector containing the indicies  of the row of \code{t} in which
each point in \code{xi} is found.}
\item{\code{p}}{An \code{ni}-by-\code{dim+1} matrix
containing the barycentric coordinates with respect to the enclosing simplex of 
each point in \code{xi}.}}
\seealso{delaunayn}
\author{David Sterratt}
\arguments{\item{x}{An \code{n}-by-\code{dim} matrix.  The rows of \code{x}
represent \code{n} points in \code{dim}-dimensional space.}
\item{t}{A \code{m}-by-\code{dim+1} matrix. A row of \code{t}
contains indices into \code{x} of the vertices of a
\code{dim}-dimensional simplex. \code{t} is usually the output of
delaunayn.}
\item{xi}{An \code{ni}-by-\code{dim} matrix.  The rows of
\code{xi} represent \code{n} points in \code{dim}-dimensional
space whose positions in the mesh are being sought.}}
