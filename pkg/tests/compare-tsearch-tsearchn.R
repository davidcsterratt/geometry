library(geometry)
X <- runif(50)
Y <- runif(50)
T <- delaunayn(cbind(X, Y))
XI <- runif(1000)
YI <- runif(1000)

out <- tsearch(X, Y, T, XI, YI)
outn <- tsearchn(cbind(X, Y), T, cbind(XI, YI))
out <- tsearch(X, Y, T, XI, YI)
print(all(na.omit(out) == na.omit(outn$idx)))

out <- tsearch(X, Y, T, XI, YI, TRUE)
print(all(na.omit(abs(outn$p - out$p) < 1e-12)))
