# make4java - A Makefile for Java projects
#
# Written in 2014 by Francesco Lattanzio <franz.lattanzio@gmail.com>
#
# To the extent possible under law, the author have dedicated all
# copyright and related and neighboring rights to this software to
# the public domain worldwide. This software is distributed without
# any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication
# along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# To enabled incremental compilation you need the "jdeps" utility
# (available in OpenJDK 1.8). If not found it will revert to full
# compilation every time one or more source files are modified or
# added (and ONLY if modified or added).
#
# NOTE: Only file modification and/or addition is supported, that is,
#       if a (re)source file is removed you have to perform a full
#       compilation ("make clean compile") in order to get rid of the
#       old classes and "filtered" resources.
#
# If you want to use jdeps but don't want to generate 1.8 bytecode,
# just add the JAVAC variable to the "localdefs.mk" file:
#
#   JAVAC := javac -source 1.7 -target 1.7 \
#            -bootclasspath /usr/lib/jvm/java-7-openjdk/jre/lib/rt.jar
#
# Choose appropriate source, target and bootclasspath's values for you
# project.
#
# NOTE: For small projects a full compilation may be faster than an
#       incremental compilation followed by a jdeps run. In such cases
#       you may wish to disable jdeps: just add "HAVE_JDEPS := false"
#       to "localdefs.mk".

-include localdefs.mk

# To change the value of the following variables, add them to
# "localdefs.mk".


#############
# Variables #
#############

# Sample optional feature -- disabled by default
ENABLE_FOO_FEATURE ?= false

# Java tools
JAR ?= jar
JAVA ?= java
JAVAC ?= javac
JAVAH ?= javah
JDEPS ?= jdeps

# Assorted tools -- every UNIX-like OS should have these (and a
# Bourne-like shell)
AWK ?= awk
CAT ?= cat
# CC ?= cc # this variable is automatically set by make
CHMOD ?= chmod
CP ?= cp -f
FGREP ?= fgrep
FIND ?= find
LINK ?= ln -f
MKDIR_P ?= mkdir -p
MV ?= mv
OS ?= uname -o
RM ?= rm -f
SED ?= sed
TAR ?= tar
WHICH ?= which
XARGS ?= xargs

# Native code support -- if defined, the values of the CPPFLAGS and
# CFLAGS variables will be passed to the C compiler to compile the C
# source files into object files, whereas the value of the LDFLAGS
# variable will be used to link those object files into the native
# dynamic library.


#################################
# Project files and directories #
#################################

# The name of the directory inside the built JARs, that will hold all
# the included JARs
resources.jars := jars

# The name of the directory inside the built JARs, that will hold all
# the native libraries
resources.libs := libs


# Component-relative path to Java source files
SOURCES_PATH := src/main/java

# Component-relative path to resource files
RESOURCES_PATH := src/main/resources

# Component-relative path to native C source files
NATIVE_SOURCES_PATH := src/main/native


# The name of a subdirectory of the topmost directory that holds all
# the project's dependencies (JAR files only).
# NOTE: The project's README or INSTALL file should contain a list of
#       all the dependencies required and should also instruct the user
#       to download them into this directory, optionally arranging them
#       into a hierachy of directories.
EXTERNAL_LIBRARIES_DIR := libs


# The name of a subdirectory of the topmost directory that will hold all
# the intermediate files produced by the build process
BUILD_DIR := build

# The name of the file that will hold the list of all the source files
SOURCE_FILES_FULL_LIST := $(BUILD_DIR)/source-files

# The name of the file that will hold the .class to .java dependencies
JAVA_DEPENDENCIES := $(BUILD_DIR)/java-dependencies

# The name of the file that will hold all the -sourcepath options
# for javac
JAVAC_SOURCEPATHS_LIST := $(BUILD_DIR)/javac-sourcepaths

# The name of the file that will hold the list of source files
# to compile
JAVAC_SOURCE_FILES_LIST := $(BUILD_DIR)/javac-source-files


# The name of the file that will hold the list of all the class files --
# and their respective source files -- processed through javah
EXPORTED_CLASSES_LIST := $(BUILD_DIR)/exported-classes

# The name of the file that will hold the list of all the class files
# that were recompiled and thus must be reprocessed through javah
JAVAH_CLASSES_LIST := $(BUILD_DIR)/javah-classes

# The name of the file that will cache javah's include directory
JDK_INCLUDE := $(BUILD_DIR)/jdk-include


# The name of the directory that will hold all the class files compiled
CLASSES_DIR := $(BUILD_DIR)/classes

# The name of the directory that will hold all the resource files ready
# to be stored in the JARs (whether or not filtered)
RESOURCES_DIR := $(BUILD_DIR)/resources

# The name of the file holding the sed script used to filter resource
# files
RESOURCES_FILTER_SCRIPT := $(BUILD_DIR)/sed-script

# The name of the directory that will hold all the JAR files built
JARS_DIR := $(BUILD_DIR)/$(resources.jars)


