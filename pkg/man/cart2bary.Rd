\name{cart2bary}
\alias{cart2bary}
\title{Conversion of Cartesian to Barycentric coordinates.}
\usage{cart2bary(T, P)}
\description{Given the Cartesian coordinates of one or more points,  with
compute the barycentric coordinates of these points with respect to
a simplex.}
\details{Given a reference simplex in \eqn{N} dimensions represented by a
\eqn{N+1}-by-\eqn{N} matrix an arbitrary point \eqn{\mathbf{P}}
in Cartesian coordinates, represented by a 1-by-\eqn{N} row
vector, can be written as
\deqn{\mathbf{P} = \mathbf{\beta}\mathbf{T}}
where \eqn{\mathbf{\beta}} is a \eqn{N+1} vector of the
barycentric coordinates. A criterion on \eqn{\mathbf{\beta}} is
that \deqn{\sum_i\beta_i = 1} Now partition the simplex into its
first \eqn{N} rows \eqn{\mathbf{T}_N} and its \eqn{N+1}th row
\eqn{\mathbf{T}_{N+1}}. Partition the barycentric coordinates
into the first \eqn{N} columns \eqn{\mathbf{\beta}_N} and the \eqn{N+1}th
column \eqn{\beta_{N+1}}. This allows us to write
\deqn{\mathbf{P - T}_{N+1} = \mathbf{\beta}_N\mathbf{T}_N + \mathbf{\beta}_{N+1}\mathbf{T}_{N+1} - \mathbf{T}_{N+1}}
which can be written
\deqn{\mathbf{P - T}_{N+1} = \mathbf{\beta}_N(\mathbf{T}_N - \mathbf{1}\mathbf{T}_{N+1})}
where \eqn{\mathbf{1}} is a \eqn{N}-by-1 matrix of ones. 
We can then solve for \eqn{\mathbf{\beta}_N}:
\deqn{\mathbf{\beta}_N = \mathbf{P - T}_{N+1}(\mathbf{T}_N - \mathbf{1}\mathbf{T}_{N+1})^{-1}}
and compute \deqn{\beta_{N+1} = 1 - \sum_{i=1}^N\beta_i}
This can be  generalised for multiple values of \eqn{\mathbf{P}},
one per row.}
\value{\eqn{M}-by-\eqn{N} matrix in which each row is the
Cartesian coordinates of corresponding row of \code{P}}
\author{David Sterratt}
\arguments{\item{T}{Reference simplex in \eqn{N} dimensions represented by a
\eqn{N+1}-by-\eqn{N} matrix}
\item{P}{\eqn{M}-by-\eqn{N} matrix in which each row is the
Cartesian coordinates of a point.}}
