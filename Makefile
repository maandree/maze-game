SHELL=bash

PREFIX=/usr/games
BIN=/bin
DATA=/share
BINJAR=$(DATA)/misc
LICENSES=$(DATA)/licenses
PKGNAME=maze-game
COMMAND=maze-game

PROGRAM=maze-game
JAVAC_FLAGS=
JAR_FLAGS=
DEBUG=0
BOOK=maze-game
BOOKDIR=info/

JAVAC=javac
JAR=jar
CAT=cat
CP=cp
RM=rm
RM_R=$(RM) -r --
UNLINK=$(RM) --
INSTALL=install
INSTALL_M755=$(INSTALL) -m 755
INSTALL_M644=$(INSTALL) -m 644
MKDIR=mkdir
MKDIR_P=mkdir -p
JAVAC_COLOUR=colourpipe.javac
FIND=find
GREP=grep
MV=mv
SED=sed


all: code info

code: debug javac jar launcher


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
	if (( $(DEBUG) < 1 )); then								\
	    for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	        $(MV) "$$file" "$${file}~";							\
	        $(SED) -e s/'\/\*debug\*\/'/'\/\/\*debug\*\/'/g < "$${file}~" > "$$file";	\
	    done										\
	elif (( $(DEBUG) > 1 )); then								\
	    for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	        i=1;										\
	        while (( $$i < $(DEBUG) )); do							\
	            $(MV) "$$file" "$${file}~";							\
	            $(SED) -e s/'\/\/\*debug\*\/'/'\/\*debug\*\/'/g < "$${file}~" > "$$file";	\
	            i=$$(( $$i + 1 ));								\
	        done										\
	    done										\
	fi


javac: debug
	($(JAVAC) $(JAVAC_FLAGS) -cp "./bin" -d "./bin" -s "./bin"		    \
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
	$(JAR) cfm "$(PROGRAM).jar" "./META-INF/MANIFEST.MF" $(JAR_FLAGS) -C "./bin"  \
	      $$($(FIND) "./bin" | $(GREP) -v '/\.class$$' | $(GREP) '\.class$$' |    \
	         $(SED) -e s/'^.\/bin'//)					      \

launcher: $(PROGRAM).install
$(PROGRAM).install: $(PROGRAM)
	cp "$<" "$@"
	sed -i 's:"$$0".jar:"$(PREFIX)$(BINJAR)/$(COMMAND).jar":g' "$@"


install: install-cmd install-license install-info

install-cmd:
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(BIN)"
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(BINJAR)"
	$(INSTALL_M755) "$(PROGRAM).install" "$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)"
	$(INSTALL_M755) "$(PROGRAM).jar" "$(DESTDIR)$(PREFIX)$(BINJAR)/$(COMMAND).jar"

install-license:
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"
	$(INSTALL_M644) "COPYING" "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"
	$(INSTALL_M644) "LICENSE" "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"

install-info:
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(DATA)/info"
	$(INSTALL_M644) "$(BOOK).info.gz" "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"


uninstall:
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)"
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(BINJAR)/$(COMMAND).jar"
	$(RM_R) "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"


clean:
	-rm -r *.{t2d,aux,{cp,pg,op,vr}{,s},fn,ky,log,toc,tp,bak,info,pdf,ps,dvi,gz,install} bin "$(PROGRAM).jar" 2>/dev/null


.PHONY: all cp2bin clean