# The name of the directory that will hold all the object files compiled
# from native C code
OBJECTS_DIR := $(BUILD_DIR)/obj

# The name of the directory that will hold all the include files
# generated by javah
INCLUDE_DIR := $(BUILD_DIR)/include

# The name of the directory that will hold all the native library built
NATIVE_DIR := $(BUILD_DIR)/$(resources.libs)


# The name of the directory that will hold all the files to be put into
# the package files
STAGE_DIR := $(BUILD_DIR)/stage

# The name of the directory that will hold all the packages built
PACKAGE_DIR := packages


####################
# Misc definitions #
####################

# Release version of the package (components have each their own version
# numbers)
release.version := 1.0.3

# External dependencies
LIBRARIES := $(shell test -d $(EXTERNAL_LIBRARIES_DIR) && $(FIND) $(EXTERNAL_LIBRARIES_DIR) -name '*.jar')

# The default target -- change it to whatever you want
package:


ifndef BUILD_PHASE


####################
# Main entry point #
####################


# Locate jdeps and define JDEPS, unless HAVE_JDEPS is defined
ifdef HAVE_JDEPS

ifneq ($(HAVE_JDEPS),true)
JDEPS :=
endif

else # def HAVE_JDEPS

# If JDEPS contains an absolute file name, use it as is, else, if it is
# relative, convert it to an absolute file name looking up in the PATH's
# directories.
# If the file cannot be found or does not exist, JDEPS will contain an
# empty string.
JDEPS := $(firstword $(wildcard $(if $(filter /%,$(JDEPS)),$(JDEPS),$(addsuffix /$(JDEPS),$(subst :, ,$(PATH))))))

ifndef JDEPS
$(info NOTE: jdeps not found: incremental compilation disabled)
endif

endif # def HAVE_JDEPS


# NOTE: The "empty" variable must NOT be defined
CLASSPATH := -cp $(subst $(empty) $(empty),:,$(CLASSES_DIR) $(LIBRARIES))


.PHONY: clean

# Everything this Makefile builds is stored under $(BUILD_DIR)
# or $(PACKAGE_DIR)
clean:
	$(RM) -r $(BUILD_DIR) $(PACKAGE_DIR)

# This is the heart of the Makefile.
# All the targets that directly or indirectly trigger (or may trigger)
# the compilation of some Java source file (i.e., all of them, except
# clean), must undergo a three-phase build process:
#   1) collect the names of the source files to be compiled
#   2) compile them, compute/update their dependencies and generate any
#      JNI header file required
#   3) do everything else required by the target
# NOTE: If incremental compilation is disabled (i.e., JDEPS is empty)
#       then, in phase 2, all the Java source files will be
#       unconditionally compiled and dependencies extraction will be
#       skipped.
# Phase 1 and 3 are implemented elsewhere in this Makefile, whereas
# phase 2 is implemented in this rule's recipe, between phase 1 and
# phase 3 invocations.
%:
	@$(MAKE) BUILD_PHASE=1 $@
	@$(MKDIR_P) $(CLASSES_DIR)
ifdef JDEPS
	@if test -s $(JAVAC_SOURCE_FILES_LIST); then \
	  echo "$(JAVAC) -Xlint:deprecation,unchecked -d $(CLASSES_DIR) $(CLASSPATH) @$(JAVAC_SOURCEPATHS_LIST) @$(JAVAC_SOURCE_FILES_LIST)" && \
	  $(JAVAC) -Xlint:deprecation,unchecked -d $(CLASSES_DIR) $(CLASSPATH) @$(JAVAC_SOURCEPATHS_LIST) @$(JAVAC_SOURCE_FILES_LIST) && \
	  if test -f $(JAVA_DEPENDENCIES); then \
	    echo "Updating $(JAVA_DEPENDENCIES)" && \
	    $(FIND) $(CLASSES_DIR) -name '*.class' -cnewer $(JAVA_DEPENDENCIES) >$(JAVA_DEPENDENCIES).tmp && \
	    $(CAT) $(JAVA_DEPENDENCIES).tmp | while read cf; do \
	      cf=$$(echo $$cf | $(SED) -e 's,\$$,\\$$,g'); \
	      $(SED) -Ee "\,^$$cf: ,d" $(JAVA_DEPENDENCIES) >$(JAVA_DEPENDENCIES).bak && \
	      $(MV) $(JAVA_DEPENDENCIES).bak $(JAVA_DEPENDENCIES); \
	    done \
	  else \
	    echo "Building $(JAVA_DEPENDENCIES)" && \
	    $(FIND) $(CLASSES_DIR) -name '*.class' >$(JAVA_DEPENDENCIES).tmp; \
	  fi && \
	  echo "BEGIN {" >$(SOURCE_FILES_FULL_LIST).awk && \
	  $(SED) -Ee 's,^.*(/$(SOURCES_PATH)/.*)$$,sf["\1"]="&",' $(SOURCE_FILES_FULL_LIST) >>$(SOURCE_FILES_FULL_LIST).awk && \
	  echo "}" >>$(SOURCE_FILES_FULL_LIST).awk && \
	  echo '{ if (sf[$$2]) print $$1 " " sf[$$2] }' >>$(SOURCE_FILES_FULL_LIST).awk && \
	  echo "$(CAT) $(JAVA_DEPENDENCIES).tmp | $(XARGS) $(JDEPS) -v" && \
	  $(CAT) $(JAVA_DEPENDENCIES).tmp | $(XARGS) $(JDEPS) -v | \
	    $(SED) -Ene 's,\.,/,g;s,^ +([^ ]+) *-> *([^ ]+).*$$,$(CLASSES_DIR)/\1.class: /$(SOURCES_PATH)/\2.java,p' | \
	    $(AWK) -f $(SOURCE_FILES_FULL_LIST).awk >>$(JAVA_DEPENDENCIES) && \
	  $(RM) $(SOURCE_FILES_FULL_LIST).awk $(JAVA_DEPENDENCIES).tmp; \
	fi
