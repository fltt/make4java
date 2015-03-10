/*
 * make4java - A Makefile for Java projects
 *
 * Written in 2015 by Francesco Lattanzio <franz.lattanzio@gmail.com>
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

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Properties;


public class Main {
    private Properties props;


    private Properties loadProperties() {
        props = new Properties();
        try {
            InputStream in = Main.class.getResourceAsStream("random.properties");
            props.load(in);
            in.close();
        } catch (Exception e) {
            throw new Error("Missing random.properties");
        }
        return props;
    }

    private Main() {
        props = loadProperties();
    }


    public String banner() {
        StringBuilder sb = new StringBuilder();
        sb.append(props.get("vendor"));
        sb.append("'s ");
        sb.append(props.get("name"));
        sb.append(" ver. ");
        sb.append(props.get("version"));
        sb.append(" (");
        sb.append(props.get("package"));
        sb.append('-');
        sb.append(props.get("release"));
        sb.append(')');
        return sb.toString();
    }

    public void doSomething() {
        int l;
        byte[] buffer;
        File tmpjar = null;
        String foojarname = "jars/foo-" + props.get("foo.version") + ".jar";
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        System.out.println("Loading foo feature version " + props.get("foo.version") + " ...");
        try {
            tmpjar = File.createTempFile("foo-", ".jar");
            OutputStream os = new FileOutputStream(tmpjar);
            InputStream is = cl.getResourceAsStream(foojarname);
            if (is == null)
                throw new IOException(foojarname + " not found");
            buffer = new byte[8192];
            while ((l = is.read(buffer)) >= 0) {
                os.write(buffer, 0, l);
            }
            is.close();
            os.flush();
            os.close();

            URL[] foojar = new URL[1];
            foojar[0] = tmpjar.toURI().toURL();
            ClassLoader ncl = URLClassLoader.newInstance(foojar, cl);

            Adder adder = (Adder)ncl.loadClass("dummy.foo.AdderImpl").newInstance();
            System.out.println("1 + 2 = " + adder.add(1, 2));
            System.out.println("1 - 2 = " + adder.subtract(1, 2));
        } catch (UnsatisfiedLinkError ex) {
            System.out.println("Sorry, foo feature not available.");
        } catch (Exception ex) {
            System.err.println(ex.toString());
        } finally {
            if ((tmpjar != null) && (!tmpjar.delete()))
                System.err.println("Cannot delete temp file: " + tmpjar.toString());
        }
    }

    public static void main(String[] args) {
        Main main = new Main();

        System.out.println(main.banner());
        System.out.println("It does nothing, but does it very well.");
        System.out.println();

        main.doSomething();
    }
}
