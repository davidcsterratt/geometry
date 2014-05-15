\name{bary2cart}
\alias{bary2cart}
\title{Conversion of Barycentric to Cartesian coordinates}
\usage{
bary2cart(X, Beta)
}
\arguments{
  \item{X}{Reference simplex in \eqn{N} dimensions
  represented by a \eqn{N+1}-by-\eqn{N} matrix}

  \item{Beta}{\eqn{M} points in baryocentric coordinates
  with respect to the simplex \code{X} represented by a
  \eqn{M}-by-\eqn{N+1} matrix}
}
\value{
\eqn{M}-by-\eqn{N} matrix in which each row is the
Cartesian coordinates of corresponding row of \code{Beta}
}
\description{
Given the baryocentric coordinates of one or more points
with respect to a simplex, compute the Cartesian
coordinates of these points.
}
\author{
David Sterratt
}