else # def JDEPS
	@if test -s $(SOURCE_FILES_FULL_LIST) -a  -s $(JAVAC_SOURCE_FILES_LIST); then \
	  echo "$(JAVAC) -Xlint:deprecation,unchecked -d $(CLASSES_DIR) $(CLASSPATH) @$(JAVAC_SOURCEPATHS_LIST) @$(SOURCE_FILES_FULL_LIST)" && \
	  $(JAVAC) -Xlint:deprecation,unchecked -d $(CLASSES_DIR) $(CLASSPATH) @$(JAVAC_SOURCEPATHS_LIST) @$(SOURCE_FILES_FULL_LIST); \
	fi
endif # def JDEPS
	@if test -s $(EXPORTED_CLASSES_LIST); then \
	  $(MKDIR_P) $(INCLUDE_DIR) && \
	  $(CAT) $(EXPORTED_CLASSES_LIST) | while read sf cn; do \
	    if $(FGREP) -q "$$sf" $(JAVAC_SOURCE_FILES_LIST); then \
	      echo "$$cn"; \
	    fi \
	  done >$(JAVAH_CLASSES_LIST); \
	  if test -s $(JAVAH_CLASSES_LIST); then \
	    echo "$(CAT) $(JAVAH_CLASSES_LIST) | $(XARGS) $(JAVAH) -d $(INCLUDE_DIR) $(CLASSPATH)" && \
	    $(CAT) $(JAVAH_CLASSES_LIST) | $(XARGS) $(JAVAH) -d $(INCLUDE_DIR) $(CLASSPATH); \
	  fi \
	fi
	@$(MAKE) BUILD_PHASE=3 $@


else # ndef BUILD_PHASE


###############################################
# Phase 1 & 3 common macros - build.mk macros #
###############################################

# Lists the variables that will be used to "filter" the resources,
# i.e., for each "varname" listed, the string "${varname}" will be
# looked for in the resources and replaced with the value of
# the variable "varname"
EXTRA_VARIABLES := resources.jars release.version


# The following macros are meant to be used in the components' build.mk.
# The "component base directory" is where the build.mk file is located
# (see the sample build.mk for an example of use).

# Arguments:
#   $(1) - component base directory
FIND_SOURCES = $(shell test -d $(1)$(SOURCES_PATH) && $(FIND) $(1)$(SOURCES_PATH) -name '*.java')

# Arguments:
#   $(1) - component base directory
FIND_RESOURCES = $(shell test -d $(1)$(RESOURCES_PATH) && $(FIND) $(1)$(RESOURCES_PATH) -type f)

# Arguments:
#   $(1) - component base directory
FIND_NATIVE_SOURCES = $(shell test -d $(1)$(NATIVE_SOURCES_PATH) && $(FIND) $(1)$(NATIVE_SOURCES_PATH) -name '*.c')


##################################################
# Phase 1 & 3 common macros - External libraries #
##################################################

# For each external dependency (see EXTERNAL_LIBRARIES_DIR above)
# the following variables will be defined:
#   <libname>.version   - version of the library
#   <libname>.basename  - file name of the library, without path
#   <libname>.buildname - where to find the library in the filesystem
#                         (relative to the topmost directory)
#   <libname>.jarname   - where to find the library inside JARs (if
#                         included in a JAR)
# where <libname> is the name of the JAR file without the .jar
# extension nor the version number
# NOTE: <libname>.version and <libname>.jarname will be automatically
#       added to the EXTRA_VARIABLES variable


# Convert the parsed library name (see further below) into values
# to be put into the external dependencies' variables, adds
# <libname>.version and <libname>.jarname to EXTRA_VARIABLES and
# define a rule to copy the library into the $(JARS_DIR) directory,
# should the external library be included into some component JAR.

# Arguments:
#   $(1) - parsed library name, i.e. the <libname>:<version> string
define PARSE_LIB_AND_VER =

MK_NAME := $(word 1,$(subst :, ,$(1)))
MK_VERSION := $(word 2,$(subst :, ,$(1)))
MK_JARNAME := $$(if $$(MK_VERSION),$$(MK_NAME)-$$(MK_VERSION).jar,$$(MK_NAME).jar)

