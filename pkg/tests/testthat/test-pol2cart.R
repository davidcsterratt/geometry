context("pol2cart")
test_that("pol2cart works correctly", {

 t <- c(0, 0.5, 1)*pi
 r <- 1
 C <- pol2cart(t, r)
 expect_equal(C[,"x"], c(1, 0, -1))
 expect_equal(C[,"y"], c(0, 1,  0))


 t <- c(0, 1, 1)*pi/4
 r <- sqrt(2)*c(0, 1, 2)
 C <- pol2cart(t, r)
 expect_equal(C[,"x"], c(0, 1, 2))
 expect_equal(C[,"y"], c(0, 1, 2))

 t <- c(0, 1, 1)*pi/4
 r <- sqrt(2)*c(0, 1, 2)
 z <- c(0, 1, 2)
 C <- pol2cart(t, r, z)
 expect_equal(C[,"x"], c(0, 1, 2))
 expect_equal(C[,"y"], c(0, 1, 2))
 expect_equal(C[,"z"], z)


 t <- 0
 r <- c(0, 1, 2)
 z <- c(0, 1, 2)
 C <- pol2cart (t, r, z)
 expect_equal (C[,"x"], c(0, 1, 2))
 expect_equal (C[,"y"], c(0, 0, 0))
 expect_equal (C[,"z"], z)


 t <- c(1, 1, 1)*pi/4
 r <- 1
 z <- c(0, 1, 2)
 C <- pol2cart (t, r, z)
 expect_equal(C[,"x"], c(1, 1, 1)/sqrt(2))
 expect_equal(C[,"y"], c(1, 1, 1)/sqrt(2))
 expect_equal(C[,"z"], z)

 
 t <- 0
 r <- c(1, 2, 3)
 z <- 1
 C <- pol2cart (t, r, z)
 expect_equal(C[,"x"], c(1, 2, 3))
 expect_equal(C[,"y"], c(0, 0, 0)/sqrt (2))
 expect_equal(C[,"z"], c(1, 1, 1))

 P <- rbind(c(theta=0, r=0),
            c(pi/4, sqrt(2)),
            c(pi/4, 2*sqrt(2)))
 C <- rbind(c(x=0, y=0),
            c(1, 1),
            c(2, 2))
 expect_equal(pol2cart(P), C)

## %!test
## %! P <- c(0, 0, 0 pi/4, sqrt(2), 1 pi/4, 2*sqrt(2), 2)
## %! C <- c(0, 0, 0 1, 1, 1 2, 2, 2)
## %! expect_equal (pol2cart (P), C, sqrt (eps))

## %!test
## %! r <- ones (1, 1, 1, 2)
## %! r(1, 1, 1, 2) <- 2
## %! t <- pi/2 * r
## %! c(x, y) <- pol2cart (t, r)
## %! X <- zeros (1, 1, 1, 2)
## %! X(1, 1, 1, 2) <- -2
## %! Y <- zeros (1, 1, 1, 2)
## %! Y(1, 1, 1, 1) <- 1
## %! expect_equal (C[,"x"], X, 2*eps)
## %! expect_equal (C[,"y"], Y, 2*eps)

## %!test
## %! c(t, r, Z) <- meshgrid (c(0, pi/2), c(1, 2), c(0, 1))
## %! c(x, y, z) <- pol2cart (t, r, Z)
## %! X <- zeros(2, 2, 2)
## %! X(:, 1, 1) <- c(1 2)
## %! X(:, 1, 2) <- c(1 2)
## %! Y <- zeros(2, 2, 2)
## %! Y(:, 2, 1) <- c(1 2)
## %! Y(:, 2, 2) <- c(1 2)
## %! expect_equal (C[,"x"], X, eps)
## %! expect_equal (C[,"y"], Y, eps)
## %! expect_equal (z, Z)

 ## Test input validation
 expect_error(pol2cart())
 expect_error(pol2cart(1,2,3,4))
 expect_error(pol2cart(list(1,2,3)), regexp="input must be matrix with 2 or 3 columns")
## %expect_error <matrix input must have 2 or 3 columns> pol2cart (ones (3,3,2))
## %expect_error <matrix input must have 2 or 3 columns> pol2cart (c(1))
## %expect_error <matrix input must have 2 or 3 columns> pol2cart (c(1,2,3,4))
## %expect_error <numeric arrays of the same size> pol2cart ({1,2,3}, c(1,2,3))
## %expect_error <numeric arrays of the same size> pol2cart (c(1,2,3), {1,2,3})
## %expect_error <numeric arrays of the same size> pol2cart (ones (3,3,3), ones (3,2,3))
## %expect_error <numeric arrays of the same size> pol2cart ({1,2,3}, c(1,2,3), c(1,2,3))
## %expect_error <numeric arrays of the same size> pol2cart (c(1,2,3), {1,2,3}, c(1,2,3))
## %expect_error <numeric arrays of the same size> pol2cart (c(1,2,3), c(1,2,3), {1,2,3})
## %expect_error <numeric arrays of the same size> pol2cart (ones (3,3,3), 1, ones (3,2,3))
## %expect_error <numeric arrays of the same size> pol2cart (ones (3,3,3), ones (3,2,3), 1)
})
