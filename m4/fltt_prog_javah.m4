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

# FLTT_PROG_JAVAH
# ---------------
# Locate the Java C header generator and verify that it works. We cannot
# just locate it as some OS makes use of wrapper scripts which may fail
# to work under several circumstances.
# It also locate the "jni.h" header file. First, it tries to locate it
# in the system include directories. Second, it looks in the "include"
# subdirectory of both the directory specified by the "java.home" Java
# property and its parent. Finally, if the user specified the
# JAVA_PREFIX variable, it looks in the "$JAVA_PREFIX/include"
# directory.
AC_DEFUN([FLTT_PROG_JAVAH],
         [AC_REQUIRE([AC_CANONICAL_HOST])[]dnl
AC_REQUIRE([FLTT_PROG_JAVA])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_javah_test],
          [dnl
# public class Conftest {
#     public native int somefun(int n);
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\14\12\0\3\0\11\7\0\12\7\0\13\1\0\6\74" >Conftest.class
printf "init\76\1\0\3\50\51V\1\0\4Code\1\0\7somefun\1\0\4\50I\51I\14\0\4" >>Conftest.class
printf "\0\5\1\0\10Conftest\1\0\20java\57lang\57Object\0\41\0\2\0\3\0\0\0" >>Conftest.class
printf "\0\0\2\0\1\0\4\0\5\0\1\0\6\0\0\0\21\0\1\0\1\0\0\0\5\52\267\0\1\261" >>Conftest.class
printf "\0\0\0\0\1\1\0\7\0\10\0\0\0\0" >>Conftest.class
AS_IF([$ac_path_JAVAH Conftest >/dev/null 2>&1 &&
       test -f Conftest.h],
      [ac_cv_path_JAVAH="$ac_path_JAVAH" ac_path_JAVAH_found=:],
      [AS_ECHO(["$as_me: javah test failed"]) >&AS_MESSAGE_LOG_FD])
rm -f Conftest.class Conftest.h])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java C header and stub file generator],
                      [ac_cv_path_JAVAH],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVAH], [javah],
                                                   [fltt_javah_test],
                                                   [ac_cv_path_JAVAH=no])])],
      [AC_CACHE_CHECK([for the Java C header and stub file generator],
                      [ac_cv_path_JAVAH],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVAH], [javah],
                                                   [fltt_javah_test],
                                                   [ac_cv_path_JAVAH=no],
                                                   ["$JAVA_PREFIX/bin"])])])
m4_undefine([fltt_javah_test])dnl
AS_IF([test "x$ac_cv_path_JAVAH" != xno],
      [JAVAH="$ac_cv_path_JAVAH"])
