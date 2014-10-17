# To enabled incremental compilation you need the "jdeps" utility (available in
# OpenJDK 1.8). If not found it will revert to full compilation every time one
# or more source files are modified/added (and ONLY if modified/added).
#
# NOTE: Only file modification/addition is supported, that is, if a (re)source
#       file is removed you have to perform a full compilation ("make clean"
#       followed by "make") in order to get rid of old classes/resources.
#
# If you don't want to generate 1.8 bytecode, define the JAVAC variable in the
# "localdefs.mk" file:
#
#   JAVAC := javac -source 1.7 -target 1.7 -bootclasspath /usr/lib/jvm/java-7-openjdk/jre/lib/rt.jar
#
# Choose source, target and bootclasspath's values appropriate for you project.
#
# NOTE: For small projects a full compilation may be faster than an incremental
#       compilation plus dependencies extration. In such cases you may disable
#       "jdeps" adding "HAVE_JDEPS := false" to "localdefs.mk".

-include localdefs.mk

# To change the value of the following variables, add them to "localdefs.mk".

# Hardware driver support
# NOTE: If DAHDI/Dialogic are not installed system-wide you may also need
#       to define CPPFLAGS and LDFLAGS to point to the headers and libraries
ENABLE_FOO_FEATURE ?= false

# Java tools
JAR ?= jar
JAVA ?= java
JAVAC ?= javac
JAVAH ?= javah
JDEPS ?= jdeps

# Every UNIX-like OS should have these (and a Bourne-like shell).
AWK ?= awk
CAT ?= cat
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


# Project structure

resources.jars := jars
resources.libs := libs

SOURCES_PATH := src/main/java
RESOURCES_PATH := src/main/resources
NATIVE_SOURCES_PATH := src/main/native

EXTERNAL_LIBRARIES_DIR := libs

BUILD_DIR := build

SOURCE_FILES_FULL_LIST := $(BUILD_DIR)/source-files
JAVA_DEPENDENCIES := $(BUILD_DIR)/java-dependencies
JAVAC_SOURCEPATHS_LIST := $(BUILD_DIR)/javac-sourcepaths
JAVAC_SOURCE_FILES_LIST := $(BUILD_DIR)/javac-source-files

EXPORTED_CLASSES_LIST := $(BUILD_DIR)/exported-classes
JAVAH_CLASSES_LIST := $(BUILD_DIR)/javah-classes
JDK_INCLUDE := $(BUILD_DIR)/jdk-include

CLASSES_DIR := $(BUILD_DIR)/classes
RESOURCES_DIR := $(BUILD_DIR)/resources
RESOURCES_FILTER_SCRIPT := $(BUILD_DIR)/sed-script
JARS_DIR := $(BUILD_DIR)/$(resources.jars)

OBJECTS_DIR := $(BUILD_DIR)/obj
INCLUDE_DIR := $(BUILD_DIR)/include
NATIVE_DIR := $(BUILD_DIR)/$(resources.libs)

STAGE_DIR := $(BUILD_DIR)/packages
PACKAGE_DIR := packages


release.version := 1.0.3

ifeq ($(shell $(OS)),GNU/Linux)
ARCHITECTURE := linux
else ifeq ($(shell $(OS)),FreeBSD)
ARCHITECTURE := freebsd
else
ARCHITECTURE := unknown
endif

LIBRARIES := $(shell test -d $(EXTERNAL_LIBRARIES_DIR) && $(FIND) $(EXTERNAL_LIBRARIES_DIR) -name '*.jar')


compile:


ifndef BUILD_PHASE


ifdef HAVE_JDEPS

ifneq ($(HAVE_JDEPS),true)
JDEPS :=
endif

else # def HAVE_JDEPS

JDEPS := $(firstword $(wildcard $(if $(filter /%,$(JDEPS)),$(JDEPS),$(addsuffix /$(JDEPS),$(subst :, ,$(PATH))))))

ifndef JDEPS
$(info NOTE: jdeps not found: incremental compilation disabled)
endif

