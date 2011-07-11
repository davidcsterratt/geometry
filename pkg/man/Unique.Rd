\name{Unique}
\alias{Unique}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ Extract Unique Rows }
\description{
  \sQuote{Unique} returns a vector, data frame or array like 'x' but with
     duplicate  elements removed.
}
\usage{
Unique(X, rows.are.sets=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{X}{ Numerical matrix. }
  \item{rows.are.sets}{ If \sQuote{\code{TRUE}}, rows are treated as sets - i.e., to define uniqueness,
  the order of the rows does not matter. }
}
\value{
  Matrix of the same number of columns as \code{x}, with the unique rows in \code{x} sorted according
  to the columns of \code{x}. If \code{rows.are.sets = TRUE} the rows are also sorted.
}
\note{
    \sQuote{\code{Unique}} is (under circumstances) much quicker than the more generic base function
    \sQuote{\code{unique}}.
}


\author{ Raoul Grasman }

\examples{
# `Unique' is faster than `unique'
x = matrix(sample(1:(4*8),4*8),ncol=4)
y = x[sample(1:nrow(x),3000,TRUE), ]
gc(); system.time(unique(y))
gc(); system.time(Unique(y))

#
z = Unique(y)
x[matorder(x),]
z[matorder(z),]

}


\keyword{ arith }% at least one, from doc/KEYWORDS
\keyword{ math }% __ONLY ONE__ keyword per line
\keyword{ array }% __ONLY ONE__ keyword per line
