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

# FLTT_PROG_JDEPS
# ---------------
# Locate the Java class dependency analyzer and verify that it works.
# We cannot just locate it as some OS makes use of wrapper scripts which
# may fail to work under several circumstances.
AC_DEFUN([FLTT_PROG_JDEPS],
         [AC_REQUIRE([AC_PROG_SED])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_jdeps_test],
          [dnl
# public class Conftest1 {
#     public int value() {
#         return 1;
#     }
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\14\12\0\3\0\11\7\0\12\7\0\13\1\0\6\74" >Conftest1.class
printf "init\76\1\0\3\50\51V\1\0\4Code\1\0\5value\1\0\3\50\51I\14\0\4\0\5" >>Conftest1.class
printf "\1\0\11Conftest1\1\0\20java\57lang\57Object\0\41\0\2\0\3\0\0\0\0" >>Conftest1.class
printf "\0\2\0\1\0\4\0\5\0\1\0\6\0\0\0\21\0\1\0\1\0\0\0\5\52\267\0\1\261" >>Conftest1.class
printf "\0\0\0\0\0\1\0\7\0\10\0\1\0\6\0\0\0\16\0\1\0\1\0\0\0\2\4\254\0\0" >>Conftest1.class
printf "\0\0\0\0" >>Conftest1.class
# public class Conftest2 extends Conftest1 {
#     public int value() {
#         return 2;
#     }
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\14\12\0\3\0\11\7\0\12\7\0\13\1\0\6\74" >Conftest2.class
printf "init\76\1\0\3\50\51V\1\0\4Code\1\0\5value\1\0\3\50\51I\14\0\4\0\5" >>Conftest2.class
printf "\1\0\11Conftest2\1\0\11Conftest1\0\41\0\2\0\3\0\0\0\0\0\2\0\1\0\4" >>Conftest2.class
printf "\0\5\0\1\0\6\0\0\0\21\0\1\0\1\0\0\0\5\52\267\0\1\261\0\0\0\0\0\1" >>Conftest2.class
printf "\0\7\0\10\0\1\0\6\0\0\0\16\0\1\0\1\0\0\0\2\5\254\0\0\0\0\0\0" >>Conftest2.class
fltt_jdepsout=`$ac_path_JDEPS -v Conftest1.class Conftest2.class 2>/dev/null | $SED -n '/^  *Conftest2 *-> *Conftest1 *.*$/p'`
AS_IF([test "x$fltt_jdepsout" != x],
      [ac_cv_path_JDEPS="$ac_path_JDEPS" ac_path_JDEPS_found=:],
      [AS_ECHO(["$as_me: jdeps test failed"]) >&AS_MESSAGE_LOG_FD])
rm -f Conftest1.class Conftest2.class])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java class dependency analyzer],
                      [ac_cv_path_JDEPS],
                      [AC_PATH_PROGS_FEATURE_CHECK([JDEPS], [jdeps],
                                                   [fltt_jdeps_test],
                                                   [ac_cv_path_JDEPS=no])])],
      [AC_CACHE_CHECK([for the Java class dependency analyzer],
                      [ac_cv_path_JDEPS],
                      [AC_PATH_PROGS_FEATURE_CHECK([JDEPS], [jdeps],
                                                   [fltt_jdeps_test],
                                                   [ac_cv_path_JDEPS=no],
                                                   ["$JAVA_PREFIX/bin"])])])
m4_undefine([fltt_jdeps_test])dnl
AS_IF([test "x$ac_cv_path_JDEPS" != xno],
      [JDEPS="$ac_cv_path_JDEPS"])
AC_SUBST([JDEPS])[]dnl
AC_ARG_VAR([JDEPS], [Java class dependency analyzer])dnl
])# FLTT_PROG_JDEPS