endif # def HAVE_JDEPS


# NOTE: 'empty' must NOT be defined
CLASSPATH := -cp $(subst $(empty) $(empty),:,$(CLASSES_DIR) $(LIBRARIES))

.PHONY: clean

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
	@$(MAKE) BUILD_PHASE=2 $@

clean:
	$(RM) -r $(BUILD_DIR) $(PACKAGE_DIR)


else # ndef BUILD_PHASE


.PHONY: compile jars package

$(BUILD_DIR) $(CLASSES_DIR) $(JARS_DIR) $(NATIVE_DIR) $(PACKAGE_DIR):
	$(MKDIR_P) $@


# build.mk filtered variables
EXTRA_VARIABLES := resources.jars release.version

# build.mk macros
FIND_SOURCES = $(shell test -d $(1)$(SOURCES_PATH) && $(FIND) $(1)$(SOURCES_PATH) -name '*.java')
FIND_RESOURCES = $(shell test -d $(1)$(RESOURCES_PATH) && $(FIND) $(1)$(RESOURCES_PATH) -type f)
FIND_NATIVE_SOURCES = $(shell test -d $(1)$(NATIVE_SOURCES_PATH) && $(FIND) $(1)$(NATIVE_SOURCES_PATH) -name '*.c')


JARS_LIST :=
MISSING_RESOURCE_JARS :=

SOURCES_TO_CLASSES = $(patsubst $(1)$(SOURCES_PATH)/%.java,$(CLASSES_DIR)/%.class,$(2))
CLASSNAME_TO_SOURCEFILE = $(patsubst %,/$(SOURCES_PATH)/%.java,$(subst .,/,$(1)))

RESOURCES_TO_JAR = $(patsubst $(1)$(RESOURCES_PATH)/%,$(RESOURCES_DIR)/$(2)/%,$(3))

SOURCES_TO_OBJECTS = $(patsubst $(2)$(NATIVE_SOURCES_PATH)/%.c,$(OBJECTS_DIR)/$(1)/%.o,$(3))
SOURCES_TO_DEPENDENCIES = $(patsubst $(2)$(NATIVE_SOURCES_PATH)/%.c,$(OBJECTS_DIR)/$(1)/%.d,$(3))

LIBS_AND_VERS := $(shell echo $(basename $(notdir $(LIBRARIES))) | $(SED) -Ee 's,([^ ]*)-(([0-9.]+)(-[^ ]*)?),\1:\2,g')
LIB_TO_JAR = $(addprefix $(JARS_DIR)/,$(notdir $(1)))


define PARSE_LIB_AND_VER =

MK_NAME := $(word 1,$(subst :, ,$(1)))
MK_VERSION := $(word 2,$(subst :, ,$(1)))
MK_JARNAME := $$(if $$(MK_VERSION),$$(MK_NAME)-$$(MK_VERSION).jar,$$(MK_NAME).jar)

$$(MK_NAME).version := $$(MK_VERSION)
$$(MK_NAME).basename := $$(MK_JARNAME)
$$(MK_NAME).buildname := $$(filter %/$$(MK_JARNAME),$$(LIBRARIES))
$$(MK_NAME).jarname := $$(addprefix $(resources.jars)/,$$(MK_JARNAME))

EXTRA_VARIABLES += $$(MK_NAME).version $$(MK_NAME).jarname

$(BUILD_DIR)/$$($$(MK_NAME).jarname): $$($$(MK_NAME).buildname) | $(JARS_DIR)
	$(LINK) $$< $$@

endef # PARSE_LIB_AND_VER


$(foreach var,$(LIBS_AND_VERS),$(eval $(call PARSE_LIB_AND_VER,$(var))))


ifeq ($(BUILD_PHASE),1)


SOURCE_DIRECTORIES :=
SOURCE_FILES :=

.PHONY: clean_javac_sourcepaths_list $(JAVAC_SOURCEPATHS_LIST)

