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

# FLTT_PROG_JAVA_PATHSEP
# ----------------------
# Determine the path separator used in classpath.
AC_DEFUN([FLTT_PROG_JAVA_PATHSEP],
         [AC_REQUIRE([FLTT_PROG_JAVA])[]dnl
AC_CACHE_CHECK([for Java path separator],
               [fltt_cv_prog_java_pathsep],
               [fltt_cv_prog_java_pathsep=no
AS_IF([test "x$JAVA" = x],
      [AS_ECHO(["$as_me: cannot determine the path separator:"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["  a working Java application launcher is required"]) >&AS_MESSAGE_LOG_FD],
      [dnl
# public class Conftest {
#     public static void main(String[] args) {
#         System.out.print(System.getProperty("path.separator"));
#     }
# }
# The following class file was generated from the above Java source file.
printf "\312\376\272\276\0\0\0002\0\36\12\0\7\0\15\11\0\16\0\17\10\0\20\12" >Conftest.class
printf "\0\16\0\21\12\0\22\0\23\7\0\24\7\0\25\1\0\6\74init\76\1\0\3\50\51" >>Conftest.class
printf "V\1\0\4Code\1\0\4main\1\0\26\50\133Ljava\57lang\57String\73\51V\14" >>Conftest.class
printf "\0\10\0\11\7\0\26\14\0\27\0\30\1\0\16path\56separator\14\0\31\0\32" >>Conftest.class
printf "\7\0\33\14\0\34\0\35\1\0\10Conftest\1\0\20java\57lang\57Object\1" >>Conftest.class
printf "\0\20java\57lang\57System\1\0\3out\1\0\25Ljava\57io\57PrintStrea" >>Conftest.class
printf "m\73\1\0\13getProperty\1\0\46\50Ljava\57lang\57String\73\51Ljava" >>Conftest.class
printf "\57lang\57String\73\1\0\23java\57io\57PrintStream\1\0\5print\1\0" >>Conftest.class
printf "\25\50Ljava\57lang\57String\73\51V\0\41\0\6\0\7\0\0\0\0\0\2\0\1\0" >>Conftest.class
printf "\10\0\11\0\1\0\12\0\0\0\21\0\1\0\1\0\0\0\5\52\267\0\1\261\0\0\0\0" >>Conftest.class
printf "\0\11\0\13\0\14\0\1\0\12\0\0\0\30\0\2\0\1\0\0\0\14\262\0\2\22\3\270" >>Conftest.class
printf "\0\4\266\0\5\261\0\0\0\0\0\0" >>Conftest.class
fltt_java_pathsep=`$JAVA Conftest 2>/dev/null`
rm -f Conftest.class
AS_IF([test "x$fltt_java_pathsep" = x],
      [AS_ECHO(["$as_me: path separator test failed"]) >&AS_MESSAGE_LOG_FD],
      [fltt_cv_prog_java_pathsep="$fltt_java_pathsep"])])])
AS_IF([test "x$fltt_cv_prog_java_pathsep" != xno],
      [JAVA_PATH_SEPARATOR="$fltt_cv_prog_java_pathsep"])
AC_SUBST([JAVA_PATH_SEPARATOR])[]dnl
])# FLTT_PROG_JAVA_PATHSEP
