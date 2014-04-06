htmlbld = $(shell perl ./findsrc.pl bld)
src = $(shell perl ./findsrc.pl src)

all:	$(htmlbld)

%.html.en:	%.xhtml.en tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" > $@

tabs.xml:	tabs.nt
		rapper -i ntriples -o rdfxml-abbrev tabs.nt > tabs.xml

tabs.nt:	doccache/owlimMaxRepository.nt
		rdfcache -cache=doccache -construct=tabconstruct.serql -constructoutput=./tabs.nt file:///`pwd`/ingridregistry.owl

doccache/owlimMaxRepository.nt:	ingridregistry.owl filelist.owl
		rm -r doccache; rdfcache -cache=doccache file:///`pwd`/ingridregistry.owl file:///`pwd`/filelist.owl

filelist.owl:	$(src)
	perl sperl.pl $(src) > $@
