all:	index.html.en dochelp/index.html.en
index.html.en:	index.xhtml.en tabs.xml tab.xslt
	saxon_transform index.xhtml.en tab.xslt topdir="`pwd`" > index.html.en
dochelp/index.html.en:	dochelp/index.xhtml.en tabs.xml tab.xslt
	saxon_transform dochelp/index.xhtml.en tab.xslt topdir="`pwd`" > dochelp/index.html.en

tabs.xml:	tabs.nt
		rapper -i ntriples -o rdfxml-abbrev tabs.nt > tabs.xml

tabs.nt:	doccache/owlimMaxRepository.nt
		rdfcache -cache=doccache -construct=tabconstruct.serql -constructoutput=./tabs.nt file:///`pwd`/ingridregistry.owl

doccache/owlimMaxRepository.nt:	ingridregistry.owl index.xhtml.en dochelp/index.xhtml.en
		rm -r doccache; rdfcache -cache=doccache file:///`pwd`/ingridregistry.owl
