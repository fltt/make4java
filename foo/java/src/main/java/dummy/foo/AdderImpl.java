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
