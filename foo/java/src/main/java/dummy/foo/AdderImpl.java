/*
 * make4java - A Makefile for Java projects
 *
 * Written in 2014 by Francesco Lattanzio <franz.lattanzio@gmail.com>
 *
 * To the extent possible under law, the author have dedicated all
 * copyright and related and neighboring rights to this software to
 * the public domain worldwide. This software is distributed without
 * any warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software.
 * If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

package dummy.foo;

import dummy.bar.Adder;


public class AdderImpl implements Adder {
    private static final String LIB_NAME = "foo-linux";

    static {
        Runtime.getRuntime().loadLibrary(LIB_NAME);
    }


    public AdderImpl() {
    }

    public native int add(int a, int b);

    public native int subtract(int a, int b);
}