$$(MK_NAME).version := $$(MK_VERSION)
$$(MK_NAME).basename := $$(MK_JARNAME)
$$(MK_NAME).buildname := $$(filter %/$$(MK_JARNAME),$$(LIBRARIES))
$$(MK_NAME).jarname := $(resources.jars)/$$(MK_JARNAME)

EXTRA_VARIABLES += $$(MK_NAME).version $$(MK_NAME).jarname

$(BUILD_DIR)/$$(value $$(MK_NAME).jarname): $$(value $$(MK_NAME).buildname) | $(JARS_DIR)
	$(LINK) $$< $$@

endef # PARSE_LIB_AND_VER


# First, parse the file names and convert them into <libname>:<version>
# strings, ...
LIBS_AND_VERS := $(shell echo $(basename $(notdir $(LIBRARIES))) | $(SED) -Ee 's,([^ ]*)-(([0-9.]+)(-[^ ]*)?),\1:\2,g')

# ... then for each such string define the aforementioned library
# variables.
$(foreach var,$(LIBS_AND_VERS),$(eval $(call PARSE_LIB_AND_VER,$(var))))


#######################################################
# Phase 1 & 3 common macros - Helper macros and stuff #
#######################################################

# Includes native libraries too
JARS_LIST :=

# Lists missing included JARs
MISSING_RESOURCE_JARS :=

SOURCES_TO_CLASSES = $(patsubst $(1)$(SOURCES_PATH)/%.java,$(CLASSES_DIR)/%.class,$(2))


.PHONY: compile jars package

$(BUILD_DIR) $(JARS_DIR) $(NATIVE_DIR) $(PACKAGE_DIR):
	$(MKDIR_P) $@


ifeq ($(BUILD_PHASE),1)


#################################################
# Phase 1 - Collect source files to be compiled #
#################################################

# -sourcepath directories list 
SOURCE_DIRECTORIES :=

# Java source files
SOURCE_FILES :=


# Store -sourcepath directories -- it must be created once at every
# run that's why we need the clean_javac_sourcepaths_list target
# and the .PHONY special target

.PHONY: clean_javac_sourcepaths_list $(JAVAC_SOURCEPATHS_LIST)

clean_javac_sourcepaths_list: | $(BUILD_DIR)
	@: >$(JAVAC_SOURCEPATHS_LIST)

$(JAVAC_SOURCEPATHS_LIST): | clean_javac_sourcepaths_list
	@echo "Building $@" \
	$(foreach var,$(SOURCE_DIRECTORIES),$(shell echo '-sourcepath $(var)$(SOURCES_PATH)' >>$@))


# Store the list of all the Java source files -- it must be created
# once at every run that's why we need the clean_source_files_full_list
# target and the .PHONY special target

.PHONY: clean_source_files_full_list $(SOURCE_FILES_FULL_LIST)

clean_source_files_full_list: | $(BUILD_DIR)
	@: >$(SOURCE_FILES_FULL_LIST)

$(SOURCE_FILES_FULL_LIST): | clean_source_files_full_list
	@echo "Building $@" \
	$(foreach var,$(SOURCE_FILES),$(shell echo '$(var)' >>$@))


# Clean-up the "to be compiled" list of Java source files (it will
# be filled-up somewhere else) -- it must be cleaned at every run
# that's why we need the .PHONY special target

.PHONY: $(JAVAC_SOURCE_FILES_LIST)

$(JAVAC_SOURCE_FILES_LIST): | $(BUILD_DIR)
	@: >$@


#############################
# Phase 1 - build.mk macros #
#############################

# For each JAR library built, the following variables will be defined:
#   <libname>.version   - version of the JAR library
#   <libname>.basename  - file name of the JAR library, without path
#   <libname>.buildname - path (relative to the topmost directory) to
#                         the JAR library
#   <libname>.jarname   - same as above, but relative to
#                         the $(BUILD_DIR) directory
# where <libname> is the name of the JAR file without the .jar
# extension nor the version number
# NOTE: <libname>.version and <libname>.jarname will be automatically
#       added to the EXTRA_VARIABLES variable only in phase 3.


# Create rules to build a JAR from Java source files.
# The phase 1 version only defines the library variables and the class
# to source files dependencies.
# The implicit %.class rule below will write all the classes older
# than their own source file and/or older than any other class they
# depends on (see the "-include $(JAVA_DEPENDENCIES)" below) to the
# $(JAVAC_SOURCE_FILES_LIST) file.

# Arguments:
#   $(1) - component/JAR name
#   $(2) - component/JAR version
#   $(3) - component base directory
#   $(4) - Java source files list
#   $(5) - resource files list (ignored)
#   $(6) - JARs or native libraries to be included in this JAR (ignored)
define BUILD_MAKE_RULES =

ifeq ($(1),)
$$(error Missing jar basename)
endif

