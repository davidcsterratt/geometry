\name{entry.value}
\alias{entry.value}
\alias{entry.value<-}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Retrieve or set a list of array element values }
\description{
  \code{entry.value} retrieves or sets the values in an array \code{a} at the positions indicated
  by the rows of a matrix \code{idx}.
}
\usage{
entry.value(a, idx)
entry.value(a, idx) <- value
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{a}{ An array. }
  \item{idx}{ Numerical matrix with the same number of columns as the number of dimensions of \code{a}.
  Each row indices a cell in \code{a} of which the value is to be retrieved or set. }
  \item{value}{ An array of length \code{nrow(idx)}. }
}
\value{
  \code{entry.value(a,idx)} returns a vector of values at the indicated cells.
  \code{entry.value(a,idx) <- val} changes the indicated cells of \code{a} to \code{val}.
}


\author{ Raoul Grasman }

\examples{
a = array(1:(4^4),c(4,4,4,4))
entry.value(a,cbind(1:4,1:4,1:4,1:4))
entry.value(a,cbind(1:4,1:4,1:4,1:4)) <- 0

entry.value(a, as.matrix(expand.grid(1:4,1:4,1:4,1:4)))
     # same as `c(a[1:4,1:4,1:4,1:4])' which is same as `c(a)'
}


\keyword{ arith }% at least one, from doc/KEYWORDS
\keyword{ math }% __ONLY ONE__ keyword per line
\keyword{ array }% __ONLY ONE__ keyword per line
