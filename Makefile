GEOMETRY_VERSION=$(shell grep Version pkg/DESCRIPTION | perl -p -e "s/Version: //;")
GEOMETRY_SVN_REVISION=$(shell svn info -R | grep "Revision:" | perl -p -e 's/Revision: //;' | sort -n -r | head -1)
GEOMETRY_SVN_REVISION1=$(shell echo $(GEOMETRY_SVN_REVISION) + 1 | bc) 
PACKAGE=geometry_$(GEOMETRY_VERSION).tar.gz

roxygen:
	echo "library(roxygen2) ; roxygenize(\"pkg\")" |	R --no-restore --slave

package: roxygen
	rm -f pkg/R/*~
	R CMD build pkg

install: package
	R CMD INSTALL --latex $(PACKAGE) 

doc: roxygen
	rm -f geometry.pdf
	R CMD Rd2dvi --pdf --output=geometry.pdf pkg 

check:
	R CMD check pkg

revision:
	@echo $(GEOMETRY_SVN_REVISION)
	@echo $(GEOMETRY_SVN_REVISION1)