MK_JARNAME := $(if $(2),$(1)-$(2).jar,$(1).jar)

$(1).version := $(2)
$(1).basename := $$(MK_JARNAME)
$(1).buildname := $(JARS_DIR)/$$(MK_JARNAME)
$(1).jarname := $(resources.jars)/$$(MK_JARNAME)

JARS_LIST += $$(value $(1).buildname)
SOURCE_DIRECTORIES += $(3)
SOURCE_FILES += $(4)

compile: $$(call SOURCES_TO_CLASSES,$(3),$(4))

$$(foreach var,$(4),$$(eval $$(call SOURCES_TO_CLASSES,$(3),$$(var)): $$(var)))

$$(value $(1).buildname): $$(call SOURCES_TO_CLASSES,$(3),$(4)) $$(foreach var,$(6),$$(addprefix $(BUILD_DIR)/,$$(value $$(var).jarname)))

endef # BUILD_MAKE_RULES


# Classes files to be processed through javah
JAVAH_CLASSES :=

# Helper macro (see next rules)
CLASSNAME_TO_SOURCEFILE = $(patsubst %,/$(SOURCES_PATH)/%.java,$(subst .,/,$(1)))


# Store javah-processed class files and related source files -- it
# must be created once at every run that's why we need the
# clean_exported_classes_list target and the .PHONY special target
# NOTE: The path to the source file is relative to the component
#       directory -- it will be further processed in the main entry
#       point rule to compute the complete path relative to
#       the topmost directory

.PHONY: clean_exported_classes_list $(EXPORTED_CLASSES_LIST)

clean_exported_classes_list: | $(BUILD_DIR)
	@: >$(EXPORTED_CLASSES_LIST)

$(EXPORTED_CLASSES_LIST): | clean_exported_classes_list
	@echo "Building $@" \
	$(foreach var,$(JAVAH_CLASSES),$(shell echo '$(call CLASSNAME_TO_SOURCEFILE,$(var)) $(var)' >>$@))


# For each native library built, the following variables will be
# defined:
#   <libname>.version   - version of the native library
#   <libname>.basename  - file name of the native library, without path
#   <libname>.buildname - path (relative to the topmost directory) to
#                         the native library
#   <libname>.jarname   - same as above, but relative to
#                         the $(BUILD_DIR) directory
# where <libname> is the name of the native library without extension
# nor version number.
# NOTE: <libname>.version and <libname>.jarname will be automatically
#       added to the EXTRA_VARIABLES variable only in phase 3.


# Create rules to build a native library from C source files.
# The phase 1 version only defines the library variables and build
# the list of classes to process through javah, storing them into
# the JAVAH_CLASSES variables.
# The previous rules will write the list of classes into
# the $(EXPORTED_CLASSES_LIST) file.

# Arguments:
#   $(1) - component/native library name
#   $(2) - component/native library version
#   $(3) - component base directory (ignored)
#   $(4) - C source files list (ignored)
#   $(5) - C compiler flags (CFLAGS) (ignored)
#   $(6) - linker flags (LDFLAGS) (ignored)
#   $(7) - javah classes (in the package.subpackage.classname format)
define BUILD_NATIVE_MAKE_RULES =

ifeq ($(1),)
$$(error Missing library basename)
endif

MK_LIBNAME := $(if $(2),$(1)-$(2).so,$(1).so)

$(1).version := $(2)
$(1).basename := $$(MK_LIBNAME)
$(1).buildname := $(NATIVE_DIR)/$$(MK_LIBNAME)
$(1).jarname := $(resources.libs)/$$(MK_LIBNAME)

JAVAH_CLASSES += $(7)

endef # BUILD_NATIVE_MAKE_RULES


# See the BUILD_MAKE_RULES macro above
$(CLASSES_DIR)/%.class: | $(JAVAC_SOURCEPATHS_LIST) $(JAVAC_SOURCE_FILES_LIST) $(SOURCE_FILES_FULL_LIST) $(EXPORTED_CLASSES_LIST)
	echo $< >>$(JAVAC_SOURCE_FILES_LIST)


else # eq ($(BUILD_PHASE),1)


#############################
# Phase 3 - build.mk macros #
#############################

# Verify the specified library has been defined.

# Arguments:
#   $(1) - component/JAR name
define CHECK_INCLUDED_JAR =

ifndef $(1).jarname
MISSING_RESOURCE_JARS += $(1)
endif

endef # CHECK_INCLUDED_JAR


# Compute the file name of a filtered resource

# Arguments:
#   $(1) - component base directory
#   $(2) - component/JAR name
#   $(3) - unfiltered resource file name
RESOURCES_TO_JAR = $(patsubst $(1)$(RESOURCES_PATH)/%,$(RESOURCES_DIR)/$(2)/%,$(3))


