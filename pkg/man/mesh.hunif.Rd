\name{mesh.hunif}
\alias{mesh.hunif}
\title{Uniform desired edge length}
\usage{
mesh.hunif(p, ...)
}
\arguments{
  \item{p}{A \code{n}-by-\code{m} matrix, each row
  representing a point in an \code{m}-dimensional space.}

  \item{...}{additional arguments (not used)}
}
\value{
Vector of ones of length \code{n}.
}
\description{
Uniform desired edge length function of position to allow
easy definition of regions when passed as the \code{fh}
argument of \code{\link{distmesh2d}} or
\code{\link{distmeshnd}}.
}
\author{
Raoul Grasman; translated from original Matlab sources of
Per-Olof Persson.
}
\seealso{
\code{\link{distmesh2d}} and \code{\link{distmeshnd}}.
}

