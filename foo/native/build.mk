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

MK_NAME := libfoo-linux
MK_VERSION :=

MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

MK_SOURCES := $(call FIND_NATIVE_SOURCES,$(MK_DIR))
MK_CFLAGS := -fPIC
MK_LDFLAGS := -shared
MK_JAVAH_CLASSES := dummy.foo.AdderImpl

$(eval $(call BUILD_NATIVE_MAKE_RULES,$(MK_NAME),$(MK_VERSION),$(MK_DIR),$(MK_SOURCES),$(MK_CFLAGS),$(MK_LDFLAGS),$(MK_JAVAH_CLASSES)))
