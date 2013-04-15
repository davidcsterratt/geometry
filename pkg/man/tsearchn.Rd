\name{tsearchn}
\alias{tsearchn}
\title{Search for the enclosing Delaunay convex hull}
\usage{
  tsearchn(x, t, xi, fast = TRUE)
}
\arguments{
  \item{x}{An \code{n}-by-\code{d} matrix.  The rows of
  \code{x} represent \code{n} points in
  \code{d}-dimensional space.}

  \item{t}{A \code{m}-by-\code{d+1} matrix. A row of
  \code{t} contains indices into \code{x} of the vertices
  of a \code{d}-dimensional simplex. \code{t} is usually
  the output of delaunayn.}

  \item{xi}{An \code{ni}-by-\code{d} matrix.  The rows of
  \code{xi} represent \code{n} points in
  \code{d}-dimensional space whose positions in the mesh
  are being sought.}

  \item{fast}{If the data is in 2D, use the fast C-based
  \code{tsearch} function to produce the results.}
}
\value{
  A list containing: \item{list("idx")}{An \code{ni}-long
  vector containing the indicies of the row of \code{t} in
  which each point in \code{xi} is found.}
  \item{list("p")}{An \code{ni}-by-\code{d+1} matrix
  containing the barycentric coordinates with respect to
  the enclosing simplex of each point in \code{xi}.}
}
\description{
  For \code{t = delaunayn(x)}, where \code{x} is a set of
  points in \code{d} dimensions, \code{tsearchn(x, t, xi)}
  finds the index in \code{t} containing the points
  \code{xi}. For points outside the convex hull, \code{idx}
  is \code{NA}. \code{tsearchn} also returns the
  barycentric coordinates \code{p} of the enclosing
  triangles.
}
\note{
  Based on the Octave function Copyright (C) 2007-2012
  David Bateman.
}
\author{
  David Sterratt
}
\seealso{
  tsearch, delaunayn
}

