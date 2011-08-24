\name{tsearch}
\alias{tsearch}
\title{Search for the enclosing Delaunay convex hull}
\usage{tsearch(x, y, t, xi, yi)}
\description{For \code{t = delaunay(p)}, where \code{p} is a 2D set of points,
\code{tsearch(p[,1], p[,2], t, xi, yi)} finds the index in \code{t}
containing the points \code{(xi, yi)}.  For points outside the
convex hull the index is \code{NA}.}
\value{The index in \code{t} containing the points \code{(xi,
yi)}.  For points outside the convex hull the index is \code{NA}.}
\author{David Sterratt}
\arguments{\item{x}{X-coordinates of triangluation points}
\item{y}{Y-coordinates of triangluation points}
\item{t}{Triangulation, e.g. produced by \code{t = delaunay(x, y)}}
\item{xi}{X-coordinates of points to test}
\item{yi}{Y-coordinates of points to test}}
