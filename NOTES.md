# To install using devtools

```
roxygen2::roxygenise("..")
devtools::install(".", build_vignettes=TRUE)
```
The `build_vignettes` argument is needed because the Qhull docs now
have to be installed in inst/doc using the `.install_extras` file in the
vignettes directory.

# To do a reverse dependency check

## Github actions method

1. Browse to the __Actions__ page on Github and then select __Reverse
   dependency check__. Alternatively go directly to this URL:
   https://github.com/davidcsterratt/geometry/actions/workflows/recheck.yml
2. Click on __Run Workflow__ and wait about an hour for results
3. Once done, click on the top __Reverse dependency check__ row and
   then __Show results__.
4. Examine the __Get results__ section, which presents some summary
   level information of the number of packages with Warning and
   Errors.
5. You can also download the old and new package logs, unzip them into
   to two separate directories, and diff them using
   ```
   diff -ru -x '*.Rout' -x '*manual.log' -x 'Rdlatex.log' newpkg-checklogs-pre newpkg-checklogs-post/  |grep Status
   ```

## Revdepcheck method

Install and use [the revdepcheck
package](https://github.com/r-lib/revdepcheck) as follows:

```
revdepcheck::revdep_check("geometry/pkg", num_workers=6)

```

## CRAN manual method

1. Make sure relevant system packages are install. On Debian/Ubuntu Linux:
   ```
   sudo apt install libgmp-dev cmake libudunits2-dev libgdal-dev libgsl-dev libglpk-dev libmagick++-dev libpoppler-cpp-dev

   ```
2. Build the package using R CMD check.
3. Put the constructed .tar.gz file in a directory on its own
4. Open R in this directory, and run
   ```
   tools::check_packages_in_dir(reverse = list(), dir='revdep-rtools', pfiles='geometry_0.4.8.tar.gz', clean=FALSE)
   ```

# To spell check
```
devtools::spell_check("pkg")
```
Update any words to ignore in `pkg/inst/WORDLIST`.

# To recreate registration skeleton

If changing any arguements to C or C++ functions:
```
tools::package_native_routine_registration_skeleton("geometry/pkg")
```

# To update links in qhull docs

The QHull html docs are copied from the Qhull source tree
(`qhull/html`) to `vignettes/qhull/html`. To satisfy the R checks,
files have to be renamed from `*.htm` to `*.html`, and the links have
to be updated too. In order to do this, once all doc files have been
copied into `pkg/inst/doc/html`, the following bash commands work:

```
for f in *.htm; do mv ${f} ${f}l ; done
for f in *.html; do for g in *.html ; do echo  perl -p -i -e \'s/`basename ${f} .html`\\.htm/${f}/g\;\' $g ; done ; done > commands
. commands
rm commands
```

# To check for protection errors with rchk

1. Install rchk using the automated installation method
https://github.com/kalibera/rchk#automated-installation

2. Build R as described at
   https://github.com/kalibera/rchk#testing-the-installation 

3. Install current geometry and dependencies
```
. /opt/rchk/scripts/config.inc
. /opt/rchk/scripts/cmpconfig.inc
cd ~/trunk
echo 'install.packages(c("geometry", "Rcpp", "lpSolve", "RcppProgress"), repos="http://cloud.r-project.org")' | ./bin/R --slave
```

4. Install github version of geometry and check
```
cd ~
git clone https://github.com/davidcsterratt/geometry
cd trunk
echo 'install.packages("../geometry_0.4.0.tar.gz")' | ./bin/R --slave
/opt/rchk/scripts/check_package.sh
cat packages/lib/geometry/libs/geometry.so.*check
```

5. When a new change to the github version made, recheck:
```
cd ~/geometry
git pull
cd
./trunk/bin/R CMD build geometry/pkg
cd ~/trunk
echo 'install.packages("../geometry_0.4.0.tar.gz")' | ./bin/R --slave
/opt/rchk/scripts/check_package.sh geometry
cat packages/lib/geometry/libs/geometry.so.*check
```
6. After having logged out neceesary to do Step 3 again.
