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
