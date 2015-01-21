BUILD_DIR ?= .
htmlbld = $(shell perl ./findsrc.pl bld)
texbld  = $(shell perl ./findsrc.pl bldlang)
src = $(shell perl ./findsrc.pl src)
out = $(shell perl ./findsrc.pl out)
png = $(shell find -L . -name '*png')
jpg = $(shell find -L . -name '*jpg')
gif = $(shell find -L . -name '*gif')
css = $(shell find -L . -name '*css')
imgs = $(png) $(gif) $(jpg)

#internal maproom
#additional = 
#src = $(shell perl ./findsrc.pl src) maproom/Imports/moremetadata.owl

#external maproom
additional = linkexternalmaproom.owl
maproom = http://iridl.ldeo.columbia.edu/maproom/ 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=es' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=fr' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=id' 'http://iridl.ldeo.columbia.edu/maproom/index.html?Set-Language=ru' 

all:	$(htmlbld) topindex.owl .gitignore

install-ingrid:	all $(texbld) $(imgs) $(css)
	echo installing ingrid-style to $(BUILD_DIR)
	tar cf - $(out) $(texbld) $(imgs) $(css) topindex.owl | tar xvf - -C $(BUILD_DIR)/html

install-apache:	all $(imgs) $(css)
	echo installing apache-style to $(BUILD_DIR)
	tar cf - $(out) $(imgs) $(css) topindex.owl | tar xvf - -C $(BUILD_DIR)/html


%.html.en:	%.xhtml.en tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`" metadata="tabs.xml" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' > $@

%.html.es:	%.xhtml.es tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`"  metadata="tabs.xml" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' > $@

%.html.fr:	%.xhtml.fr tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`"  metadata="tabs.xml" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' > $@

%.html.ru:	%.xhtml.ru tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`"  metadata="tabs.xml" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' > $@

%.html:	%.xhtml tabs.xml tab.xslt
	saxon_transform $< tab.xslt topdir="`pwd`"  metadata="tabs.xml" | sed -e '1 N;s/[\n]* *SYSTEM[^>]*//' > $@

%/index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

index.tex:	findsrc.pl tabs.xml
		perl ./findsrc.pl bldlangindex ./$@ > $@ 

tabs.xml:	tabs.nt
		rapper -i ntriples -o rdfxml-abbrev -f 'xmlns:terms="http://iridl.ldeo.columbia.edu/ontologies/iriterms.owl#"' -f 'xmlns:reg="http://iridl.ldeo.columbia.edu/maproom/maproomregistry.owl#"' -f 'xmlns:map="http://iridl.ldeo.columbia.edu/ontologies/maproom.owl#"' -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f 'xmlns:vocab="http://www.w3.org/1999/xhtml/vocab#"' tabs.nt > tabs.xml

tabs.nt:	doccache/owlimMaxRepository.nt
		rdfcache -cache=doccache -construct=tabconstruct.serql -constructoutput=./tabs.nt file://`pwd`/ingridregistry.owl

doccache/owlimMaxRepository.nt:	ingridregistry.owl filelist.owl
		rm -rf doccache; rdfcache -cache=doccache file://`pwd`/ingridregistry.owl file://`pwd`/filelist.owl

filelist.owl:	$(src) $(additional) sperl.pl Makefile
	perl sperl.pl $(src) $(additional) $(maproom) > $@

topindex.owl:	$(out) sperl.pl
	perl sperl.pl $(out) > $@

# only used in external map room
linkexternalmaproom.owl: 
	echo '<file:///> <http://www.w3.org/1999/xhtml/vocab#section> <http://iridl.ldeo.columbia.edu/maproom/> .' > linkexternalmaproom.nt
	rapper -i ntriples -o rdfxml linkexternalmaproom.nt > linkexternalmaproom.owl
	rm linkexternalmaproom.nt

# this is so that rdfcache can load all the map pages with the proper url.
# it is not in the make because it has to run first before all the variables get set with findsrc.pl and find
maproom: 
	ln -s ../maproom maproom


.gitignore: topindex.owl findsrc.pl
	perl ./findsrc.pl bld | sed 's/^.\///' > $@
	perl ./findsrc.pl bldlang | sed 's/^.\///' >> $@
	echo 'doccache/' >> $@
	echo 'filelist.owl' >> $@
	echo 'tabs.nt' >> $@
	echo 'tabs.xml' >> $@
	echo 'topindex.owl' >> $@
	echo '.gitignore' >> $@
	echo 'maproom' >> $@
	echo 'linkexternalmaproom.owl' >> $@
