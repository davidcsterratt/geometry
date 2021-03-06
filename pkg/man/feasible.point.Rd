% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/intersectn.R
\name{feasible.point}
\alias{feasible.point}
\title{Find point in intersection of convex hulls}
\usage{
feasible.point(ch1, ch2, tol = 0)
}
\arguments{
\item{ch1}{First convex hull with normals}

\item{ch2}{Second convex hull with normals}

\item{tol}{The point must be at least this far within the facets
of both convex hulls}
}
\description{
Find point that lies somewhere in interesction of two convex
hulls. If such a point does not exist, return \code{NA}. The
feasible point is found using a linear program similar to the one
suggested at \url{../doc/qhull/html/qhalf.html#notes}
}
