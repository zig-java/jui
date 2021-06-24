package com.jui;

public final class JNIExample {
    static {
        System.loadLibrary("jni_example");
    }
  
    public static native String greet();

    public static void main(String[] args) {
        System.out.println(greet());
    }
}
