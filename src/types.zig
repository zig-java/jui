//! Some JVM types, specifically jbyte, jint, and jlong are machine-dependent
//! This file contains those definitions and others

const std = @import("std");

/// Stolen from https://github.com/ziglang/zig/pull/6272
pub const va_list = switch (std.builtin.target.cpu.arch) {
    .aarch64 => switch (std.builtin.target.os.tag) {
        .windows => [*c]u8,
        .ios, .macosx, .tvos, .watchos => [*c]u8,
        else => [1]extern struct {
            __stack: *c_void,
            __gr_top: *c_void,
            __vr_top: *c_void,
            __gr_offs: c_int,
            __vr_offs: c_int,
        },
    },
    .sparc, .wasm32, .wasm64 => *c_void,
    .powerpc => switch (std.builtin.target.os.tag) {
        .ios, .macosx, .tvos, .watchos, .aix => [*c]u8,
        else => [1]extern struct {
            gpr: u8,
            fpr: u8,
            reserved: u16,
            overflow_arg_area: *c_void,
            reg_save_area: *c_void,
        },
    },
    .s390x => [1]extern struct {
        __gpr: c_long,
        __fpr: c_long,
        __overflow_arg_area: *c_void,
        __reg_save_area: *c_void,
    },
    .i386 => [*c]u8,
    .x86_64 => switch (std.builtin.target.os.tag) {
        .windows => [*c]u8,
        else => [1]extern struct {
            gp_offset: c_uint,
            fp_offset: c_uint,
            overflow_arg_area: *c_void,
            reg_save_area: *c_void,
        },
    },
    else => @compileError("va_list not supported for this target yet"),
};

const os = std.builtin.target.os.tag;
const cpu_bit_count = std.builtin.target.cpu.arch.ptrBitWidth();

// TODO: Add support for every other missing os / architecture
// I haven't found a place that contains `jni_md.h`s for every
// possible os-arch combo, it seems we'll have to install Java
// sources for every combo and manually extract the file

// pub const JNICALL: std.builtin.CallingConvention = .Stdcall;
pub const JNICALL: std.builtin.CallingConvention = .C;

pub const jint = switch (os) {
    .windows => c_long,
    else => @compileError("Not supported bidoof"),
};

pub const jlong = switch (os) {
    .windows => i64,
    else => @compileError("Not supported bidoof"),
};

pub const jbyte = switch (os) {
    .windows => i8,
    else => @compileError("Not supported bidoof"),
};

pub const jboolean = u8;
pub const jchar = c_ushort;
pub const jshort = c_short;
pub const jfloat = f32;
pub const jdouble = f64;

pub const jsize = jint;

pub const jobject = ?*opaque {};

pub const jclass = jobject;
pub const jthrowable = jobject;
pub const jstring = jobject;
pub const jarray = jobject;

pub const jbooleanArray = jarray;
pub const jbyteArray = jarray;
pub const jcharArray = jarray;
pub const jshortArray = jarray;
pub const jintArray = jarray;
pub const jlongArray = jarray;
pub const jfloatArray = jarray;
pub const jdoubleArray = jarray;
pub const jobjectArray = jarray;

pub const jweak = jobject;

pub const jvalue = extern union {
    z: jboolean,
    b: jbyte,
    c: jchar,
    s: jshort,
    i: jint,
    j: jlong,
    f: jfloat,
    d: jdouble,
    l: jobject,
};

pub const jfieldID = ?*opaque {};
pub const jmethodID = ?*opaque {};

pub const jobjectRefType = enum {
    invalidRefType,
    localRefType,
    globalRefType,
    weakGlobalRefType,
};

pub const jni_false: jboolean = 0;
pub const jni_true: jboolean = 1;

/// Errors are negative jints; 0 indicates success
pub const JNIError = error{
    /// Unknown error; value of -1
    Unknown,
    /// Thread detached from the VM; value of -2
    ThreadDetached,
    /// JNI version error; value of -3
    BadVersion,
    /// Not enough memory; value of -4
    OutOfMemory,
    /// VM already created; value of -5
    VMAlreadyExists,
    /// Invalid arguments; value of -6
    InvalidArguments,
};

