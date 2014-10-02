BUILD_DIR ?= .
htmlbld = $(shell perl ./findsrc.pl bld)
texbld  = $(shell perl ./findsrc.pl bldlang)
src = $(shell perl ./findsrc.pl src)
out = $(shell perl ./findsrc.pl out)
png = $(shell find . -name '*png')
jpg = $(shell find . -name '*jpg')
gif = $(shell find . -name '*gif')
css = $(shell find . -name '*css')
imgs = $(png) $(gif) $(jpg)
maproom = http://iridl.ldeo.columbia.edu/maproom/ 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=es' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=fr' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=id' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=ru' 
all:	$(htmlbld) topindex.owl .gitignore

install-ingrid:	all $(texbld) $(imgs) $(css)
	echo installing ingrid-style to $(BUILD_DIR)
	tar cf - $(out) $(texbld) $(imgs) $(css) topindex.owl | tar xvf - -C $(BUILD_DIR)/html

install-apache:	all $(imgs) $(css)
	echo installing apache-style to $(BUILD_DIR)
	tar cf - $(out) $(imgs) $(css) topindex.owl | tar xvf - -C $(BUILD_DIR)/html


%.html.en:	%.xhtml.en tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' - > $@

%.html.es:	%.xhtml.es tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' - > $@

%.html.fr:	%.xhtml.fr tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' - > $@

%.html.ru:	%.xhtml.ru tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' - > $@

%.html:	%.xhtml tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' - > $@

%/index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

tabs.xml:	tabs.nt
		rapper -i ntriples -o rdfxml-abbrev tabs.nt > tabs.xml

tabs.nt:	doccache/owlimMaxRepository.nt
		rdfcache -cache=doccache -construct=tabconstruct.serql -constructoutput=./tabs.nt file:///`pwd`/ingridregistry.owl

doccache/owlimMaxRepository.nt:	ingridregistry.owl filelist.owl
		rm -rf doccache; rdfcache -cache=doccache file:///`pwd`/ingridregistry.owl file:///`pwd`/filelist.owl

filelist.owl:	$(src) sperl.pl Makefile
	perl sperl.pl $(src) $(maproom) > $@

topindex.owl:	$(out) sperl.pl
	perl sperl.pl $(out) > $@

.gitignore: topindex.owl findsrc.pl
	perl ./findsrc.pl bld | sed 's/^.\///' > $@
	echo 'doccache/' >> $@
	echo 'filelist.owl' >> $@
	echo 'tabs.nt' >> $@
	echo 'tabs.xml' >> $@
	echo 'topindex.owl' >> $@
	echo '.gitignore' >> $@
