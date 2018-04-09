# To do spell check
```
devtools::spell_check("pkg/", dict="en_GB", ignore=read.table(".spell_ignore", stringsAsFactors=FALSE)$V1)
```

# To make R CMD check igore these spellings (experimental)

See http://dirk.eddelbuettel.com/blog/2017/08/10/
```
ignore <- read.table(".spell_ignore", stringsAsFactors=FALSE)$V1
readr::write_rds(ignore, "pkg/.aspell/geometry.rds")

```
