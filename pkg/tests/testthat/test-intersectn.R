test_that("intersectn can run on overlapping triangles", {
  ## Make star of David from isosceles triangles of length 3
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- -ps2[,2]

  expect_equal(feasible.point(convhulln(ps1, output.options=TRUE),
                              convhulln(ps2, output.options=TRUE)),
               c(0, 0))
  is <-  intersectn(ps1, ps2)
  isa <-  intersectn(ps1, ps2, autoscale=TRUE)
  ## Intersecting area is same as 6 isosceles triangles of length 1, which have 
  ## area sqrt(3)/4
  ## 
  expect_equal(is$ch$vol, sqrt(3)/4*6)
  expect_equal(isa$ch$vol, sqrt(3)/4*6)

  ## Another overlapping example
  ps2 <- ps1
  ps2[,2] <- ps2[,2]+2
  is <-  intersectn(ps1, ps2)

  ## Now make one element of feasible point negative
  ps3 <- ps1
  ps4 <- ps1
  ps4[,2] <- -ps4[,2]
  ps3[,2] <- ps3[,2] - 10
  ps4[,2] <- ps4[,2] - 10

  expect_equal(feasible.point(convhulln(ps3, output.options=TRUE),
                              convhulln(ps4, output.options=TRUE)),
               c(0, -10))
  expect_equal(intersectn(ps3, ps4)$ch$vol, sqrt(3)/4*6)
})

test_that("intersectn gives zero volume on non-overlapping triangles", {
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- ps2[,2] + 3
  
  expect_equal(feasible.point(convhulln(ps1, "n"), convhulln(ps2, "n")), NA)
  is <-  intersectn(ps1, ps2)
  expect_equal(is$ch$vol, 0)
  
})