clean_javac_sourcepaths_list: | $(BUILD_DIR)
	@: >$(JAVAC_SOURCEPATHS_LIST)

$(JAVAC_SOURCEPATHS_LIST): | clean_javac_sourcepaths_list
	@echo "Building $@" \
	$(foreach var,$(SOURCE_DIRECTORIES),$(shell echo '-sourcepath $(var)$(SOURCES_PATH)' >>$@))

.PHONY: $(JAVAC_SOURCE_FILES_LIST)

$(JAVAC_SOURCE_FILES_LIST): | $(BUILD_DIR)
	@: >$@

.PHONY: clean_source_files_full_list $(SOURCE_FILES_FULL_LIST)

clean_source_files_full_list: | $(BUILD_DIR)
	@: >$(SOURCE_FILES_FULL_LIST)

$(SOURCE_FILES_FULL_LIST): | clean_source_files_full_list
	@echo "Building $@" \
	$(foreach var,$(SOURCE_FILES),$(shell echo '$(var)' >>$@))


define BUILD_MAKE_RULES =

ifeq ($(1),)
$$(error Missing jar basename)
endif

MK_JARNAME := $(if $(2),$(1)-$(2).jar,$(1).jar)

$(1).version := $(2)
$(1).buildname := $(JARS_DIR)/$$(MK_JARNAME)
$(1).basename := $$(MK_JARNAME)
$(1).jarname := $(resources.jars)/$$(MK_JARNAME)

JARS_LIST += $(JARS_DIR)/$$(MK_JARNAME)
SOURCE_DIRECTORIES += $(3)
SOURCE_FILES += $(4)

compile: $$(call SOURCES_TO_CLASSES,$(3),$(4))

$$(foreach var,$(4),$$(eval $$(call SOURCES_TO_CLASSES,$(3),$$(var)): $$(var)))

$(JARS_DIR)/$$(MK_JARNAME): $$(call SOURCES_TO_CLASSES,$(3),$(4)) $$(foreach var,$(6),$$(value $$(var).buildname))

endef # BUILD_MAKE_RULES


JAVAH_CLASSES :=

.PHONY: clean_exported_classes_list $(EXPORTED_CLASSES_LIST)

clean_exported_classes_list: | $(BUILD_DIR)
	@: >$(EXPORTED_CLASSES_LIST)

$(EXPORTED_CLASSES_LIST): | clean_exported_classes_list
	@echo "Building $@" \
	$(foreach var,$(JAVAH_CLASSES),$(shell echo '$(call CLASSNAME_TO_SOURCEFILE,$(var)) $(var)' >>$@))

define BUILD_NATIVE_MAKE_RULES =

ifeq ($(1),)
$$(error Missing library basename)
endif

MK_LIBNAME := $(if $(2),$(1)-$(2).so,$(1).so)

$(1).version := $(2)
$(1).buildname := $(NATIVE_DIR)/$$(MK_LIBNAME)
$(1).basename := $$(MK_LIBNAME)
$(1).libname := $(resources.libs)/$$(MK_LIBNAME)

JAVAH_CLASSES += $(7)

endef # BUILD_NATIVE_MAKE_RULES


$(CLASSES_DIR)/%.class: | $(JAVAC_SOURCEPATHS_LIST) $(JAVAC_SOURCE_FILES_LIST) $(SOURCE_FILES_FULL_LIST) $(EXPORTED_CLASSES_LIST)
	echo $< >>$(JAVAC_SOURCE_FILES_LIST)


else # eq ($(BUILD_PHASE),1)


define BUILD_EXTRA_JAR_RULES =

ifndef $(1).jarname
MISSING_RESOURCE_JARS += $(1)
endif

endef # BUILD_EXTRA_JAR_RULES


define BUILD_MAKE_RULES =

ifeq ($(1),)
$$(error Missing jar basename)
endif

MK_JARNAME := $(if $(2),$(1)-$(2).jar,$(1).jar)

