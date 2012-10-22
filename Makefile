SHELL=bash

JAVAC_FLAGS=
JPP_FLAGS=
DEBUG=0

JAVAC=javac7
DEFUALT_JAVAC=javac
CAT=cat
RM=rm
MKDIR=mkdir
JPP=jpp
HASH=hash
JAVAC_COLOUR=colourpipe.javac
FIND=find
GREP=grep
MV=mv
SED=sed


all: jpp debug javac

jpp:
	if [ ! -d "bin" ]; then  $(MKDIR) "bin"  ; fi
	$(JPP) -s "./src" -o "./bin" -DDEBUG=$(DEBUG) $(JPP_FLAGS) $$($(FIND) "./src" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$')

debug: jpp
	(if (( $(DEBUG) < 1 )); then								\
	     for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	         $(MV) "$$FILE" "$$FILE~";							\
	         $(SED) -e s/'\/\*debug\*\/'/'\/\/\*debug\*\/'/g < "$$FILE~" > "$$FILE";	\
	     done										\
	 elif (( $(DEBUG) > 1 )); then								\
	     for file in $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$'); do	\
	         i=1										\
	         while (( $$i < $(DEBUG) )); do							\
	             $(MV) "$$FILE" "$$FILE~";							\
	             $(SED) -e s/'\/\/\*debug\*\/'/'\/\*debug\*\/'/g < "$$FILE~" > "$$FILE";	\
	             i=$$(( $$i + 1 ))								\
	         done										\
	     done										\
	 fi											\
	)

javac: jpp debug
	(function _jc7														   \
	 {   $(HASH) $(JAVAC) 2>/dev/null >/dev/null;										   \
	     if [ "$$?" = 0 ]; then												   \
	         $(JAVAC) "$$@";												   \
	     else														   \
	         $(DEFUALT_JAVAC) "$$@";											   \
	     fi;														   \
	 };															   \
	 _jc7 $(JAVAC_FLAGS) -cp "./bin" -d "./bin" -s "./bin" $$($(FIND) "./bin" | $(GREP) -v '/\.java$$' | $(GREP) '\.java$$');  \
	 (   $(HASH) $(JAVAC_COLOUR) 2>/dev/null >/dev/null;									   \
	     if [ "$$?" = 0 ]; then												   \
	         $(JAVAC_COLOUR);												   \
	     else														   \
	         $(CAT);													   \
	     fi															   \
	))


clean:
	if [ -d "bin" ]; then  $(RM) -r "bin"  ; fi


.PHONY: all clean
