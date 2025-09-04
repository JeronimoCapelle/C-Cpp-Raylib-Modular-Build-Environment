#compilers
CPP := g++ -std=c++23 
CC 	:= gcc -std=c23

#flags
ErrorFlags		:= -Wall -Wextra -Werror -Wpedantic -Wpointer-arith -Wcast-align -Wstrict-overflow=5 -Wwrite-strings -Wswitch-enum -Wconversion -Wunreachable-code -Walloc-zero -Wduplicated-branches -Wduplicated-cond -Wformat=2 -Wunused -Wno-missing-braces -Wfloat-equal -Wshadow -Wold-style-cast -Wdouble-promotion -Wcast-qual -Wundef
PerfFlags 	 	:= -mtune=native -Ofast -m64 -DNDEBUG -march=native -fno-signed-zeros -fno-trapping-math #-flto=auto
DebugFlags	 	:= -g3 -Og -ggdb

#build structure
DEBUG_BUILD ?= 0
ifeq($(DEBUG_BUILD),1)
	BUILD_TYPE := debug
	BUILD_FLAGS := $(DebugFlags)
else
	BUILD_TYPE := release
	BUILD_FLAGS := $(PerfFlags)
endif

buildDir := build/$(BUILD_TYPE)

#build directories
objectsDir 	:= $(buildDir)/obj
binDir 		:= $(buildDir)/bin
GCHDir		:= $(buildDir)/GCH

#file directories
srcDir		:= src
IncludeDir	:= inc
libDir 		:= lib

#-------- Project Files --------

#final build name
target 	:= Masterpiece

