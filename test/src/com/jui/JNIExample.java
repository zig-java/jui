package com.jui;

public final class JNIExample {
    static {
        System.loadLibrary("jni_example");
    }
  
    public static native String greet();

    public static void main(String[] args) {
        try {
            System.out.println(greet());
        } catch (Exception e) {
            System.out.println("Big bad Zig error handled in Java >:(");
            e.printStackTrace();
        }
    }
}
