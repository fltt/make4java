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

# FLTT_PROG_JAVADOC
# -----------------
# Locate the Java API documentation generator and verify that it is
# working. We cannot just locate it as some OS makes use of wrapper
# scripts which may fail to work under several circumstances.
AC_DEFUN([FLTT_PROG_JAVADOC],
         [AC_REQUIRE([AC_PROG_SED])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_javadoc_test],
          [[cat >Conftest.java <<EOF
public class Conftest {
}
EOF]
AS_IF([$ac_path_JAVADOC -d conftest Conftest.java >/dev/null 2>&1 &&
       test -f conftest/Conftest.html],
      [ac_cv_path_JAVADOC="$ac_path_JAVADOC" ac_path_JAVADOC_found=:],
      [AS_ECHO(["$as_me: failed program was:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest.java >&AS_MESSAGE_LOG_FD])
rm -rf Conftest.java conftest])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java API documentation generator],
                      [ac_cv_path_JAVADOC],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVADOC], [javadoc],
                                                   [fltt_javadoc_test],
                                                   [ac_cv_path_JAVADOC=no])])],
      [AC_CACHE_CHECK([for the Java API documentation generator],
                      [ac_cv_path_JAVADOC],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVADOC], [javadoc],
                                                   [fltt_javadoc_test],
                                                   [ac_cv_path_JAVADOC=no],
                                                   ["$JAVA_PREFIX/bin"])])])
m4_undefine([fltt_javadoc_test])dnl
AS_IF([test "x$ac_cv_path_JAVADOC" != xno],
      [JAVADOC="$ac_cv_path_JAVADOC"])
AC_SUBST([JAVADOC])[]dnl
AC_ARG_VAR([JAVADOC], [Java API documentation generator])dnl
])# FLTT_PROG_JAVADOC
