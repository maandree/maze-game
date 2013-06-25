SHELL=bash

PROGRAM=maze-game
JAVAC_FLAGS=
JAR_FLAGS=
DEBUG=0
PREFIX=/usr
GAMEDIR=/bin
DATADIR=/share
BOOK=$(PROGRAM)
BOOKDIR=info/

JAVAC=javac7
DEFUALT_JAVAC=javac
JAR=jar7
DEFUALT_JAR=jar
CAT=cat
CP=cp
RM=rm
RM_R=$(RM) -r
UNLINK=unlink
INSTALL=install
INSTALL_M755=$(INSTALL) -m 755
INSTALL_M644=$(INSTALL) -m 644
MKDIR=mkdir
MKDIR_P=mkdir -p
HASH=hash
JAVAC_COLOUR=colourpipe.javac
FIND=find
GREP=grep
MV=mv
SED=sed


all: debug javac jar info


info: $(BOOK).info.gz
%.info: $(BOOKDIR)%.texinfo
	$(MAKEINFO) "$<"
%.info.gz: %.info
	gzip -9c < "$<" > "$@"


pdf: $(BOOK).pdf
%.pdf: $(BOOKDIR)%.texinfo
	texi2pdf "$<"

pdf.gz: $(BOOK).pdf.gz
%.pdf.gz: %.pdf
	gzip -9c < "$<" > "$@"

pdf.xz: $(BOOK).pdf.xz
%.pdf.xz: %.pdf
	xz -e9 < "$<" > "$@"


dvi: $(BOOK).dvi
%.dvi: $(BOOKDIR)%.texinfo
	$(TEXI2DVI) "$<"

dvi.gz: $(BOOK).dvi.gz
%.dvi.gz: %.dvi
	gzip -9c < "$<" > "$@"

dvi.xz: $(BOOK).dvi.xz
%.dvi.xz: %.dvi
	xz -e9 < "$<" > "$@"


cp2bin:
	if [ ! -d "./bin" ]; then  \
	    $(MKDIR) "./bin";	   \
	fi
	$(FIND) "./src" |					       \
	while read file; do					       \
	    out=$$($(SED) -e s/'\.\/src\/'/'\.\/bin\/'/ <<<$${file});  \
	    if [ -d "$$file" ]; then				       \
	        if [ ! -d "$$out" ]; then			       \
	            $(MKDIR) "$$out";				       \
	        fi						       \
	    else						       \
	        $(CP) "$$file" "$$out";				       \
	    fi							       \
	done


debug: cp2bin
	(if (( $(DEBUG) < 1 )); then								\
	     for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	         $(MV) "$$file" "$${file}~";							\
	         $(SED) -e s/'\/\*debug\*\/'/'\/\/\*debug\*\/'/g < "$${file}~" > "$$file";	\
	     done										\
	 elif (( $(DEBUG) > 1 )); then								\
	     for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	         i=1;										\
	         while (( $$i < $(DEBUG) )); do							\
	             $(MV) "$$file" "$${file}~";						\
	             $(SED) -e s/'\/\/\*debug\*\/'/'\/\*debug\*\/'/g < "$${file}~" > "$$file";	\
	             i=$$(( $$i + 1 ));								\
	         done										\
	     done										\
	 fi											\
	)


javac: debug
	(function _jc7								    \
	 {   $(HASH) $(JAVAC) 2>/dev/null >/dev/null;				    \
	     if [ "$$?" = 0 ]; then						    \
	         $(JAVAC) "$$@";						    \
	     else								    \
	         $(DEFUALT_JAVAC) "$$@";					    \
	     fi;								    \
	 };									    \
	 _jc7 $(JAVAC_FLAGS) -cp "./bin" -d "./bin" -s "./bin"			    \
	      $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$') |&  \
	 (   rc=$$?;								    \
	     $(HASH) $(JAVAC_COLOUR) 2>/dev/null >/dev/null;			    \
	     if [ "$$?" = 0 ]; then						    \
	         $(JAVAC_COLOUR);						    \
	     else								    \
	         $(CAT);							    \
	     fi;								    \
	     [ "$$rc" = "0" ] || false;						    \
	))


jar: javac
	(function _jar7								     \
	 {   $(HASH) $(JAR) 2>/dev/null >/dev/null;				     \
	     if [ "$$?" = 0 ]; then						     \
	         $(JAR) "$$@";							     \
	     else								     \
	         $(DEFUALT_JAR) "$$@";						     \
	     fi;								     \
	 };									     \
	 _jar7 cfm "$(PROGRAM).jar" "./META-INF/MANIFEST.MF" $(JAR_FLAGS) -C "./bin"  \
	       $$($(FIND) "./bin" | $(GREP) -v '/\.class$$' | $(GREP) '\.class$$' |  \
	          $(SED) -e s/'^.\/bin'//);					     \
	)


install:
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(GAMEDIR)"
	$(INSTALL_M755) "$(PROGRAM)"     "$(DESTDIR)$(PREFIX)$(GAMEDIR)"
	$(INSTALL_M755) "$(PROGRAM).jar" "$(DESTDIR)$(PREFIX)$(GAMEDIR)"
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(DATADIR)/licenses/$(PROGRAM)"
	$(INSTALL_M644) "COPYING" "$(DESTDIR)$(PREFIX)$(DATADIR)/licenses/$(PROGRAM)"
	$(INSTALL_M644) "LICENSE" "$(DESTDIR)$(PREFIX)$(DATADIR)/licenses/$(PROGRAM)"
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(DATADIR)/info"
	$(INSTALL_M644) "$(BOOK).info.gz" "$(DESTDIR)$(PREFIX)$(DATADIR)/info"


uninstall:
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(GAMEDIR)/$(PROGRAM)"
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(GAMEDIR)/$(PROGRAM).jar"
	$(RM_R) "$(DESTDIR)$(PREFIX)$(DATA)/licenses/$(PROGRAM)"
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(DATA)/info/$(BOOK).info.gz"


clean:
	if [ -d "bin" ];            then  $(RM_R) "bin"             ; fi
	if [ -f "$(PROGRAM).jar" ]; then  $(RM)   "$(PROGRAM).jar"  ; fi
	-rm -r *.{t2d,aux,{cp,pg,op,vr}{,s},fn,ky,log,toc,tp,bak,info,pdf,ps,dvi,gz} 2>/dev/null


.PHONY: all cp2bin clean
