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

import java.io.InputStream;

import java.util.AbstractMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Vector;


public final class Tester {
    private Properties props;


    private Tester() {
        props = new Properties();
        InputStream in = Tester.class.getResourceAsStream("test_suite.properties");
        if (in == null)
            throw new Error("Missing test_suite.properties");
        try {
            props.load(in);
            in.close();
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new Error("Cannot load test_suite.properties");
        }
    }

    private String banner() {
        StringBuilder sb = new StringBuilder();
        sb.append("Foo Tester ver. ");
        sb.append(props.getProperty("version"));
        sb.append(" (");
        sb.append(props.getProperty("name"));
        sb.append(" release ");
        sb.append(props.getProperty("release"));
        sb.append(")\n");
        sb.append("Compiled against foo-");
        sb.append(props.getProperty("foo.version"));
        sb.append('\n');
        return sb.toString();
    }

    private String[] getParameters(int i, String[] names) {
        Vector<String> values = new Vector<String>(names.length);
        for (int j = 0; j < names.length; ++j) {
            String pname = String.format("test.%d.%s", i, names[j]);
            values.add(props.getProperty(pname));
        }
        return values.toArray(new String[0]);
    }

    private void printSuccess(int i) {
        System.out.println("\u001B[1mTest #" + i + ": \u001B[32msuccess\u001B[0m");
    }

    private void printFailed(int i, List<Map.Entry<String, String>> info) {
        System.out.println("\u001B[1mTest #" + i + ": \u001B[31mfailed\u001B[0m");
        if (info == null)
            return;
        Iterator<Map.Entry<String, String>> j = info.iterator();
        while (j.hasNext()) {
            Map.Entry<String, String> pv = j.next();
            System.out.println("  " + pv.getKey() + ": " + pv.getValue());
        }
    }

    private void printUnexpectedException(int i, List<Map.Entry<String, String>> info) {
        System.out.println("\u001B[1mTest #" + i + ": \u001B[31munexpected exception\u001B[0m");
        Iterator<Map.Entry<String, String>> j = info.iterator();
        while (j.hasNext()) {
            Map.Entry<String, String> pv = j.next();
            System.out.println("  " + pv.getKey() + ": " + pv.getValue());
        }
    }

    private void printUnknownType(int i, String type) {
        System.out.println("\u001B[1mTest #" + i + ": \u001B[35munknown type\u001B[0m");
        System.out.println("  type: " + type);
    }

    private String[] doTestAdditionParameters = {
        "a",
        "b",
        "result"
    };

    private void doTestAddition(int i, String[] params) {
        String a = params[0];
        String b = params[1];
        String result = params[2];
        try {
            dummy.bar.Adder adder = new dummy.foo.AdderImpl();
            int aa = Integer.parseInt(a);
            int bb = Integer.parseInt(b);
            int exResult = Integer.parseInt(result);
            int acResult = adder.add(aa, bb);
            if (exResult == acResult) {
                printSuccess(i);
            } else {
                List<Map.Entry<String, String>> info =
                    new LinkedList<Map.Entry<String, String>>();
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("              a", a));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("              b", b));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("expected result", result));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("  actual result", Integer.toString(acResult)));
                printFailed(i, info);
            }
        } catch (Throwable ex) {
            List<Map.Entry<String, String>> info =
                new LinkedList<Map.Entry<String, String>>();
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("        a", a));
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("        b", b));
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("exception", ex.toString()));
            printUnexpectedException(i, info);
            ex.printStackTrace();
        }
    }

    private String[] doTestSubtractionParameters = {
        "a",
        "b",
        "result"
    };

    private void doTestSubtraction(int i, String[] params) {
        String a = params[0];
        String b = params[1];
        String result = params[2];
        try {
            dummy.bar.Adder adder = new dummy.foo.AdderImpl();
            int aa = Integer.parseInt(a);
            int bb = Integer.parseInt(b);
            int exResult = Integer.parseInt(result);
            int acResult = adder.subtract(aa, bb);
            if (exResult == acResult) {
                printSuccess(i);
            } else {
                List<Map.Entry<String, String>> info =
                    new LinkedList<Map.Entry<String, String>>();
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("              a", a));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("              b", b));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("expected result", result));
                info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                         ("  actual result", Integer.toString(acResult)));
                printFailed(i, info);
            }
        } catch (Throwable ex) {
            List<Map.Entry<String, String>> info =
                new LinkedList<Map.Entry<String, String>>();
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("        a", a));
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("        b", b));
            info.add(new AbstractMap.SimpleImmutableEntry<String, String>
                     ("exception", ex.toString()));
            printUnexpectedException(i, info);
            ex.printStackTrace();
        }
    }

    private void doTestAll() {
        int i;
        for (i = 1;; ++i) {
            String pname = String.format("test.%d.type", i);
            String pvalue = props.getProperty(pname);
            if (pvalue == null)
                break;
            if (pvalue.equalsIgnoreCase("add")) {
                doTestAddition(i, getParameters(i, doTestAdditionParameters));
            } else if (pvalue.equalsIgnoreCase("subtract")) {
                doTestSubtraction(i, getParameters(i, doTestSubtractionParameters));
            } else {
                printUnknownType(i, pvalue);
            }
        }
        if (i == 0)
            System.err.println("No tests found!");
    }


    public static void main(String[] args) {
        Tester main = new Tester();
        System.out.print(main.banner());
        System.out.println();
        main.doTestAll();
    }
}
