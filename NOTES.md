# To install using devtools

```
roxygen2::roxygenise("..")
devtools::install(".", build_vignettes=TRUE)
```
The `build_vignettes` argument is needed because the Qhull docs now
have to be installed in inst/doc using the .install_extras file in the
vignettes directory.

# To do a reverse dependency check

```
revdepcheck::revdep_check("geometry/pkg", num_workers=6)
```

# To spell check
```
devtools::spell_check("pkg")
```
Update any words to ignore in `pkg/inst/WORDLIST`.

# To update links in qhull docs

The QHull html docs are copied from the Qhull source tree
(`qhull/docs/html`) to `pkg/inst/doc/html`. To satisfy the R checks,
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
