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

# FLTT_PROG_JAVA
# --------------
# Locate the Java application launcher and verify that it works. We
# cannot just locate it as some OS makes use of wrapper scripts which
# may fail to work under several circumstances.
AC_DEFUN([FLTT_PROG_JAVA],
         [AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_java_test],
          [dnl
# public class Conftest {
#     public static void main(String[] args) {
#         System.out.print("It works");
#     }
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\32\12\0\6\0\14\11\0\15\0\16\10\0\17\12" >Conftest.class
printf "\0\20\0\21\7\0\22\7\0\23\1\0\6\74init\76\1\0\3\50\51V\1\0\4Code\1" >>Conftest.class
printf "\0\4main\1\0\26\50\133Ljava\57lang\57String\73\51V\14\0\7\0\10\7" >>Conftest.class
printf "\0\24\14\0\25\0\26\1\0\10It\40works\7\0\27\14\0\30\0\31\1\0\10Co" >>Conftest.class
printf "nftest\1\0\20java\57lang\57Object\1\0\20java\57lang\57System\1\0" >>Conftest.class
printf "\3out\1\0\25Ljava\57io\57PrintStream\73\1\0\23java\57io\57PrintS" >>Conftest.class
printf "tream\1\0\5print\1\0\25\50Ljava\57lang\57String\73\51V\0\41\0\5\0" >>Conftest.class
printf "\6\0\0\0\0\0\2\0\1\0\7\0\10\0\1\0\11\0\0\0\21\0\1\0\1\0\0\0\5\52" >>Conftest.class
printf "\267\0\1\261\0\0\0\0\0\11\0\12\0\13\0\1\0\11\0\0\0\25\0\2\0\1\0\0" >>Conftest.class
printf "\0\11\262\0\2\22\3\266\0\4\261\0\0\0\0\0\0" >>Conftest.class
fltt_javaout=`$ac_path_JAVA Conftest 2>/dev/null`
rm -f Conftest.class
AS_IF([test "x$fltt_javaout" = "xIt works"],
      [ac_cv_path_JAVA="$ac_path_JAVA" ac_path_JAVA_found=:],
      [AS_ECHO(["$as_me: java test failed"]) >&AS_MESSAGE_LOG_FD])])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java application launcher],
                      [ac_cv_path_JAVA],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVA], [java],
                                                   [fltt_java_test],
                                                   [ac_cv_path_JAVA=no])])],
      [AC_CACHE_CHECK([for the Java application launcher],
                      [ac_cv_path_JAVA],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVA], [java],
                                                   [fltt_java_test],
                                                   [ac_cv_path_JAVA=no],
                                                   ["$JAVA_PREFIX/bin"])])])
m4_undefine([fltt_java_test])dnl
AS_IF([test "x$ac_cv_path_JAVA" != xno],
      [JAVA="$ac_cv_path_JAVA"])
AC_SUBST([JAVA])[]dnl
AC_ARG_VAR([JAVA], [Java application launcher])[]dnl
])# FLTT_PROG_JAVA
