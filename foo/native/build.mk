MK_NAME := libfoo-linux
MK_VERSION :=

MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

MK_SOURCES := $(call FIND_NATIVE_SOURCES,$(MK_DIR))
MK_CFLAGS := -fPIC -O
ifeq ($(ARCHITECTURE),linux)
MK_LDFLAGS := -shared -lc -ldl
else # freebsd
MK_LDFLAGS := -shared -lc
endif
MK_JAVAH_CLASSES := dummy.foo.AdderImpl

$(eval $(call BUILD_NATIVE_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_CFLAGS),$(MK_LDFLAGS),$(MK_JAVAH_CLASSES)))