test_that("intersectn gives zero volume on non-overlapping triangles", {
  ps1 <- rbind(c(0,   sqrt(3)),
               c(3/2, -sqrt(3)/2),
               c(-3/2, -sqrt(3)/2))
  ps2 <- ps1
  ps2[,2] <- ps2[,2] + 3
  
  expect_equal(feasible.point(convhulln(ps1, "n"), convhulln(ps2, "n")), NA)
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
  expect_equal(feasible.point(convhulln(ps1, "n"), convhulln(ps2, "n")), NA)
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

test_that("intersectn can run on  tetrahedra with a common point", {
  ps1 <- rbind(c(-0.4015654, -0.1084358, -0.3727391),
               c( 0.2384763,  0.3896078, -0.4447473),
               c( 0.5000000, -0.5000000, -0.5000000),
               c(-0.5000000, -0.5000000, -0.5000000))
  ps2 <- rbind(c(-0.1392469,  0.03303547, -0.2436112),
               c( 0.3434195, -0.20338201, -0.4638141),
               c(-0.5000000,  0.50000000, -0.5000000),
               c(-0.5000000, -0.50000000, -0.5000000))
  is <-  intersectn(ps1, ps2)
})

test_that("intersectn can compute the volume of overlapping delaunay triangulations of boxes", {
  ## Volume of overlap should be 1/8
  ps1 <- rbox(2, B=0.5, C=0.5)
  ps2 <- rbox(2, B=0.5, C=0.5) + 0.5
  dt1 <- delaunayn(ps1)
  dt2 <- delaunayn(ps2)

  vol <- 0
  for (i in 1:nrow(dt1)) {
    for (j in 1:nrow(dt2)) {
      is <- intersectn(ps1[dt1[i,],], ps2[dt2[j,],])
      vol <- vol + is$ch$vol
    }
  }
  expect_equal(vol, 0.125, tol=0.0001)
})

test_that("intersectn can deal with some input that caused errors before fixing Issue #34", {
  ## Issue 34: https://github.com/davidcsterratt/geometry/issues/34
  ps1 <- rbind(
    c(500.9656357388012111187, 843268.9656357388012111, 5.5),
    c(658.9656357388012111187, 843109.9656357388012111, 10.0),
    c(576.9656357388012111187, 843174.9656357388012111,  2.0),
    c(795.9656357388012111187, 843235.9656357388012111, 20.0))
  ps2 <- rbind(
    c(707.9656400000000076034, 843153.9656399999512359, 12.000000000000000000000),
    c(645.6795799999999871943, 843166.4228499999735504, 10.200630000000000308091),
    c(631.6632399999999734064, 843182.9680800000205636,  8.772800000000000153477),
    c(707.9656400000000076034, 843153.9656399999512359, 12.000000000000000000000),
    c(608.9447900000000117871, 843172.7368899999419227,  7.772330000000000183036),
    c(607.9656400000000076034, 843173.9656399999512359,  7.669999999999999928946))
  ## Before Issue #34 was fixed this threw an error:
  ##   Received error code 2 from qhull. Qhull error:
  ##     qhull precision warning: 
  ##     The initial hull is narrow (cosine of min. angle is 1.0000000000000002).
  ## expect_error(intersectn(ps1, ps2, tol=1E-4, return.chs=FALSE, options="Tv"), ".*The initial hull is narrow.*")
  
  ## This threw an error in Rev aab45b7311b6
  out <- intersectn(ps1, ps2, tol=1E-4, return.chs=FALSE)
})

test_that("intersectn works on rotated boxes", {
  rot <- function(theta) {return(rbind(c(cos(theta), sin(theta)), c(-sin(theta), cos(theta))))}
  ## Area of octogan created by two squares at 45 deg to each other
  sq <- rbox(C=1, D=2, n=0)
  expect_equal(intersectn(sq%*%rot(pi/4), sq)$ch$vol, 8*(sqrt(2) - 1))
  
  rot4 <- function(theta) {return(rbind(c(cos(theta), sin(theta), 0, 0), c(-sin(theta), cos(theta), 0, 0), c(0, 0, 1, 0), c(0, 0, 0 ,1)))}
  ## Area of hyperoctoid created by two hypercubes at 45 deg to each other
  hc <- rbox(C=1, D=4, n=0)
  expect_equal(intersectn(hc%*%rot4(pi/4), hc)$ch$vol, 4*8*(sqrt(2) - 1))
})

test_that("intersectn works in 4D", {
    load(file.path(system.file(package="geometry"), "extdata", "intersectn4D.RData"))
  chi <- convhulln(seti, output.options=TRUE)
  chj <- convhulln(setj, output.options=TRUE)
  chij <- intersectn(seti, setj)
  chji <- intersectn(setj, seti)
  expect_equal(chij$ch$vol, chji$ch$vol)
  expect_true(chi$vol >= chij$ch$vol)
  expect_equal(chj$vol, chij$ch$vol)
})

test_that("no regression on issue 35", {
  ## This gave an error in version 0.4.1
  ## See https://github.com/davidcsterratt/geometry/issues/35
  load(file.path(system.file(package="geometry"), "extdata", "issue35-intersectn.RData"))

  ch <- intersectn(seti, setj)
  expect_true(ch$ch$vol > 0)
  cha <- intersectn(seti, setj, autoscale=TRUE)
  expect_true(cha$ch$vol > 0)
  expect_equal(ch$ch$vol, cha$ch$vol)
})

test_that("no regression on issue 35", {
  ## This is an example that requires various combinations of flags to
  ## be provided to lpSolve::lp
  ##
  ## Also testing a scaled version, which was easier to fixed with the
  ## set of flags used originally.
  ## https://github.com/davidcsterratt/geometry/issues/35
  load(file.path(system.file(package="geometry"), "extdata", "error_15_620.RData"))
  ch <- intersectn(p1, p1)
  expect_true(ch$ch$vol > 0)
  cha <- intersectn(p1, p1, autoscale=TRUE)
  expect_true(cha$ch$vol > 0)
  expect_equal(ch$ch$vol, cha$ch$vol)
  
  zfac <- 10
  p1[,3] <- p1[,3]*zfac
  p2[,3] <- p2[,3]*zfac
  ch <- intersectn(p1, p1)
  expect_true(ch$ch$vol > 0)
  cha <- intersectn(p1, p1, autoscale=TRUE)
  expect_true(cha$ch$vol > 0)
  expect_equal(ch$ch$vol, cha$ch$vol)
})

test_that("intersectn doesn't crash on some input", {
  ## This is an example causes a crash if flag SCALE_GEOMETRIC (4) is
  ## given to lpSolve::lp in feasible.point()
  load(file.path(system.file(package="geometry"), "extdata", "overlap260-5034.RData"))
  ch <- intersectn(p1, p2)
  cha <- intersectn(p1, p2, autoscale=TRUE)
  expect_equal(ch$ch$vol, cha$ch$vol)
})

test_that("intersectn doesn't crash on input that causes a crash with scale=7 on some processors", {
  ## This is an example causes a crash on some processors if flag SCALE_CURTISREID (7) is
  ## given to lpSolve::lp in feasible.point()
  load(file.path(system.file(package="geometry"), "extdata", "save-overlap32-176.RData"))
  intersectn(p1, p2, tol=1E-3)

  load(file.path(system.file(package="geometry"), "extdata", "save-overlap68-557.RData"))
  intersectn(p1, p2, tol=1E-3)
})

test_that("intersectn doesn't crash on input that causes a crash with EQUILIBRIATE=1 on some processors", {
  ## This is an example causes a crash on some processors if flag
  ## EQUILIBRIATE is given to lpSolve::lp in feasible.point()
  load(file.path(system.file(package="geometry"), "extdata", "save-overlap149-9428.RData"))
  intersectn(p1, p2, tol=1E-3)
})