#header files to compile
headerFiles := $(wildcard $(IncludeDir)/*.hpp $(IncludeDir)/*.h)
gchFiles 	:= $(sort $(foreach file, $(headerFiles), $(GCHDir)/$(strip $(patsubst %.h, %.h.gch, $(patsubst %.hpp, %.hpp.gch,$(notdir $(file)))))))

#cpp files to compile
SrcFiles = $(wildcard $(srcDir)/*.cpp $(srcDir)/*.c)
ObjFiles = $(sort $(foreach file, $(SrcFiles), $(objectsDir)/$(strip $(patsubst %.c, %.o, $(patsubst %.cpp, %.o,$(notdir $(file)))))))

#directory flags
LibFlags	:= #Empty
LibDirFlag 	:= $(addprefix -L, $(realpath $(LibDir))) #Empty
IncDirFlag 	:= $(sort $(addprefix -I, $(realpath $(IncludeDir))))
GCHDirFlag 	 = $(sort $(addprefix -I, $(realpath $(GCHDir))))


#----------------- LIBRARIES ------------------

#----- RAYLIB -----
RaylibDir 			:= Libraries/raylib
RaylibIncDir		:= $(RaylibDir)/$(IncludeDir)
RaylibLibDir 		:= $(RaylibDir)/$(libDir)

RaylibHeaderFiles	:= $(sort $(foreach dir, $(RaylibIncDir), $(wildcard $(dir)/*.h)) $(foreach dir, $(RaylibIncDir), $(wildcard $(dir)/*.hpp)))

RaylibLibFlags 		:= -lraylib -lopengl32 -lgdi32 -lwinmm
RaylibLibDirFlags 	:= $(sort $(addprefix -L, $(realpath $(RaylibLibDir))))
RaylibIncDirFlags 	:= $(sort $(addprefix -I, $(realpath $(RaylibIncDir))))

#----- RaylibCPP -----
RaylibCPPDir 		:= Libraries/raylib-cpp
RaylibCPPIncDir 	:= $(RaylibCPPDir)/$(IncludeDir)
RaylibCPPGCHDir 	:= $(RaylibCPPDir)/$(GCHDir)

RaylibCPPMainFile 	:= $(RaylibCPPGCHDir)/raylib-cpp.hpp.gch
RaylibCPPHeaderFiles:= $(sort $(foreach dir, $(RaylibCPPIncDir), $(wildcard $(dir)/*.h)) $(foreach dir, $(RaylibCPPIncDir), $(wildcard $(dir)/*.hpp)))
RaylibCPPGCHFiles 	:= $(foreach file, $(RaylibCPPHeaderFiles), $(RaylibCPPGCHDir)/$(strip $(patsubst %.h, %.h.gch, $(patsubst %.hpp, %.hpp.gch, $(notdir $(file)))))) 

RaylibCPPIncDirFlags:= $(sort $(addprefix -I, $(realpath $(RaylibCPPIncDir))))
RaylibCPPGCHDirFlags = $(sort $(addprefix -I, $(realpath $(RaylibCPPGCHDir))))
#------------------END LIBRARIES --------------------------


#-------------------- recipes -----------------
all: $(binDir)/$(target).exe

$(MakeDir)/RaylibCPPGCH: 	$(RaylibCPPMainFile)
	mkdir -p $(dir $@)
	touch $@
$(MakeDir)/ProjObj: 		$(ObjFiles)
	mkdir -p $(dir $@)
	touch $@
$(MakeDir)/ProjGCH: 		$(gchFiles)
	mkdir -p $(dir $@)
	touch $@

#---------- generic recipes ----------

$(binDir)/$(target).exe: $(objectsDir)/main.o $(MakeDir)/ProjObj #Project EXE
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "Executable from main.o"
	@echo "compiling $@ from $<"
	@echo "---------------------"
	$(CPP) $< -o $@ $(RaylibLibFlags) $(RaylibLibDirFlags) $(PerfFlags) $(ErrorFlags) $(ExtraErrorFlags) $(GCHDirFlag) $(CPPFlags)

#Project Objects ------------------
$(objectsDir)/%.o: $(srcDir)/%.cpp $(MakeDir)/ProjGCH #Project .CPP
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "Project Objects from Project CPP files"
	@echo "compiling $@ from $<"
	@echo "---------------------"
	$(CPP) -x c++ $< -c -o $@  -Winvalid-pch $(PerfFlags) $(ErrorFlags) $(ExtraErrorFlags) $(RaylibCPPGCHDirFlags) $(GCHDirFlag) $(CPPFlags)

$(objectsDir)/%.o: $(srcDir)/%.c $(MakeDir)/ProjGCH #Project .C
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "Project Objects from Project C files"
	@echo "compiling $@ from $<"
	@echo "---------------------"
	$(CC)  -x c $< -c -o $@ $(PerfFlags) $(ErrorFlags) $(ExtraErrorFlags) $(RaylibCPPGCHDirFlags) $(GCHDirFlag) $(CFlags)

#Project Headers ---------------
$(GCHDir)/%.h.gch: $(IncludeDir)/%.h $(MakeDir)/RaylibCPPGCH #Project .H
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "Project GCH from Project .H files"
	@echo "compiling $@ from $<"
	@echo "-----------------------"
	$(CC) -x c-header $< -c -o $@ $(PerfFlags) $(ErrorFlags) $(ExtraErrorFlags) $(RaylibCPPGCHDirFlags) $(IncDirFlag) $(CFlags)

$(GCHDir)/%.hpp.gch: $(IncludeDir)/%.hpp $(MakeDir)/RaylibCPPGCH #Project .HPP
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "Project GCH from Project .HPP files"
	@echo "compiling $@ from $<"
	@echo "----------------------"
	$(CPP) -x c++-header $< -c -o $@ $(PerfFlags) $(ErrorFlags) $(ExtraErrorFlags) $(RaylibCPPGCHDirFlags) $(IncDirFlag) $(CPPFlags)

#RaylibCPP ---------------
$(RaylibCPPGCHDir)/%.hpp.gch: $(RaylibCPPIncDir)/%.hpp #RaylibCPP .HPP
	mkdir -p $(dir $@)
	@echo "---------------------------------"
	@echo "RaylibCPP GCH from RaylibCPP .HPP files"
	@echo "compiling $@ from $<"
	@echo "---------------------"
	$(CPP) -x c++-header $< -c -o $@ $(PerfFlags) $(ErrorFlags) $(RaylibIncDirFlags) $(RaylibCPPIncDirFlags) $(CPPFlags)


#phony
.PHONY: clean cleanProj cleanRaylibCPP run debug release

run: $(binDir)/$(target).exe
	$(binDir)/$(target).exe
	make cleanProj

clean: cleanProj cleanRaylibCPP
	rm -rf $(MakeDir)

cleanProj:
	rm -rf $(objectsDir) $(binDir) $(GCHDir)
	rm $(MakeDir)/ProjObj $(MakeDir)/ProjGCH
cleanRaylibCPP:
	rm -rf  $(RaylibCPPGCHDir)
	rm $(MakeDir)/RaylibCPPGCH

debug:
	$(MAKE) DEBUG_BUILD=1
release:
	$(MAKE) DEBUG_BUILD=0