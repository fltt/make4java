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
# Locate the Java class dependency analyzer and verify that it is
# working. We cannot just locate it as some OS makes use of wrapper
# scripts which may fail to work under several circumstances.
AC_DEFUN([FLTT_PROG_JDEPS],
         [AC_REQUIRE([AC_PROG_SED])[]dnl
AC_REQUIRE([FLTT_PROG_JAVAC])[]dnl
AC_ARG_VAR([JAVA_PREFIX], [path to the Java home directory])[]dnl
m4_define([fltt_jdeps_test],
          [AS_IF([test ! -f Conftest1.class || test ! -f Conftest2.class],
                 [AS_IF([test "x$JAVAC" = x],
                        [AS_ECHO(["$as_me: jdeps test failed:"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["  cannot proceed without a working Java compiler"]) >&AS_MESSAGE_LOG_FD],
                        [[cat >Conftest1.java <<EOF
public class Conftest1 {
    private int v1 = 1;
    public int value() {
        return v1;
    }
}
EOF
cat >Conftest2.java <<EOF
public class Conftest2 extends Conftest1 {
    private int v2 = 2;
    public int value() {
        return v2;
    }
}
EOF]
AS_IF([$JAVAC Conftest1.java Conftest2.java >/dev/null 2>&1 &&
       test -f Conftest1.class && test -f Conftest2.class], [],
      [AS_ECHO(["$as_me: failed programs were:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest1.java >&AS_MESSAGE_LOG_FD
AS_ECHO(["and:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest2.java >&AS_MESSAGE_LOG_FD])])])
AS_IF([test -f Conftest1.class && test -f Conftest2.class],
      [fltt_jdepsout=`$ac_path_JDEPS -v Conftest1.class Conftest2.class 2>/dev/null | $SED -n '/^  *Conftest2 *-> *Conftest1 *.*$/p'`
AS_IF([test "x$fltt_jdepsout" != x],
       [ac_cv_path_JDEPS=$ac_path_JDEPS ac_path_JDEPS_found=:],
       [AS_ECHO(["$as_me: jdeps test failed:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest1.java >&AS_MESSAGE_LOG_FD
AS_ECHO(["and:"]) >&AS_MESSAGE_LOG_FD
$SED 's/^/| /' Conftest2.java >&AS_MESSAGE_LOG_FD])])])dnl
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
                                                   [$JAVA_PREFIX/bin])])])
m4_undefine([fltt_jdeps_test])dnl
rm -f Conftest1.java Conftest2.java Conftest1.class Conftest2.class
AS_IF([test "x$ac_cv_path_JDEPS" != xno],
      [JDEPS=$ac_cv_path_JDEPS])
AC_SUBST([JDEPS])[]dnl
AC_ARG_VAR([JDEPS], [Java class dependency analyzer])dnl
])# FLTT_PROG_JDEPS