# Create rules to build a JAR from Java source files.
# The phase 3 version defines the library variables and the filtered to
# unfiltered resource dependencies and verifies that all the included
# libraries are defined (this means that the build.mk file of any
# included JAR or native library must be included in the Makefile
# before the including JAR's build.mk -- see also "Components' build.mk"
# below).
# There's no implicit %.class rule. The compile target is not really
# needed as that's phase 1 task. However, I've decided to keep it as
# a means to double-check the rules -- should phase 1 fails to poperly
# perform its task, we would get a "make: *** No rule to make target
# `abc', needed by `def'.  Stop." error message.
# The implicit $(RESOURCES_DIR)/% rule below will filter all
# the resource files before copying them into the $(RESOURCES_DIR)
# directory.
# Note that, if it already exists, the built JAR will be updated with
# the newer classes/resources/included libraries.

# Arguments:
#   $(1) - component/JAR name
#   $(2) - component/JAR version
#   $(3) - component base directory
#   $(4) - Java source files list
#   $(5) - resource files list
#   $(6) - JARs or native libraries to be included in this JAR
define BUILD_MAKE_RULES =

ifeq ($(1),)
$$(error Missing jar basename)
endif

MK_JARNAME := $(if $(2),$(1)-$(2).jar,$(1).jar)

$(1).version := $(2)
$(1).basename := $$(MK_JARNAME)
$(1).buildname := $(JARS_DIR)/$$(MK_JARNAME)
$(1).jarname := $(resources.jars)/$$(MK_JARNAME)

EXTRA_VARIABLES += $(1).version $(1).jarname
JARS_LIST += $$(value $(1).buildname)

compile: $$(call SOURCES_TO_CLASSES,$(3),$(4))

$$(foreach var,$(5),$$(eval $$(call RESOURCES_TO_JAR,$(3),$(1),$$(var)): $$(var)))

$$(foreach var,$(6),$$(eval $$(call CHECK_INCLUDED_JAR,$$(var))))

$$(value $(1).buildname): $$(call SOURCES_TO_CLASSES,$(3),$(4)) \
                          $$(call RESOURCES_TO_JAR,$(3),$(1),$(5)) \
                          $$(foreach var,$(6),$$(addprefix $(BUILD_DIR)/,$$(value $$(var).jarname))) | $(JARS_DIR)
	if test -f $$@; then cmd=u; else cmd=c; fi && \
	$(JAR) $$$${cmd}vf $$@ \
	  $$(addprefix -C $(CLASSES_DIR) ,$$(patsubst $(CLASSES_DIR)/%,'%',$$(filter $(CLASSES_DIR)/%,$$?) \
	                                                                   $$(wildcard $$(patsubst %.class,%$$$$*.class,$$(filter $(CLASSES_DIR)/%,$$?))))) \
	  $$(addprefix -C $(RESOURCES_DIR)/$(1) ,$$(patsubst $(RESOURCES_DIR)/$(1)/%,'%',$$(filter $(RESOURCES_DIR)/%,$$?))) \
	  $$(addprefix -C $(BUILD_DIR) ,$$(patsubst $(BUILD_DIR)/%,'%',$$(filter $(JARS_DIR)/%,$$?)))

endef # BUILD_MAKE_RULES


# Find out where javah include files are stored.
# As this is an expensive operation, we cache the result into
# the $(JDK_INCLUDE) file.
# As the $(JDK_INCLUDE) file is included as a dependency in every
# native object/dependency list file, it will be built only if needed.

$(JDK_INCLUDE):
	@echo "Building $@" && \
	dir=$$($(JAVA) -XshowSettings:properties -version 2>&1 | $(SED) -ne 's,^ *java\.home *= *\(.*\)$$,\1/../include,p') && \
	if test -n "$$dir"; then \
	  (cd "$$dir" && pwd) >$@; \
	else \
	  echo "ERROR: Cannot find JDK include directory"; \
	  exit 1; \
	fi


# Supported architecture for native code -- $(ARCHITECTURE) must expand
# to the name of an architecture supported by javah, this is used to
# access architecture-specific javah include files
ifeq ($(shell $(OS)),GNU/Linux)
ARCHITECTURE := linux
else ifeq ($(shell $(OS)),FreeBSD)
ARCHITECTURE := freebsd
else
ARCHITECTURE := unknown
endif


# Helper macros (see next two macros)
SOURCES_TO_DEPENDENCIES = $(patsubst $(2)$(NATIVE_SOURCES_PATH)/%.c,$(OBJECTS_DIR)/$(1)/%.d,$(3))
SOURCES_TO_OBJECTS = $(patsubst $(2)$(NATIVE_SOURCES_PATH)/%.c,$(OBJECTS_DIR)/$(1)/%.o,$(3))


# Create the rules to compile object files (.o) and dependencies
# files (.d).
# Including the dependency files into the Makefile would ensure that
# they are build if non existent or older than the C source file or
# any other object file's dependency -- in fact, each dependency file
# will contain both the object file and itself as dependant from all
# the files (recursively) included from the source file.
# NOTE: I've tested this rules with both gcc and clang. Other
#       compilers may require some tweak, especially in the recipes.

