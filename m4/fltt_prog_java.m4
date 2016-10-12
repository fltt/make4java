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
# Locate the Java application launcher and verify that it is working. We
# cannot just locate it as some OS makes use of wrapper scripts which
# may fail to work under several circumstances.
AC_DEFUN([FLTT_PROG_JAVA],
         [AC_REQUIRE([AC_PROG_SED])[]dnl
AC_REQUIRE([FLTT_PROG_JAVAC])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_java_test],
          [AS_IF([test ! -f Conftest.class],
                 [AS_IF([test "x$JAVAC" = x],
                        [AS_ECHO(["$as_me: java test failed:"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["  cannot proceed without a working Java compiler"]) >&AS_MESSAGE_LOG_FD],
                        [[cat >Conftest.java <<EOF
public class Conftest {
    public static void main(String[] args) {
        System.out.println("It works");
    }
}
EOF]
AS_IF([$JAVAC Conftest.java >/dev/null 2>&1 && test -f Conftest.class], [],
      [AS_ECHO(["$as_me: failed programs were:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest.java >&AS_MESSAGE_LOG_FD])])])
AS_IF([test -f Conftest.class],
      [fltt_javaout=`$ac_path_JAVA Conftest 2>/dev/null`
AS_IF([test "x$fltt_javaout" = "xIt works"],
       [ac_cv_path_JAVA=$ac_path_JAVA ac_path_JAVA_found=:],
       [AS_ECHO(["$as_me: java test failed:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest.java >&AS_MESSAGE_LOG_FD])])])dnl
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
                                                   [$JAVA_PREFIX/bin])])])
m4_undefine([fltt_java_test])dnl
rm -f Conftest.java Conftest.class
AS_IF([test "x$ac_cv_path_JAVA" != xno],
      [JAVA=$ac_cv_path_JAVA])
AC_SUBST([JAVA])[]dnl
AC_ARG_VAR([JAVA], [Java application launcher])dnl
])# FLTT_PROG_JAVA
