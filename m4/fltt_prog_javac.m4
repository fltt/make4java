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

# FLTT_PROG_JAVAC
# ---------------
# Locate the Java compiler and verify that it works. We cannot just
# locate it as some OS makes use of wrapper scripts which may fail to
# work under several circumstances.
AC_DEFUN([FLTT_PROG_JAVAC],
         [AC_REQUIRE([AC_PROG_SED])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_compilers_list], [javac jikes guavac "gcj -C"])dnl
m4_define([fltt_javac_test],
          [[cat >Conftest.java <<EOF
public class Conftest {
}
EOF]
AS_IF([$ac_path_JAVAC Conftest.java >/dev/null 2>&1 &&
       test -f Conftest.class],
      [ac_cv_path_JAVAC="$ac_path_JAVAC" ac_path_JAVAC_found=:],
      [AS_ECHO(["$as_me: failed program was:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest.java >&AS_MESSAGE_LOG_FD])
rm -f Conftest.java Conftest.class])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java programming language compiler],
                      [ac_cv_path_JAVAC],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVAC],
                                                   [fltt_compilers_list],
                                                   [fltt_javac_test],
                                                   [ac_cv_path_JAVAC=no])])],
      [AC_CACHE_CHECK([for the Java programming language compiler],
                      [ac_cv_path_JAVAC],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAVAC],
                                                   [fltt_compilers_list],
                                                   [fltt_javac_test],
                                                   [ac_cv_path_JAVAC=no],
                                                   ["$JAVA_PREFIX/bin"])])])
m4_undefine([fltt_javac_test])dnl
m4_undefine([fltt_compilers_list])dnl
AS_IF([test "x$ac_cv_path_JAVAC" != xno],
      [JAVAC="$ac_cv_path_JAVAC"])
AC_SUBST([JAVAC])[]dnl
AC_ARG_VAR([JAVAC], [Java programming language compiler])[]dnl
])# FLTT_PROG_JAVAC