# Arguments:
#   $(1) - component/native library name
#   $(2) - component base directory
#   $(3) - component-specific CFLAGS
#   $(4) - C source file name
define BUILD_NATIVE_COMPILE_RULES =

ifeq ($(ARCHITECTURE),unknown)
$$(error Unsupported OS: $(shell $(OS)))
endif

include $$(call SOURCES_TO_DEPENDENCIES,$(1),$(2),$(4))

$$(call SOURCES_TO_DEPENDENCIES,$(1),$(2),$(4)): $(4) | $(JDK_INCLUDE)
	$(MKDIR_P) $$$$(dirname $$@) && \
	JDK_INCLUDE_DIR=$$$$(cat $(JDK_INCLUDE)) && \
	$(CPP) $(CPPFLAGS) -I $$$$JDK_INCLUDE_DIR -I $$$$JDK_INCLUDE_DIR/$(ARCHITECTURE) -I $(INCLUDE_DIR) -MM \
	  -MT '$$(call SOURCES_TO_DEPENDENCIES,$(1),$(2),$(4)) $$(call SOURCES_TO_OBJECTS,$(1),$(2),$(4))' $$< >$$@

$$(call SOURCES_TO_OBJECTS,$(1),$(2),$(4)): $(4) | $(JDK_INCLUDE)
	$(MKDIR_P) $$$$(dirname $$@) && \
	JDK_INCLUDE_DIR=$$$$(cat $(JDK_INCLUDE)) && \
	$(CC) $(CPPFLAGS) $(CFLAGS) -I $$$$JDK_INCLUDE_DIR -I $$$$JDK_INCLUDE_DIR/$(ARCHITECTURE) -I $(INCLUDE_DIR) $(3) -c -o $$@ $$<

endef # BUILD_NATIVE_COMPILE_RULES


# Create rules to build a native library from C source files.
# The phase 3 version defines the library variables, the library link
# rule and the source files compile rules.

# Arguments:
#   $(1) - component/native library name
#   $(2) - component/native library version
#   $(3) - component base directory
#   $(4) - C source files list
#   $(5) - C compiler flags (CFLAGS)
#   $(6) - linker flags (LDFLAGS)
#   $(7) - javah classes (in the package.subpackage.classname format)
#          (ignored)
define BUILD_NATIVE_MAKE_RULES =

ifeq ($(1),)
$$(error Missing library basename)
endif

MK_LIBNAME := $(if $(2),$(1)-$(2).so,$(1).so)

$(1).version := $(2)
$(1).basename := $$(MK_LIBNAME)
$(1).buildname := $(NATIVE_DIR)/$$(MK_LIBNAME)
$(1).jarname := $(resources.libs)/$$(MK_LIBNAME)

EXTRA_VARIABLES += $(1).version $(1).jarname
JARS_LIST += $$(value $(1).buildname)

compile: $$(call SOURCES_TO_OBJECTS,$(1),$(3),$(4))

$$(foreach var,$(4),$$(eval $$(call BUILD_NATIVE_COMPILE_RULES,$(1),$(3),$(5),$$(var))))

$$(value $(1).buildname): $$(call SOURCES_TO_OBJECTS,$(1),$(3),$(4)) | $(NATIVE_DIR)
	$(CC) $(LDFLAGS) $(6) -o $$@ $$^

endef # BUILD_NATIVE_MAKE_RULES


# Build the sed script used to filter the resources -- for it must be
# created once at every run, we need the clean_resources_filter_script
# and .PHONY targets.
# The script will parse the resource files looking for strings of the
# form "${varname}" and will substitute those strings with the value of
# the make variable named "varname".
# Only the varnames listed in EXTRA_VARIABLES will be substituted -- any
# string of the form "${varname}" where varname is not listed in
# EXTRA_VARIABLES will be left untouched.

.PHONY: clean_resources_filter_script $(RESOURCES_FILTER_SCRIPT)

clean_resources_filter_script: | $(BUILD_DIR)
	@: >$(RESOURCES_FILTER_SCRIPT)

$(RESOURCES_FILTER_SCRIPT): | clean_resources_filter_script
	@echo "Building $@" \
	$(foreach var,$(EXTRA_VARIABLES),$(shell echo 's|$${$(var)}|$($(var))|g' >>$(RESOURCES_FILTER_SCRIPT)))


# This rule applies the aforementioned sed script to all the resource
# files.
# NOTE: For text-only files this is good enough, but for binary,
#       especially *big* binary files, this could cause some trouble.
#       A possible solution would be to split the resources into two
#       distinct directories -- one for resources to filter and the
#       other for resources to keep as are.

$(RESOURCES_DIR)/%: | $(RESOURCES_FILTER_SCRIPT)
	$(MKDIR_P) $$(dirname $@) && \
	$(SED) -f $(RESOURCES_FILTER_SCRIPT) $< >$@


endif # eq ($(BUILD_PHASE),1)


########################
# Components' build.mk #
########################

# Here are included all the build.mk of the project.
# Order is not important, unless some component include some other
# component's jar (see next comments).

