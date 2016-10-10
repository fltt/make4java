dnl make4java - A Makefile for Java projects
dnl
dnl Written in 2016 by Francesco Lattanzio <franz.lattanzio@gmail.com>
dnl
dnl To the extent possible under law, the author have dedicated all
dnl copyright and related and neighboring rights to this software to
dnl the public domain worldwide. This software is distributed without
dnl any warranty.
dnl
dnl You should have received a copy of the CC0 Public Domain Dedication
dnl along with this software.
dnl If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
dnl
AC_PREREQ([2.62])
AC_INIT([FooBar Sample Application], [1.1.0], [franz.lattanzio@gmail.com], [foobar])
AC_CONFIG_SRCDIR([bar/java/build.mk])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
dnl *** Check options (first) ***
AC_ARG_ENABLE([foo-feature],
              [AS_HELP_STRING([--enable-foo-feature],
                              [enable the foo-feature @<:@default=no@:>@])],
              [AS_CASE([$enableval],
                       [yes|no], [],
                       [AC_MSG_ERROR([--enable-foo-feature was given an invalid argument])])],
              [enable_foo_feature=no])
AC_SUBST([ENABLE_FOO_FEATURE], [$enable_foo_feature])
AC_ARG_ENABLE([jdeps],
              [AS_HELP_STRING([--enable-jdeps@<:@=yes|no|check@:>@],
                              [enable incremental compilation @<:@default=check@:>@])],
              [AS_CASE([$enableval],
                       [yes|no|check], [],
                       [AC_MSG_ERROR([--enable-jdeps was given an invalid argument])])],
              [enable_jdeps=check])
dnl Enable checking for tools required to compile native code only if
dnl needed.
enable_native=no
AS_IF([test "x$enable_foo_feature" = xyes],
      [enable_native=yes])
missing_programs=""
dnl *** Check for tools required unconditionally ***
dnl AC_PROG_LN_S always define something
AC_PROG_LN_S
AC_ARG_VAR([LN_S], [ln -s command])dnl
dnl AC_PROG_MKDIR_P always define something.
AC_PROG_MKDIR_P
AC_ARG_VAR([MKDIR_P], [mkdir -p command])dnl
AC_PROG_SED
AC_ARG_VAR([SED], [sed command])dnl
AS_IF([test "x$SED" = x],
      [missing_programs="$missing_programs sed"])
AC_CHECK_PROGS([FIND], [find])
AC_ARG_VAR([FIND], [find command])dnl
AS_IF([test "x$FIND" = x],
      [missing_programs="$missing_programs find"])
_AM_PROG_TAR([v7])
AC_ARG_VAR([TAR], [tar command])dnl
AC_CHECK_PROGS([GZIP], [gzip])
AC_ARG_VAR([GZIP], [gzip command])dnl
AC_ARG_VAR([GZIP_OPTIONS], [gzip compression options, default is '--best'])dnl
AS_IF([test "x$GZIP" = x],
      [AC_SUBST([COMPRESS], [cat])
       AC_SUBST([COMPRESS_EXT], [])],
      [AC_SUBST([COMPRESS], ["$GZIP \$\${GZIP_OPTIONS---best} -c"])
       AC_SUBST([COMPRESS_EXT], [.gz])])
FLTT_PROG_JAVAC
AS_IF([test "x$JAVAC" = x],
      [missing_programs="$missing_programs javac"])
FLTT_PROG_JAR
AS_IF([test "x$JAR" = x],
      [missing_programs="$missing_programs jar"])
FLTT_PROG_JAVA
AS_IF([test "x$JAVA" = x],
      [missing_programs="$missing_programs java"])
dnl *** Check for tools required only when compiling native code ***
dnl NOTE: Autoconf expands all the AC_REQUIRE'd macros outside
dnl       conditional blocks on purpose. To ensure that all those
dnl       macros are expanded inside the AS_IF block, care must be
dnl       taken to invoke all their AC_REQUIRE'd macros directly.
dnl       This trick, however, does not work for all the macros.
dnl       Those defined by means of AC_DEFUN_ONCE (e.g.
dnl       AC_CANONICAL_BUILD below) will be expanded outside
dnl       nevertheless. I'll keep them inside the conditional block
dnl       just in case someday their definition is changed to AC_DEFUN
dnl       or equivalent.
AS_IF([test "x$enable_native" = xyes],
      [AC_CANONICAL_BUILD
AC_PROG_CC
AC_PROG_CC_C_O
AS_IF([eval test \$ac_cv_prog_cc_${ac_cc}_c_o != yes],
      [AC_MSG_ERROR([your C compiler doesn't accept -c and -o together])])
AC_PROG_CPP
dnl AC_PROG_GREP is AC_REQUIRE'd by AC_PROG_FGREP.
AC_PROG_GREP
AC_PROG_FGREP
AC_ARG_VAR([FGREP], [fgrep command])dnl
dnl AC_LANG_COMPILER is indirectly AC_REQUIRE'd by FLTT_PROG_JAVAH.
AC_LANG_COMPILER(C)
FLTT_PROG_JAVAH
AS_IF([test "x$JAVAH" = x],
      [missing_programs="$missing_programs javah"],
      [AS_IF([test "x$JAVAH_CPPFLAGS" = x],
             [AC_MSG_ERROR([could not find jni.h])])])
AC_CHECK_PROGS([XARGS], [xargs])
AC_ARG_VAR([XARGS], [xargs command])dnl
AS_IF([test "x$XARGS" = x],
      [missing_programs="$missing_programs xargs"])
])
dnl *** Check for tools required only when compiling incrementally ***
missing_jdeps_programs=""
AS_IF([test "x$enable_jdeps" != xno],
      [AC_PROG_AWK
AC_ARG_VAR([AWK], [awk command])dnl
AC_CHECK_PROGS([XARGS], [xargs])
dnl Checking for jdeps is costly, thus we check for it only if both
dnl AWK and XARGS are available.
AS_IF([test "x$AWK" = x || test "x$XARGS" = x],
      [AS_IF([test "x$AWK" = x],
             [missing_jdeps_programs="$missing_jdeps_programs awk"])
AS_IF([test "x$XARGS" = x],
      [missing_jdeps_programs="$missing_jdeps_programs xargs"])],
      [FLTT_PROG_JDEPS
AS_IF([test "x$JDEPS" = x],
      [missing_jdeps_programs="$missing_jdeps_programs jdeps"])])])
dnl *** Report missing tools ***
AS_IF([test "x$enable_jdeps" = xyes],
      [missing_programs="$missing_programs$missing_jdeps_programs"])
AS_IF([test "x$missing_programs" != x],
      [AC_MSG_ERROR([the following program(s) couldn't be found:$missing_programs])])
AS_IF([test "x$missing_jdeps_programs" != x],
      [AC_MSG_WARN([incremental compilation is disabled for the following program(s) couldn't be found:$missing_jdeps_programs])])
AS_IF([test "x$TAR" = xfalse],
      [AC_MSG_WARN([could not find the tar utility, the tar package won't be built])])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_HEADERS([config.h])
AC_OUTPUT
