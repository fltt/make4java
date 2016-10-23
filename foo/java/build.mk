# make4java - A Makefile for Java projects
#
# Written in 2016 by Francesco Lattanzio <franz.lattanzio@gmail.com>
#
# To the extent possible under law, the author have dedicated all
# copyright and related and neighboring rights to this software to
# the public domain worldwide. This software is distributed without
# any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication
# along with this software.
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

MK_NAME := foo
MK_VERSION := 1.0.1
MK_ENABLED := yes

MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

MK_SOURCES := $(call FIND_SOURCES,$(MK_DIR))
MK_RESOURCES := $(call FIND_RESOURCES,$(MK_DIR))
MK_INCLUDED_JARS :=
MK_ADDITIONAL_CLASSES :=

$(eval $(call BUILD_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_ENABLED),$(MK_DIR),$(MK_SOURCES),$(MK_RESOURCES),$(MK_INCLUDED_JARS),$(MK_ADDITIONAL_CLASSES)))
