\name{extprod3d}
\alias{extprod3d}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Compute external- or `cross'- product of 3D vectors. }
\description{
  Computes the external product
  \deqn{
   \left(x_2  y_3 - x_3  y_2,\; x_3 y_1 - x_1 y_3,\; x_1 y_2 - x_2 y_1 \right)
   }{
   (x2 * y3 - x3 * y2, x3 * y1 - x1 * y3, x1 * y2 - x2 * y1)
   }
   of the 3D vectors in \bold{x} and \bold{y}.
}
\usage{
extprod3d(x, y)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{ \code{n}-by-3 matrix. Each row is one \bold{x}-vector }
  \item{y}{ \code{n}-by-3 matrix. Each row is one \bold{y}-vector }
}
\value{
  \code{n}-by-3 matrix
}

\author{ Raoul Grasman }

\keyword{ arith }% at least one, from doc/KEYWORDS
\keyword{ math }% __ONLY ONE__ keyword per line
\keyword{ array }% __ONLY ONE__ keyword per line
