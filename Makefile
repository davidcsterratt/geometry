GEOMETRY_VERSION=$(shell grep Version pkg/DESCRIPTION | perl -p -e "s/Version: //;")
GEOMETRY_SVN_REVISION=$(shell svn info -R | grep "Revision:" | perl -p -e 's/Revision: //;' | sort -n -r | head -1)
GEOMETRY_SVN_REVISION1=$(shell echo $(GEOMETRY_SVN_REVISION) + 1 | bc) 
PACKAGE=geometry_$(GEOMETRY_VERSION).tar.gz

roxygen:
	rm -f pkg/man/*
	echo "if (!library(roxygen2, logical.return=TRUE)) {install.packages(\"roxygen2\", repos=\"http://star-www.st-andrews.ac.uk/cran/\"); library(roxygen2) } ; roxygenize(\"pkg\")" |	R --no-restore --slave

package: roxygen
	rm -f pkg/R/*~
	R CMD build pkg

install: package
	R CMD INSTALL --latex $(PACKAGE) 

doc: roxygen
	rm -f geometry.pdf
	R CMD Rd2dvi --pdf --output=geometry.pdf pkg 

check:
	R CMD check $(PACKAGE)
	@ if [ $$(/bin/ls -1 pkg/inst/doc/*htm 2>/dev/null | wc -l) -gt 0 ] ; then echo "ERROR: .htm files in pkg/inst/doc. See Makefile for suggestion of how to fix" ; fi	
	@ if [ $$(/bin/ls -1 pkg/inst/doc/html/*htm 2>/dev/null | wc -l) -gt 0 ]; then echo "ERROR: .htm files in pkg/inst/doc. See Makefile for suggestion of how to fix" ; fi 

revision:
	@echo $(GEOMETRY_SVN_REVISION)
	@echo $(GEOMETRY_SVN_REVISION1)

## qhull doc files need to have html suffixes and to have html 
## cd inst/doc
## for f in  *.htm ; do svn move $f ${f}l ; done
## perl -p -i -e 's/\.htm([#\"])/.html\1/g; ' *.html
## cd html
## for f in  *.htm ; do svn move $f ${f}l ; done
## perl -p -i -e 's/\.htm([#\"])/.html\1/g; ' *.html

## Generate test results like this:
## R --vanilla < pkg/tests/delaunayn.R > pkg/tests/delaunayn.Rout.save

