test_that("intersectn can run on overlapping triangles", {
  ## Make star of David from isosceles triangles of length 3
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- -ps2[,2]

  is <-  intersectn(ps1, ps2)
  ## Intersecting area is same as 6 isosceles triangles of length 1, which have 
  ## area sqrt(3)/4
  ## 
  expect_equal(is$ch$vol, sqrt(3)/4*6)

  ## Another overlapping example
  ps2 <- ps1
  ps2[,2] <- ps2[,2]+2
  is <-  intersectn(ps1, ps2)  
})

test_that("intersectn gives zero volume on non-overlapping triangles", {
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- ps2[,2] + 3
  
  expect_equal(feasible.point(ps1, ps2), NA)
  is <-  intersectn(ps1, ps2)
  expect_equal(is$ch$vol, 0)
  
})


test_that("intersectn gives zero volume on non-overlapping triangles", {
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- ps2[,2] + 3
  
  expect_equal(feasible.point(ps1, ps2), NA)
  is <-  intersectn(ps1, ps2)
  expect_equal(is$ch$vol, 0)
  
})

test_that("feasible.point works on a 3D example", {
  ## These tetrahedra do not overlap
  ps1 <- rbind(c( 0.5000000, -0.5000000,  0.5000000),
               c(-0.1018942,  0.1848312, -0.1260239),
               c( 0.5000000, -0.5000000, -0.5000000),
               c(-0.5000000, -0.5000000, -0.5000000))
  ps2 <- rbind(c( 0.7581575,  0.6352585,  0.32876),
               c( 1.0000000,  0.0000000,  1.00000),
               c( 0.0000000,  0.0000000,  1.00000),
               c( 1.0000000,  0.0000000,  0.00000))
  expect_equal(feasible.point(ps1, ps2), NA)
})

test_that("intersectn can run on overlapping tetrahedra", {
  ## Make star of David from isocelese triangles of length 3
  ps1 <- rbind(c(0,   sqrt(3), 0),
               c(3/2, -sqrt(3)/2, 0),
               c(-3/2, -sqrt(3)/2, 0),
               c(0, 0, 3*sqrt(2/3)))
  ch1 <- convhulln(ps1, "FA")
  expect_equal(ch1$vol, sqrt(2)/12*27)
  ps2 <- ps1

  ## By shifting tetrahedron up by half of its height, we should make
  ## something with 1/8 of the volume
  ps2[,3] <- ps2[,3] + 3/2*sqrt(2/3)
  is <-  intersectn(ps1, ps2)
  expect_equal(is$ch$vol, sqrt(2)/12*27/8)
  
})

## test_that("intersectn can run on  tetrahedra with a common point", {
##   ps1 <- rbind(c(-0.4015654, -0.1084358, -0.3727391),
##                c( 0.2384763,  0.3896078, -0.4447473),
##                c( 0.5000000, -0.5000000, -0.5000000),
##                c(-0.5000000, -0.5000000, -0.5000000))
##   ps2 <- rbind(c(-0.1392469,  0.03303547, -0.2436112),
##                c( 0.3434195, -0.20338201, -0.4638141),
##                c(-0.5000000,  0.50000000, -0.5000000),
##                c(-0.5000000, -0.50000000, -0.5000000))
##   is <-  intersectn(ps1, ps2)
## })

test_that("intersectn can compute the volume of overlapping delaunay triangulations of boxes", {
  ## Volume of overlap should be 1/8
  ps1 <- rbox(2, B=0.5, C=0.5)
  ps2 <- rbox(2, B=0.5, C=0.5) + 0.5
  dt1 <- delaunayn(ps1)
  dt2 <- delaunayn(ps2)

  vol <- 0
  for (i in 1:nrow(dt1)) {
    for (j in 1:nrow(dt2)) {
      is <- suppressMessages(intersectn(ps1[dt1[i,],], ps2[dt2[j,],]))
      vol <- vol + is$ch$vol
    }
  }
  expect_equal(vol, 0.125, tol=0.0001)
})
