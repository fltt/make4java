/*
 * make4java - A Makefile for Java projects
 *
 * Written in 2016 by Francesco Lattanzio <franz.lattanzio@gmail.com>
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

package dummy.bar;


/**
 * Sample methods to be implemented by the sample {@link dummy.foo}
 * package.
 *
 * @since 1.0.0
 */
public interface Adder {
    /**
     * Sums two integers.
     *
     * @param a the first addend
     * @param b the second addend
     * @return the result
     *
     * @since 1.0.0
     */
    public int add(int a, int b);

    /**
     * Subtracts two integers.
     *
     * @param a the minuend
     * @param b the subtrahend
     * @return the result
     *
     * @since 1.0.0
     */
    public int subtract(int a, int b);
}