AC_SUBST([JAVAH])[]dnl
AC_ARG_VAR([JAVAH], [Java C header and stub file generator])[]dnl
dnl Check for jni.h's location
AC_CACHE_CHECK([for javah C preprocessor flags],
               [fltt_cv_prog_javah_cppflags],
               [fltt_cv_prog_javah_cppflags=no
AS_IF([test "x$JAVAH" = x],
      [AS_ECHO(["$as_me: cannot locate jni.h:"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["  a working Java C header generator is required"]) >&AS_MESSAGE_LOG_FD],
      [fltt_save_CPPFLAGS="$CPPFLAGS"
AS_CASE([$host_os],
        [cygwin*|mingw*], [fltt_os="win32 -D__int64=int64_t"],
        [fltt_os=`expr "X$host_os" : 'X\(@<:@^0-9-@:>@*\).*'`])
dnl First try: check for a "system" jni.h
AC_COMPILE_IFELSE([AC_LANG_SOURCE([@%:@include <jni.h>])],
                  [fltt_cv_prog_javah_cppflags=""],
                  [AS_ECHO(["$as_me: could not find a (working) system jni.h"]) >&AS_MESSAGE_LOG_FD])
dnl Second try: ask the JVM where its home directory is and look there
AS_IF([test "x$fltt_cv_prog_javah_cppflags" = xno],
      [AS_IF([test "x$JAVA" = x],
             [AS_ECHO(["$as_me: jni.h test failed:"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["  a working Java application launcher is required"]) >&AS_MESSAGE_LOG_FD],
             [dnl
# public class Conftest {
#     public static void main(String[] arg) {
#         System.out.print(System.getProperty("java.home"));
#     }
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\36\12\0\7\0\15\11\0\16\0\17\10\0\20\12" >Conftest.class
printf "\0\16\0\21\12\0\22\0\23\7\0\24\7\0\25\1\0\6\74init\76\1\0\3\50\51" >>Conftest.class
printf "V\1\0\4Code\1\0\4main\1\0\26\50\133Ljava\57lang\57String\73\51V\14" >>Conftest.class
printf "\0\10\0\11\7\0\26\14\0\27\0\30\1\0\11java\56home\14\0\31\0\32\7\0" >>Conftest.class
printf "\33\14\0\34\0\35\1\0\10Conftest\1\0\20java\57lang\57Object\1\0\20" >>Conftest.class
printf "java\57lang\57System\1\0\3out\1\0\25Ljava\57io\57PrintStream\73\1" >>Conftest.class
printf "\0\13getProperty\1\0\46\50Ljava\57lang\57String\73\51Ljava\57lan" >>Conftest.class
printf "g\57String\73\1\0\23java\57io\57PrintStream\1\0\5print\1\0\25\50" >>Conftest.class
printf "Ljava\57lang\57String\73\51V\0\41\0\6\0\7\0\0\0\0\0\2\0\1\0\10\0" >>Conftest.class
printf "\11\0\1\0\12\0\0\0\21\0\1\0\1\0\0\0\5\52\267\0\1\261\0\0\0\0\0\11" >>Conftest.class
printf "\0\13\0\14\0\1\0\12\0\0\0\30\0\2\0\1\0\0\0\14\262\0\2\22\3\270\0" >>Conftest.class
printf "\4\266\0\5\261\0\0\0\0\0\0" >>Conftest.class
fltt_javahome=`$JAVA Conftest 2>/dev/null`
rm -f Conftest.class
AS_IF([test "x$fltt_javahome" != x],
      [AS_IF([test -d "$fltt_javahome/include"],
             [CPPFLAGS="$fltt_save_CPPFLAGS -I$fltt_javahome/include -I$fltt_javahome/include/$fltt_os"
AC_COMPILE_IFELSE([AC_LANG_SOURCE([@%:@include <jni.h>])],
                  [fltt_cv_prog_javah_cppflags="-I$fltt_javahome/include -I$fltt_javahome/include/$fltt_os"],
                  [AS_ECHO(["$as_me: could not find (a working) jni.h in $fltt_javahome/include"]) >&AS_MESSAGE_LOG_FD])])
AS_IF([test "x$fltt_cv_prog_javah_cppflags" = xno],
      [fltt_javahome2=`AS_DIRNAME(["$fltt_javahome"])`
AS_IF([test -d "$fltt_javahome2/include"],
      [CPPFLAGS="$fltt_save_CPPFLAGS -I$fltt_javahome2/include -I$fltt_javahome2/include/$fltt_os"
AC_COMPILE_IFELSE([AC_LANG_SOURCE([@%:@include <jni.h>])],
                  [fltt_cv_prog_javah_cppflags="-I$fltt_javahome2/include -I$fltt_javahome2/include/$fltt_os"],
                  [AS_ECHO(["$as_me: could not find (a working) jni.h in $fltt_javahome2/include"]) >&AS_MESSAGE_LOG_FD])])])],
      [AS_ECHO(["$as_me: failed to retrieve the java.home property"]) >&AS_MESSAGE_LOG_FD])])])
dnl Third try: look in under JAVA_PREFIX, if provided
AS_IF([test "x$fltt_cv_prog_javah_cppflags" = xno && test "x$JAVA_PREFIX" != x &&
       test "$fltt_javahome/include" != "$JAVA_PREFIX/include" &&
       test "$fltt_javahome2/include" != "$JAVA_PREFIX/include" &&
       test -d "$JAVA_PREFIX/include"],
      [CPPFLAGS="$fltt_save_CPPFLAGS -I$JAVA_PREFIX/include -I$JAVA_PREFIX/include/$fltt_os"
AC_COMPILE_IFELSE([AC_LANG_SOURCE([@%:@include <jni.h>])],
                  [fltt_cv_prog_javah_cppflags="-I$JAVA_PREFIX/include -I$JAVA_PREFIX/include/$fltt_os"],
                  [AS_ECHO(["$as_me: could not find (a working) jni.h in: $JAVA_PREFIX/include"]) >&AS_MESSAGE_LOG_FD])])
CPPFLAGS="$fltt_save_CPPFLAGS"])])
AS_IF([test "x$fltt_cv_prog_javah_cppflags" != xno],
      [JAVAH_CPPFLAGS="$fltt_cv_prog_javah_cppflags"])
AC_SUBST([JAVAH_CPPFLAGS])[]dnl
])# FLTT_PROG_JAVAH
