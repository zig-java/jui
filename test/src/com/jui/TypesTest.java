package com.jui;

public class TypesTest {

    public interface Interface {}

    public static abstract class Abstract {
        public Abstract() {}
    }

    public boolean booleanValue;
    public byte byteValue;
    public char charValue;
    public short shortValue;
    public int intValue;
    public long longValue;
    public float floatValue;
    public double doubleValue;
    public Object objectValue;

    public static boolean staticBooleanValue;
    public static byte staticByteValue;
    public static char staticCharValue;
    public static short staticShortValue;
    public static int staticIntValue;
    public static long staticLongValue;
    public static float staticFloatValue;
    public static double staticDoubleValue;
    public static Object staticObjectValue;

    public TypesTest() {
    }

    public TypesTest(boolean value) {
        booleanValue = value;
    }

    public TypesTest(byte value) {
        byteValue = value;
    }

    public TypesTest(char value) {
        charValue = value;
    }

    public TypesTest(short value) {
        shortValue = value;
    }

    public TypesTest(int value) {
        intValue = value;
    }

    public TypesTest(long value) {
        longValue = value;
    }

    public TypesTest(float value) {
        floatValue = value;
    }

    public TypesTest(double value) {
        doubleValue = value;
    }

    public TypesTest(Object value) {
        objectValue = value;
    }

    public void initialize(boolean z, byte b, char c, short s, int i, long j, float f, double d, Object l) {
        booleanValue = z;
        byteValue = b;
        charValue = c;
        shortValue = s;
        intValue = i;
        longValue = j;
        floatValue = f;
        doubleValue = d;
        objectValue = l;
    }

    public boolean getBooleanValue() {
        return booleanValue;
    }

    public byte getByteValue() {
        return byteValue;
    }

    public char getCharValue() {
        return charValue;
    }

    public short getShortValue() {
        return shortValue;
    }

    public int getIntValue() {
        return intValue;
    }

    public long getLongValue() {
        return longValue;
    }

    public float getFloatValue() {
        return floatValue;
    }

    public double getDoubleValue() {
        return doubleValue;
    }

    public Object getObjectValue() {
        return objectValue;
    }

    public static void staticInitialize(boolean z, byte b, char c, short s, int i, long j, float f, double d,
            Object l) {
        staticBooleanValue = z;
        staticByteValue = b;
        staticCharValue = c;
        staticShortValue = s;
        staticIntValue = i;
        staticLongValue = j;
        staticFloatValue = f;
        staticDoubleValue = d;
        staticObjectValue = l;
    }

    public static boolean getStaticBooleanValue() {
        return staticBooleanValue;
    }

    public static byte getStaticByteValue() {
        return staticByteValue;
    }

    public static char getStaticCharValue() {
        return staticCharValue;
    }

    public static short getStaticShortValue() {
        return staticShortValue;
    }

    public static int getStaticIntValue() {
        return staticIntValue;
    }

    public static long getStaticLongValue() {
        return staticLongValue;
    }

    public static float getStaticFloatValue() {
        return staticFloatValue;
    }

    public static double getStaticDoubleValue() {
        return staticDoubleValue;
    }

    public static Object getStaticObjectValue() {
        return staticObjectValue;
    }

    public void Fail() throws Exception {
        throw new Exception("FAILED FROM JAVA");
    }
}