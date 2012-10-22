jarSHELL=bash

JAVAC_FLAGS=
JPP_FLAGS=
JAR_FLAGS=
DEBUG=0
PREFIX=/usr
GAMEDIR=/bin

JAVAC=javac7
DEFUALT_JAVAC=javac
JAR=jar7
DEFUALT_JAR=jar
CAT=cat
RM=rm
RM_R=$(RM) -r
UNLINK=unlink
INSTALL=install
INSTALL_M755=$(INSTALL) -m 755
MKDIR=mkdir
MKDIR_P=mkdir -p
JPP=jpp
HASH=hash
JAVAC_COLOUR=colourpipe.javac
FIND=find
GREP=grep
MV=mv
SED=sed


all: jpp debug javac jar


jpp:
	if [ ! -d "bin" ]; then  $(MKDIR) "bin"  ; fi
	$(JPP) -s "./src" -o "./bin" -DDEBUG=$(DEBUG) $(JPP_FLAGS)             \
	    $$($(FIND) "./src" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$')


debug: jpp
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


javac: jpp debug
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
	 _jar7 cfm "maze-game.jar" "./META-INF/MANIFEST.MF" $(JAR_FLAGS) -C "./bin"  \
	       $$($(FIND) "./bin" | $(GREP) -v '/\.class$$' | $(GREP) '\.class$$' |  \
	          $(SED) -e s/'^.\/bin'//);					     \
	)


install:
	$(MKDIR_P) "$(DESTDIR)$(PREFIX)$(GAMEDIR)"
	$(INSTALL_M755) "maze-game"     "$(DESTDIR)$(PREFIX)$(GAMEDIR)"
	$(INSTALL_M755) "maze-game.jar" "$(DESTDIR)$(PREFIX)$(GAMEDIR)"


uninstall:
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(GAMEDIR)/maze-game"
	$(UNLINK) "$(DESTDIR)$(PREFIX)$(GAMEDIR)/maze-game.jar"


clean:
	if [ -d "bin" ];           then  $(RM_R) "bin"        ; fi
	if [ -f "maze-game.jar" ]; then  $(RM)   "maze-game"  ; fi


.PHONY: all clean