/// Returned when a userland exception occurs
pub const ExceptionError = error{
    Exception,
};

pub const JNINativeMethod = extern struct {
    name: [*c]u8,
    signature: [*c]u8,
    fnPtr: ?*c_void,
};

const JNINativeInterface = extern struct {
    reserved0: ?*c_void,
    reserved1: ?*c_void,
    reserved2: ?*c_void,
    reserved3: ?*c_void,

    GetVersion: fn ([*c]JNIEnv) callconv(JNICALL) jint,
    DefineClass: fn ([*c]JNIEnv, [*c]const u8, jobject, [*c]const jbyte, jsize) callconv(JNICALL) jclass,
    FindClass: fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) jclass,
    FromReflectedMethod: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jmethodID,
    FromReflectedField: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jfieldID,
    ToReflectedMethod: fn ([*c]JNIEnv, jclass, jmethodID, jboolean) callconv(JNICALL) jobject,
    GetSuperclass: fn ([*c]JNIEnv, jclass) callconv(JNICALL) jclass,
    IsAssignableFrom: fn ([*c]JNIEnv, jclass, jclass) callconv(JNICALL) jboolean,
    ToReflectedField: fn ([*c]JNIEnv, jclass, jfieldID, jboolean) callconv(JNICALL) jobject,
    Throw: fn ([*c]JNIEnv, jthrowable) callconv(JNICALL) jint,
    ThrowNew: fn ([*c]JNIEnv, jclass, [*c]const u8) callconv(JNICALL) jint,
    ExceptionOccurred: fn ([*c]JNIEnv) callconv(JNICALL) jthrowable,
    ExceptionDescribe: fn ([*c]JNIEnv) callconv(JNICALL) void,
    ExceptionClear: fn ([*c]JNIEnv) callconv(JNICALL) void,
    FatalError: fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) void,
    PushLocalFrame: fn ([*c]JNIEnv, jint) callconv(JNICALL) jint,
    PopLocalFrame: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
    NewGlobalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
    DeleteGlobalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) void,
    DeleteLocalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) void,
    IsSameObject: fn ([*c]JNIEnv, jobject, jobject) callconv(JNICALL) jboolean,
    NewLocalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
    EnsureLocalCapacity: fn ([*c]JNIEnv, jint) callconv(JNICALL) jint,
    AllocObject: fn ([*c]JNIEnv, jclass) callconv(JNICALL) jobject,
    NewObject: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jobject,
    NewObjectV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
    NewObjectA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
    GetObjectClass: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jclass,
    IsInstanceOf: fn ([*c]JNIEnv, jobject, jclass) callconv(JNICALL) jboolean,
    GetMethodID: fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jmethodID,
    CallObjectMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jobject,
    CallObjectMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jobject,
    CallObjectMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
    CallBooleanMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jboolean,
    CallBooleanMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jboolean,
    CallBooleanMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
    CallByteMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jbyte,
    CallByteMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jbyte,
    CallByteMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
    CallCharMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jchar,
    CallCharMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jchar,
    CallCharMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
    CallShortMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jshort,
    CallShortMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jshort,
    CallShortMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
    CallIntMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jint,
    CallIntMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jint,
    CallIntMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
    CallLongMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jlong,
    CallLongMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jlong,
    CallLongMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
    CallFloatMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jfloat,
    CallFloatMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jfloat,
    CallFloatMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
    CallDoubleMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jdouble,
    CallDoubleMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jdouble,
    CallDoubleMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
    CallVoidMethod: fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) void,
    CallVoidMethodV: fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) void,
    CallVoidMethodA: fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
    CallNonvirtualObjectMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jobject,
    CallNonvirtualObjectMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
    CallNonvirtualObjectMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
    CallNonvirtualBooleanMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jboolean,
    CallNonvirtualBooleanMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jboolean,
    CallNonvirtualBooleanMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
    CallNonvirtualByteMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jbyte,
    CallNonvirtualByteMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jbyte,
    CallNonvirtualByteMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
    CallNonvirtualCharMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jchar,
    CallNonvirtualCharMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jchar,
    CallNonvirtualCharMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
    CallNonvirtualShortMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jshort,
    CallNonvirtualShortMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jshort,
    CallNonvirtualShortMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
    CallNonvirtualIntMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jint,
    CallNonvirtualIntMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jint,
    CallNonvirtualIntMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
    CallNonvirtualLongMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jlong,
    CallNonvirtualLongMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jlong,
    CallNonvirtualLongMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
    CallNonvirtualFloatMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jfloat,
    CallNonvirtualFloatMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jfloat,
    CallNonvirtualFloatMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
    CallNonvirtualDoubleMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jdouble,
    CallNonvirtualDoubleMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jdouble,
    CallNonvirtualDoubleMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
    CallNonvirtualVoidMethod: fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) void,
    CallNonvirtualVoidMethodV: fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) void,
    CallNonvirtualVoidMethodA: fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
    GetFieldID: fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jfieldID,
    GetObjectField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jobject,
    GetBooleanField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jboolean,
    GetByteField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jbyte,
    GetCharField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jchar,
    GetShortField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jshort,
    GetIntField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jint,
    GetLongField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jlong,
    GetFloatField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jfloat,
    GetDoubleField: fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jdouble,
    SetObjectField: fn ([*c]JNIEnv, jobject, jfieldID, jobject) callconv(JNICALL) void,
    SetBooleanField: fn ([*c]JNIEnv, jobject, jfieldID, jboolean) callconv(JNICALL) void,
    SetByteField: fn ([*c]JNIEnv, jobject, jfieldID, jbyte) callconv(JNICALL) void,
    SetCharField: fn ([*c]JNIEnv, jobject, jfieldID, jchar) callconv(JNICALL) void,
    SetShortField: fn ([*c]JNIEnv, jobject, jfieldID, jshort) callconv(JNICALL) void,
    SetIntField: fn ([*c]JNIEnv, jobject, jfieldID, jint) callconv(JNICALL) void,
    SetLongField: fn ([*c]JNIEnv, jobject, jfieldID, jlong) callconv(JNICALL) void,
    SetFloatField: fn ([*c]JNIEnv, jobject, jfieldID, jfloat) callconv(JNICALL) void,
    SetDoubleField: fn ([*c]JNIEnv, jobject, jfieldID, jdouble) callconv(JNICALL) void,
    GetStaticMethodID: fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jmethodID,
    CallStaticObjectMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jobject,
    CallStaticObjectMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
    CallStaticObjectMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
    CallStaticBooleanMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jboolean,
    CallStaticBooleanMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jboolean,
    CallStaticBooleanMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
    CallStaticByteMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jbyte,
    CallStaticByteMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jbyte,
    CallStaticByteMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
    CallStaticCharMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jchar,
    CallStaticCharMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jchar,
    CallStaticCharMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
    CallStaticShortMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jshort,
    CallStaticShortMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jshort,
    CallStaticShortMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
    CallStaticIntMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jint,
    CallStaticIntMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jint,
    CallStaticIntMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
    CallStaticLongMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jlong,
    CallStaticLongMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jlong,
    CallStaticLongMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
    CallStaticFloatMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jfloat,
    CallStaticFloatMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jfloat,
    CallStaticFloatMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
    CallStaticDoubleMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jdouble,
    CallStaticDoubleMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jdouble,
    CallStaticDoubleMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
    CallStaticVoidMethod: fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) void,
    CallStaticVoidMethodV: fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) void,
    CallStaticVoidMethodA: fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
    GetStaticFieldID: fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jfieldID,
    GetStaticObjectField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jobject,
    GetStaticBooleanField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jboolean,
    GetStaticByteField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jbyte,
    GetStaticCharField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jchar,
    GetStaticShortField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jshort,
    GetStaticIntField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jint,
    GetStaticLongField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jlong,
    GetStaticFloatField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jfloat,
    GetStaticDoubleField: fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jdouble,
    SetStaticObjectField: fn ([*c]JNIEnv, jclass, jfieldID, jobject) callconv(JNICALL) void,
    SetStaticBooleanField: fn ([*c]JNIEnv, jclass, jfieldID, jboolean) callconv(JNICALL) void,
    SetStaticByteField: fn ([*c]JNIEnv, jclass, jfieldID, jbyte) callconv(JNICALL) void,
    SetStaticCharField: fn ([*c]JNIEnv, jclass, jfieldID, jchar) callconv(JNICALL) void,
    SetStaticShortField: fn ([*c]JNIEnv, jclass, jfieldID, jshort) callconv(JNICALL) void,
    SetStaticIntField: fn ([*c]JNIEnv, jclass, jfieldID, jint) callconv(JNICALL) void,
    SetStaticLongField: fn ([*c]JNIEnv, jclass, jfieldID, jlong) callconv(JNICALL) void,
    SetStaticFloatField: fn ([*c]JNIEnv, jclass, jfieldID, jfloat) callconv(JNICALL) void,
    SetStaticDoubleField: fn ([*c]JNIEnv, jclass, jfieldID, jdouble) callconv(JNICALL) void,
    NewString: fn ([*c]JNIEnv, [*c]const jchar, jsize) callconv(JNICALL) jstring,
    GetStringLength: fn ([*c]JNIEnv, jstring) callconv(JNICALL) jsize,
    GetStringChars: fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const jchar,
    ReleaseStringChars: fn ([*c]JNIEnv, jstring, [*c]const jchar) callconv(JNICALL) void,
    NewStringUTF: fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) jstring,
    GetStringUTFLength: fn ([*c]JNIEnv, jstring) callconv(JNICALL) jsize,
    GetStringUTFChars: fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const u8,
    ReleaseStringUTFChars: fn ([*c]JNIEnv, jstring, [*c]const u8) callconv(JNICALL) void,
    GetArrayLength: fn ([*c]JNIEnv, jarray) callconv(JNICALL) jsize,
    NewObjectArray: fn ([*c]JNIEnv, jsize, jclass, jobject) callconv(JNICALL) jobjectArray,
    GetObjectArrayElement: fn ([*c]JNIEnv, jobjectArray, jsize) callconv(JNICALL) jobject,
    SetObjectArrayElement: fn ([*c]JNIEnv, jobjectArray, jsize, jobject) callconv(JNICALL) void,
    NewBooleanArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jbooleanArray,
    NewByteArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jbyteArray,
    NewCharArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jcharArray,
    NewShortArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jshortArray,
    NewIntArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jintArray,
    NewLongArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jlongArray,
    NewFloatArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jfloatArray,
    NewDoubleArray: fn ([*c]JNIEnv, jsize) callconv(JNICALL) jdoubleArray,
    GetBooleanArrayElements: fn ([*c]JNIEnv, jbooleanArray, [*c]jboolean) callconv(JNICALL) [*c]jboolean,
    GetByteArrayElements: fn ([*c]JNIEnv, jbyteArray, [*c]jboolean) callconv(JNICALL) [*c]jbyte,
    GetCharArrayElements: fn ([*c]JNIEnv, jcharArray, [*c]jboolean) callconv(JNICALL) [*c]jchar,
    GetShortArrayElements: fn ([*c]JNIEnv, jshortArray, [*c]jboolean) callconv(JNICALL) [*c]jshort,
    GetIntArrayElements: fn ([*c]JNIEnv, jintArray, [*c]jboolean) callconv(JNICALL) [*c]jint,
    GetLongArrayElements: fn ([*c]JNIEnv, jlongArray, [*c]jboolean) callconv(JNICALL) [*c]jlong,
    GetFloatArrayElements: fn ([*c]JNIEnv, jfloatArray, [*c]jboolean) callconv(JNICALL) [*c]jfloat,
    GetDoubleArrayElements: fn ([*c]JNIEnv, jdoubleArray, [*c]jboolean) callconv(JNICALL) [*c]jdouble,
    ReleaseBooleanArrayElements: fn ([*c]JNIEnv, jbooleanArray, [*c]jboolean, jint) callconv(JNICALL) void,
    ReleaseByteArrayElements: fn ([*c]JNIEnv, jbyteArray, [*c]jbyte, jint) callconv(JNICALL) void,
    ReleaseCharArrayElements: fn ([*c]JNIEnv, jcharArray, [*c]jchar, jint) callconv(JNICALL) void,
    ReleaseShortArrayElements: fn ([*c]JNIEnv, jshortArray, [*c]jshort, jint) callconv(JNICALL) void,
    ReleaseIntArrayElements: fn ([*c]JNIEnv, jintArray, [*c]jint, jint) callconv(JNICALL) void,
    ReleaseLongArrayElements: fn ([*c]JNIEnv, jlongArray, [*c]jlong, jint) callconv(JNICALL) void,
    ReleaseFloatArrayElements: fn ([*c]JNIEnv, jfloatArray, [*c]jfloat, jint) callconv(JNICALL) void,
    ReleaseDoubleArrayElements: fn ([*c]JNIEnv, jdoubleArray, [*c]jdouble, jint) callconv(JNICALL) void,
    GetBooleanArrayRegion: fn ([*c]JNIEnv, jbooleanArray, jsize, jsize, [*c]jboolean) callconv(JNICALL) void,
    GetByteArrayRegion: fn ([*c]JNIEnv, jbyteArray, jsize, jsize, [*c]jbyte) callconv(JNICALL) void,
    GetCharArrayRegion: fn ([*c]JNIEnv, jcharArray, jsize, jsize, [*c]jchar) callconv(JNICALL) void,
    GetShortArrayRegion: fn ([*c]JNIEnv, jshortArray, jsize, jsize, [*c]jshort) callconv(JNICALL) void,
    GetIntArrayRegion: fn ([*c]JNIEnv, jintArray, jsize, jsize, [*c]jint) callconv(JNICALL) void,
    GetLongArrayRegion: fn ([*c]JNIEnv, jlongArray, jsize, jsize, [*c]jlong) callconv(JNICALL) void,
    GetFloatArrayRegion: fn ([*c]JNIEnv, jfloatArray, jsize, jsize, [*c]jfloat) callconv(JNICALL) void,
    GetDoubleArrayRegion: fn ([*c]JNIEnv, jdoubleArray, jsize, jsize, [*c]jdouble) callconv(JNICALL) void,
    SetBooleanArrayRegion: fn ([*c]JNIEnv, jbooleanArray, jsize, jsize, [*c]const jboolean) callconv(JNICALL) void,
    SetByteArrayRegion: fn ([*c]JNIEnv, jbyteArray, jsize, jsize, [*c]const jbyte) callconv(JNICALL) void,
    SetCharArrayRegion: fn ([*c]JNIEnv, jcharArray, jsize, jsize, [*c]const jchar) callconv(JNICALL) void,
    SetShortArrayRegion: fn ([*c]JNIEnv, jshortArray, jsize, jsize, [*c]const jshort) callconv(JNICALL) void,
    SetIntArrayRegion: fn ([*c]JNIEnv, jintArray, jsize, jsize, [*c]const jint) callconv(JNICALL) void,
    SetLongArrayRegion: fn ([*c]JNIEnv, jlongArray, jsize, jsize, [*c]const jlong) callconv(JNICALL) void,
    SetFloatArrayRegion: fn ([*c]JNIEnv, jfloatArray, jsize, jsize, [*c]const jfloat) callconv(JNICALL) void,
    SetDoubleArrayRegion: fn ([*c]JNIEnv, jdoubleArray, jsize, jsize, [*c]const jdouble) callconv(JNICALL) void,
    RegisterNatives: fn ([*c]JNIEnv, jclass, [*c]const JNINativeMethod, jint) callconv(JNICALL) jint,
    UnregisterNatives: fn ([*c]JNIEnv, jclass) callconv(JNICALL) jint,
    MonitorEnter: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jint,
    MonitorExit: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jint,
    GetJavaVM: fn ([*c]JNIEnv, [*c][*c]JavaVM) callconv(JNICALL) jint,
    GetStringRegion: fn ([*c]JNIEnv, jstring, jsize, jsize, [*c]jchar) callconv(JNICALL) void,
    GetStringUTFRegion: fn ([*c]JNIEnv, jstring, jsize, jsize, [*c]u8) callconv(JNICALL) void,
    GetPrimitiveArrayCritical: fn ([*c]JNIEnv, jarray, [*c]jboolean) callconv(JNICALL) ?*c_void,
    ReleasePrimitiveArrayCritical: fn ([*c]JNIEnv, jarray, ?*c_void, jint) callconv(JNICALL) void,
    GetStringCritical: fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const jchar,
    ReleaseStringCritical: fn ([*c]JNIEnv, jstring, [*c]const jchar) callconv(JNICALL) void,
    NewWeakGlobalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jweak,
    DeleteWeakGlobalRef: fn ([*c]JNIEnv, jweak) callconv(JNICALL) void,
    ExceptionCheck: fn ([*c]JNIEnv) callconv(JNICALL) jboolean,
    NewDirectByteBuffer: fn ([*c]JNIEnv, ?*c_void, jlong) callconv(JNICALL) jobject,
    GetDirectBufferAddress: fn ([*c]JNIEnv, jobject) callconv(JNICALL) ?*c_void,
    GetDirectBufferCapacity: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jlong,
    GetObjectRefType: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobjectRefType,
    GetModule: fn ([*c]JNIEnv, jclass) callconv(JNICALL) jobject,
};