# foo must be included before bar for bar's build.mk references
# foo's jar as an included jar (see phase 3's BUILD_MAKE_RULES)
include foo/java/build.mk
include bar/build.mk

ifeq ($(ENABLE_FOO_FEATURE),true)
include foo/native/build.mk
endif


# If variable MISSING_RESOURCE_JARS is not empty, then some component
# is including some undefined jar file.
# This may also happen if the build.mk file defining the included jar
# was itself included in this Makefile *after* the build.mk file
# referencing the included jar (see previous comment).

ifdef MISSING_RESOURCE_JARS
$(error Missing extra jar(s): $(MISSING_RESOURCE_JARS))
endif


# Next include Java classes dependencies -- if the file
# $(JAVA_DEPENDENCIES) does not exist, we are compiling for the first
# time or right after having invoked the clean target, thus we are
# going to compile everything, then we don't need to track any
# dependency.

-include $(JAVA_DEPENDENCIES)


# A convenience target to build all the JARs of the project, without
# packing them into packages (see below).

jars: $(JARS_LIST)


#############
# Packaging #
#############

# The following are rules to collect the JARs and native libraries
# built into a package.
# This is just an example -- you can (and should) customize them to your
# taste, e.g., collecting them into multiple packages or maybe just
# moving the JARs into some predefined directory.

# First, we define variables to list the files that will build the
# package: one variable for each directory inside the package.

BAR_BIN_BUILD_LIST := bin/run.sh

BAR_DOC_BUILD_LIST := doc/README

BAR_JAR_BUILD_LIST := $(bar.buildname)

FOO_NATIVE_BUILD_LIST :=

ifeq ($(ENABLE_FOO_FEATURE),true)
FOO_NATIVE_BUILD_LIST += $(libfoo-linux.buildname)
endif


ifeq ($(BUILD_PHASE),1)


# During phase 1 we only need to list package's dependencies that will
# lead to Java classes, i.e., the JAR files.

# *_JAR_BUILD_LIST only
$(PACKAGE_DIR)/foobar-$(release.version).tar.gz: $(BAR_JAR_BUILD_LIST)

package: $(PACKAGE_DIR)/foobar-$(release.version).tar.gz


else #eq ($(BUILD_PHASE),1)


# In phase 3 we actually build the package.
# First the files listed in the *_BUILD_LIST variables are copied into
# the stage directory (STAGE_DIR), then the package is created running
# tar from that directory.


# Convert the file names listed in the *_BUILD_LIST variables into their
# respective file names under the stage directory.

# Arguments:
#   $(1) - stage subdirectory (may be empty)
#   $(2) - stage files
INTO_STAGE = $(addprefix $(STAGE_DIR)/$(if $(1),$(1)/,),$(notdir $(2)))


# Create rules to build stage subdirectories and define dependencies
# between the stage files and their respective *_BUILD_LIST files.
# All the stage file names are collected in a variable whose name is
# specified in the second argument -- it will be used to define the
# package's prerequisites.

# Arguments:
#   $(1) - build list files
#   $(2) - stage files variable name
#   $(3) - stage subdirectory
define ADD_PACKAGE_RULES =

$(2) += $$(call INTO_STAGE,$(3),$(1))

$(STAGE_DIR)/$(3):
	$(MKDIR_P) $$@

$$(foreach var,$(1),$$(eval $$(call INTO_STAGE,$(3),$$(var)): $$(var) | $(STAGE_DIR)/$(3)))

endef # ADD_PACKAGE_RULES


# Hard links are faster to build than copying
$(STAGE_DIR)/%:
	$(LINK) $^ $@

# *.sh files are treated specially: they are both filtered as resources
# are and made executable
$(STAGE_DIR)/%.sh: | $(RESOURCES_FILTER_SCRIPT)
	$(SED) -f $(RESOURCES_FILTER_SCRIPT) $< >$@ && \
	$(CHMOD) a+x $@


FOOBAR_STAGE_LIST :=

$(eval $(call ADD_PACKAGE_RULES,$(BAR_BIN_BUILD_LIST),FOOBAR_STAGE_LIST,bin))
$(eval $(call ADD_PACKAGE_RULES,$(BAR_DOC_BUILD_LIST),FOOBAR_STAGE_LIST,doc))
$(eval $(call ADD_PACKAGE_RULES,$(BAR_JAR_BUILD_LIST),FOOBAR_STAGE_LIST,lib))
$(eval $(call ADD_PACKAGE_RULES,$(FOO_NATIVE_BUILD_LIST),FOOBAR_STAGE_LIST,native))


$(PACKAGE_DIR)/foobar-$(release.version).tar.gz: $(FOOBAR_STAGE_LIST) | $(PACKAGE_DIR)
	$(RM) $@ && $(TAR) -czv -f $@ -C $(STAGE_DIR) $(patsubst $(STAGE_DIR)/%,'%',$^)

package: $(PACKAGE_DIR)/foobar-$(release.version).tar.gz


endif # eq ($(BUILD_PHASE),1)


endif # ndef BUILD_PHASE