$(1).version := $(2)
$(1).buildname := $(JARS_DIR)/$$(MK_JARNAME)
$(1).basename := $$(MK_JARNAME)
$(1).jarname := $(resources.jars)/$$(MK_JARNAME)

EXTRA_VARIABLES += $(1).version $(1).jarname
JARS_LIST += $(JARS_DIR)/$$(MK_JARNAME)

compile: $$(call SOURCES_TO_CLASSES,$(3),$(4))

$$(foreach var,$(5),$$(eval $$(call RESOURCES_TO_JAR,$(3),$(1),$$(var)): $$(var)))

$$(foreach var,$(6),$$(eval $$(call BUILD_EXTRA_JAR_RULES,$$(var))))

$(JARS_DIR)/$$(MK_JARNAME): $$(call SOURCES_TO_CLASSES,$(3),$(4)) $$(call RESOURCES_TO_JAR,$(3),$(1),$(5)) $$(foreach var,$(6),$$(call LIB_TO_JAR,$$(value $$(var).buildname))) | $(JARS_DIR)
	if test -f $$@; then cmd=u; else cmd=c; fi && \
	$(JAR) $$$${cmd}vf $$@ \
	  $$(addprefix -C $(CLASSES_DIR) ,$$(patsubst $(CLASSES_DIR)/%,'%',$$(filter $(CLASSES_DIR)/%,$$?) \
	                                                                   $$(wildcard $$(patsubst %.class,%$$$$*.class,$$(filter $(CLASSES_DIR)/%,$$?))))) \
	  $$(addprefix -C $(RESOURCES_DIR)/$(1) ,$$(patsubst $(RESOURCES_DIR)/$(1)/%,'%',$$(filter $(RESOURCES_DIR)/%,$$?))) \
	  $$(addprefix -C $(BUILD_DIR) ,$$(patsubst $(BUILD_DIR)/%,'%',$$(filter $(JARS_DIR)/%,$$?)))

endef # BUILD_MAKE_RULES


$(JDK_INCLUDE):
	@echo "Building $@" && \
	dir=$$($(JAVA) -XshowSettings:properties -version 2>&1 | $(SED) -ne 's,^ *java\.home *= *\(.*\)$$,\1/../include,p') && \
	if test -n "$$dir"; then \
	  (cd "$$dir" && pwd) >$@; \
	else \
	  echo "ERROR: Cannot find JDK include directory"; \
	  exit 1; \
	fi


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


define BUILD_NATIVE_MAKE_RULES =

ifeq ($(1),)
$$(error Missing library basename)
endif

MK_LIBNAME := $(if $(2),$(1)-$(2).so,$(1).so)

$(1).version := $(2)
$(1).buildname := $(NATIVE_DIR)/$$(MK_LIBNAME)
$(1).basename := $$(MK_LIBNAME)
$(1).libname := $(resources.libs)/$$(MK_LIBNAME)

EXTRA_VARIABLES += $(1).version $(1).libname
JARS_LIST += $(NATIVE_DIR)/$$(MK_LIBNAME)

compile: $$(call SOURCES_TO_OBJECTS,$(1),$(3),$(4))

$$(foreach var,$(4),$$(eval $$(call BUILD_NATIVE_COMPILE_RULES,$(1),$(3),$(5),$$(var))))

$(NATIVE_DIR)/$$(MK_LIBNAME): $$(call SOURCES_TO_OBJECTS,$(1),$(3),$(4)) | $(NATIVE_DIR)
	$(CC) $(LDFLAGS) $(6) -o $$@ $$^

endef # BUILD_NATIVE_MAKE_RULES


.PHONY: clean_resources_filter_script $(RESOURCES_FILTER_SCRIPT)

clean_resources_filter_script: | $(BUILD_DIR)
	@: >$(RESOURCES_FILTER_SCRIPT)

$(RESOURCES_FILTER_SCRIPT): | clean_resources_filter_script
	@echo "Building $@" \
	$(foreach var,$(EXTRA_VARIABLES),$(shell echo 's|$${$(var)}|$($(var))|g' >>$(RESOURCES_FILTER_SCRIPT)))