const JNIInvokeInterface = extern struct {
    reserved0: ?*c_void,
    reserved1: ?*c_void,
    reserved2: ?*c_void,

    DestroyJavaVM: fn ([*c]JavaVM) callconv(JNICALL) jint,
    AttachCurrentThread: fn ([*c]JavaVM, [*c]?*c_void, ?*c_void) callconv(JNICALL) jint,
    DetachCurrentThread: fn ([*c]JavaVM) callconv(JNICALL) jint,
    GetEnv: fn ([*c]JavaVM, [*c]?*c_void, jint) callconv(JNICALL) jint,
    AttachCurrentThreadAsDaemon: fn ([*c]JavaVM, [*c]?*c_void, ?*c_void) callconv(JNICALL) jint,
};

fn handleError(return_val: jint) JNIError!void {
    if (return_val < 0 and return_val >= -6) {
        inline for (comptime std.meta.fields(JNIError)) |err, i| {
            if (i == -return_val - 1)
                return @field(JNIError, err.name);
        }
    }
}

pub const JNIEnv = extern struct {
    const Self = @This();

    interface: *const JNINativeInterface,

    pub const JNIVersion = struct {
        minor: u16,
        major: u16,
    };

    /// Gets the JNI version (not the Java version!)
    pub fn getJNIVersion(self: *Self) JNIError!JNIVersion {
        var version = self.interface.GetVersion(self);
        try handleError(version);

        return @bitCast(JNIVersion, version);
    }

    /// Takes a ClassLoader and buffer containing a classfile
    /// Buffer can be discarded after use
    /// The name is always null as it is a redudant argument
    pub fn defineClass(self: *Self, loader: jobject, buf: []const u8) ExceptionError!jclass {
        var maybe_class = self.interface.DefineClass(self, null, loader, @ptrCast([*c]const jbyte, buf), @intCast(jsize, buf.len));
        if (maybe_class) |class| {
            return class;
        } else {
            return ExceptionError.Exception;
        }
    }

    pub fn newStringUTF(self: *Self, buf: [*c]const u8) jstring {
        return self.interface.NewStringUTF(self, buf);
    }

    pub fn findClass(self: *Self, name: [*c]const u8) jclass {
        return self.interface.FindClass(self, name);
    }

    pub fn throwNew(self: *Self, class: jclass, message: [*c]const u8) !void {
        try handleError(self.interface.ThrowNew(self, class, message));
    }

    pub fn throwGeneric(self: *Self, message: [*c]const u8) !void {
        var class = self.findClass("java/lang/Exception");
        return self.throwNew(class, message);
    }
};

pub const JavaVM = extern struct {
    const Self = @This();

    interface: *const JNIInvokeInterface,

    pub fn destroyJavaVM() !void {}
};
