htmlbld = $(shell perl ./findsrc.pl bld)
texbld  = $(shell perl ./findsrc.pl bldlang)
src = $(shell perl ./findsrc.pl src)
out = $(shell perl ./findsrc.pl out)

all:	$(htmlbld) topindex.owl

install-ingrid:	all $(texbld)
	echo need $(out) $(texbld) topindex.owl

install-apache:	all
	echo need $(out) topindex.owl

%.html.en:	%.xhtml.en tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" > $@

%/index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

tabs.xml:	tabs.nt
		rapper -i ntriples -o rdfxml-abbrev tabs.nt > tabs.xml

tabs.nt:	doccache/owlimMaxRepository.nt
		rdfcache -cache=doccache -construct=tabconstruct.serql -constructoutput=./tabs.nt file:///`pwd`/ingridregistry.owl

doccache/owlimMaxRepository.nt:	ingridregistry.owl filelist.owl
		rm -r doccache; rdfcache -cache=doccache file:///`pwd`/ingridregistry.owl file:///`pwd`/filelist.owl

filelist.owl:	$(src) sperl.pl
	perl sperl.pl $(src) > $@

topindex.owl:	$(out) sperl.pl
	perl sperl.pl $(out) > $@
