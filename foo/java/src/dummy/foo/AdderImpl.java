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

package dummy.foo;

import dummy.bar.Adder;

import java.io.InputStream;
import java.util.Properties;


/**
 * An implementation of the sample {@link dummy.bar.Adder} interface.
 *
 * @since 1.0.0
 */
public class AdderImpl implements Adder {
    static {
        InputStream in = AdderImpl.class.getResourceAsStream("properties");
        if (in == null)
            throw new Error("Missing properties");
        Properties p = new Properties();
        try {
            p.load(in);
            System.loadLibrary(p.getProperty("native.libname"));
            in.close();
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Error("Cannot load properties");
        }
    }


    /**
     * Default constructor.
     *
     * @since 1.0.0
     */
    public AdderImpl() {
    }

    /**
     * Sums two integers.
     *
     * @param a the first addend
     * @param b the second addend
     * @return the result
     *
     * @since 1.0.0
     */
    public native int add(int a, int b);

    /**
     * Subtracts two integers.
     *
     * @param a the minuend
     * @param b the subtrahend
     * @return the result
     *
     * @since 1.0.0
     */
    public native int subtract(int a, int b);
}