$(RESOURCES_DIR)/%: | $(RESOURCES_FILTER_SCRIPT)
	$(MKDIR_P) $$(dirname $@) && \
	$(SED) -f $(RESOURCES_FILTER_SCRIPT) $< >$@


endif # eq ($(BUILD_PHASE),1)


# 'foo' must be included before 'bar', for 'bar' includes 'foo' jar
include foo/java/build.mk
include bar/build.mk

ifeq ($(ENABLE_FOO_FEATURE),true)
include foo/native/build.mk
endif

-include $(JAVA_DEPENDENCIES)

ifdef MISSING_RESOURCE_JARS
$(error Missing extra jar(s): $(MISSING_RESOURCE_JARS))
endif

jars: $(JARS_LIST)


BAR_BIN_BUILD_LIST := bin/run.sh

BAR_DOC_BUILD_LIST := doc/README

BAR_JAR_BUILD_LIST := $(bar.buildname)

FOO_NATIVE_BUILD_LIST :=

ifeq ($(ENABLE_FOO_FEATURE),true)
FOO_NATIVE_BUILD_LIST += $(libfoo-linux.buildname)
endif


ifeq ($(BUILD_PHASE),1)


# *_JAR_BUILD_LIST only
$(PACKAGE_DIR)/foobar-$(release.version).tar.gz: $(BAR_JAR_BUILD_LIST)

package: $(PACKAGE_DIR)/foobar-$(release.version).tar.gz


else #eq ($(BUILD_PHASE),1)


INTO_STAGE = $(addprefix $(STAGE_DIR)/$(if $(1),$(1)/,),$(notdir $(2)))


define BUILD_PACKAGE_RULES =

$(2) := $$(call INTO_STAGE,$(3),$$($(1)))

$(STAGE_DIR)/$(3):
	$(MKDIR_P) $$@

$$(foreach var,$$($(1)),$$(eval $$(call INTO_STAGE,$(3),$$(var)): $$(var) | $(STAGE_DIR)/$(3)))

endef # BUILD_PACKAGE_RULES


define ADD_PACKAGE_RULES =

$(2) += $$(call INTO_STAGE,$(3),$$($(1)))

$(STAGE_DIR)/$(3):
	$(MKDIR_P) $$@

$$(foreach var,$$($(1)),$$(eval $$(call INTO_STAGE,$(3),$$(var)): $$(var) | $(STAGE_DIR)/$(3)))

endef # ADD_PACKAGE_RULES


$(STAGE_DIR)/%:
	$(LINK) $^ $@

$(STAGE_DIR)/%.sh: | $(RESOURCES_FILTER_SCRIPT)
	$(SED) -f $(RESOURCES_FILTER_SCRIPT) $< >$@ && \
	$(CHMOD) a+x $@


$(eval $(call BUILD_PACKAGE_RULES,BAR_BIN_BUILD_LIST,FOOBAR_STAGE_LIST,bin))
$(eval $(call ADD_PACKAGE_RULES,BAR_DOC_BUILD_LIST,FOOBAR_STAGE_LIST,doc))
$(eval $(call ADD_PACKAGE_RULES,BAR_JAR_BUILD_LIST,FOOBAR_STAGE_LIST,lib))
$(eval $(call ADD_PACKAGE_RULES,FOO_NATIVE_BUILD_LIST,FOOBAR_STAGE_LIST,native))


$(PACKAGE_DIR)/foobar-$(release.version).tar.gz: $(FOOBAR_STAGE_LIST) | $(PACKAGE_DIR)
	$(RM) $@ && $(TAR) -czv -f $@ -C $(STAGE_DIR) $(patsubst $(STAGE_DIR)/%,'%',$^)

package: $(PACKAGE_DIR)/foobar-$(release.version).tar.gz


endif # eq ($(BUILD_PHASE),1)


endif # ndef BUILD_PHASE
