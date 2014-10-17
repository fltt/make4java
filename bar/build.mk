MK_NAME := bar
MK_VERSION := 1.0.0

MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

MK_SOURCES := $(call FIND_SOURCES,$(MK_DIR))
MK_RESOURCES := $(call FIND_RESOURCES,$(MK_DIR))
MK_INCLUDED_JARS := foo

bar.name := FooBar Dummy Tool
bar.vendor := FooTech
bar.version := $(MK_VERSION)

EXTRA_VARIABLES += bar.name bar.vendor bar.version

$(eval $(call BUILD_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_RESOURCES),$(MK_INCLUDED_JARS)))
