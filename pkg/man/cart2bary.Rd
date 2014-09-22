\name{cart2bary}
\alias{cart2bary}
\title{Conversion of Cartesian to Barycentric coordinates.}
\usage{
cart2bary(X, P)
}
\arguments{
  \item{X}{Reference simplex in \eqn{N} dimensions
  represented by a \eqn{N+1}-by-\eqn{N} matrix}

  \item{P}{\eqn{M}-by-\eqn{N} matrix in which each row is
  the Cartesian coordinates of a point.}
}
\value{
\eqn{M}-by-\eqn{N+1} matrix in which each row is the
barycentric coordinates of corresponding row of \code{P}.
If the simplex is degenerate a warning is issued and the
function returns \code{NULL}.
}
\description{
Given the Cartesian coordinates of one or more points,
compute the barycentric coordinates of these points with
respect to a simplex.
}
\details{
Given a reference simplex in \eqn{N} dimensions represented
by a \eqn{N+1}-by-\eqn{N} matrix an arbitrary point
\eqn{\mathbf{P}} in Cartesian coordinates, represented by a
1-by-\eqn{N} row vector, can be written as \deqn{\mathbf{P}
= \mathbf{\beta}\mathbf{X}} where \eqn{\mathbf{\beta}} is a
\eqn{N+1} vector of the barycentric coordinates. A
criterion on \eqn{\mathbf{\beta}} is that
\deqn{\sum_i\beta_i = 1} Now partition the simplex into its
first \eqn{N} rows \eqn{\mathbf{X}_N} and its \eqn{N+1}th
row \eqn{\mathbf{X}_{N+1}}. Partition the barycentric
coordinates into the first \eqn{N} columns
\eqn{\mathbf{\beta}_N} and the \eqn{N+1}th column
\eqn{\beta_{N+1}}. This allows us to write \deqn{\mathbf{P
- X}_{N+1} = \mathbf{\beta}_N\mathbf{X}_N +
\mathbf{\beta}_{N+1}\mathbf{X}_{N+1} - \mathbf{X}_{N+1}}
which can be written \deqn{\mathbf{P - X}_{N+1} =
\mathbf{\beta}_N(\mathbf{X}_N -
\mathbf{1}\mathbf{X}_{N+1})} where \eqn{\mathbf{1}} is a
\eqn{N}-by-1 matrix of ones.  We can then solve for
\eqn{\mathbf{\beta}_N}: \deqn{\mathbf{\beta}_N = (\mathbf{P
- X}_{N+1})(\mathbf{X}_N -
\mathbf{1}\mathbf{X}_{N+1})^{-1}} and compute
\deqn{\beta_{N+1} = 1 - \sum_{i=1}^N\beta_i} This can be
generalised for multiple values of \eqn{\mathbf{P}}, one
per row.
}
\note{
Based on the Octave function by David Bateman.
}
\examples{
## Define simplex in 2D (i.e. a triangle)
X <- rbind(c(0, 0),
           c(0, 1),
           c(1, 0))
## Cartesian cooridinates of points
P <- rbind(c(0.5, 0.5),
           c(0.1, 0.8))
## Plot triangle and points
trimesh(rbind(1:3), X)
text(X[,1], X[,2], 1:3) # Label vertices
points(P)
cart2bary(X, P)
}
\author{
David Sterratt
}
\seealso{
bary2cart
}

