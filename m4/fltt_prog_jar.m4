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

# FLTT_PROG_JAR
# -------------
# Locate the Java archiver and verify that it is working. We cannot just
# locate it as some OS makes use of wrapper scripts which may fail to
# work under several circumstances.
AC_DEFUN([FLTT_PROG_JAR],
         [AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_jar_test],
          [[cat >conftest.txt <<EOF
Some random text.
EOF]
AS_IF([$ac_path_JAR cf conftest.jar conftest.txt >/dev/null 2>&1 &&
       test -f conftest.jar],
      [ac_cv_path_JAR=$ac_path_JAR ac_path_JAR_found=:])
rm -f conftest.jar conftest.txt])dnl
AS_IF([test "x$JAVA_PREFIX" = x],
      [AC_CACHE_CHECK([for the Java archive tool],
                      [ac_cv_path_JAR],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAR], [jar],
                                                   [fltt_jar_test],
                                                   [ac_cv_path_JAR=no])])],
      [AC_CACHE_CHECK([for the Java archive tool],
                      [ac_cv_path_JAR],
                      [AC_PATH_PROGS_FEATURE_CHECK([JAR], [jar],
                                                   [fltt_jar_test],
                                                   [ac_cv_path_JAR=no],
                                                   [$JAVA_PREFIX/bin])])])
m4_undefine([fltt_jar_test])dnl
AS_IF([test "x$ac_cv_path_JAR" != xno],
      [JAR=$ac_cv_path_JAR])
AC_SUBST([JAR])[]dnl
AC_ARG_VAR([JAR], [Java archiver tool])dnl
])# FLTT_PROG_JAR
