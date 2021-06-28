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

pub const NativeType = enum {
    object,
    boolean,
    byte,
    char,
    short,
    int,
    long,
    float,
    double,
};

pub fn MapNativeType(comptime native_type: NativeType) type {
    return switch (native_type) {
        .object => jobject,
        .boolean => jboolean,
        .byte => jbyte,
        .char => jchar,
        .short => jshort,
        .int => jint,
        .long => jlong,
        .float => jfloat,
        .double => jdouble,
    };
}

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

    pub fn toJValue(value: anytype) jvalue {
        return switch (@TypeOf(value)) {
            jboolean => .{ .z = value },
            jbyte => .{ .b = value },
            jchar => .{ .c = value },
            jshort => .{ .s = value },
            jint => .{ .i = value },
            jlong => .{ .j = value },
            jfloat => .{ .f = value },
            jdouble => .{ .d = value },
            jobject => .{ .l = value },
            else => @compileError("invalid value!"),
        };
    }
};

pub const jfieldID = ?*opaque {};
pub const jmethodID = ?*opaque {};

pub const ObjectReferenceKind = enum(c_int) {
    /// The reference is invalid (gced, null)
    invalid,
    /// The reference is local and will not exist in the future
    local,
    /// The reference is global and is guaranteed to exist in the future
    global,
    /// The reference is a weak global and is guaranteed to exist in the future, but its underlying object is not
    weak_global,
    /// Since references are typically implemented as pointers once deleted it is not specified what value GetObjectReferenceKind will return.
    _,
};

// The new error handling model for jui is simple:
// 1. Handle known errors/exceptions mentioned in the JNI as Zig errors
// 2. Handle userland or unknown errors/exceptions separately

/// Errors are negative jints; 0 indicates success
pub const JNIFailureError = error{
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
    GetObjectReferenceKind: fn ([*c]JNIEnv, jobject) callconv(JNICALL) ObjectReferenceKind,
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

fn handleFailureError(return_val: jint) JNIFailureError!void {
    if (return_val < 0 and return_val >= -6) {
        inline for (comptime std.meta.fields(JNIFailureError)) |err, i| {
            if (i == -return_val - 1)
                return @field(JNIFailureError, err.name);
        }
    }

    if (return_val < 0) return JNIFailureError.Unknown;
}

pub const JNIVersion = packed struct {
    minor: u16,
    major: u16,
};

pub const JNIEnv = extern struct {
    const Self = @This();

    interface: *const JNINativeInterface,

    // Utils

    pub fn getClassNameOfObject(self: *Self, obj: jobject) jstring {
        var cls = self.getObjectClass(obj);

        // First get the class object
        var mid = self.interface.GetMethodID(self, cls, "getClass", "()Ljava/lang/Class;");
        var clsObj = self.interface.CallObjectMethod(self, obj, mid);

        // Now get the class object's class descriptor
        cls = self.getObjectClass(clsObj);

        // Find the getName() method on the class object
        mid = self.interface.GetMethodID(self, cls, "getName", "()Ljava/lang/String;");

        // Call the getName() to get a jstring object back
        var strObj = self.interface.CallObjectMethod(self, clsObj, mid);
        return strObj;
    }

    /// Handles a known error
    /// Only use this if you're 100% sure an error/exception has occurred
    fn handleKnownError(self: *Self, comptime Set: type) Set {
        var throwable = self.getPendingException();

        var name_str = self.getClassNameOfObject(throwable);

        var name = self.interface.GetStringUTFChars(self, name_str, null);
        defer self.interface.ReleaseStringUTFChars(self, name_str, name);

        var n = std.mem.span(@ptrCast([*:0]const u8, name));
        var eon = n[std.mem.lastIndexOf(u8, n, ".").? + 1 ..];

        var x = std.hash.Wyhash.hash(0, eon);

        inline for (comptime std.meta.fields(Set)) |err| {
            var z = std.hash.Wyhash.hash(0, err.name);
            if (x == z) {
                self.clearPendingException();
                return @field(Set, err.name);
            }
        }

        const first = comptime std.meta.fields(Set)[0];
        return @field(Set, first.name);
    }

    // Version Information

    /// Gets the JNI version (not the Java version!)
    pub fn getJNIVersion(self: *Self) JNIVersion {
        var version = self.interface.GetVersion(self);
        return @bitCast(JNIVersion, version);
    }

    // Class Operations

    pub const DefineClassError = error{
        /// The class data does not specify a valid class
        ClassFormatError,
        /// A class or interface would be its own superclass or superinterface
        ClassCircularityError,
        OutOfMemoryError,
        /// The caller attempts to define a class in the "java" package tree
        SecurityException,
    };

    /// Takes a ClassLoader and buffer containing a classfile
    /// Buffer can be discarded after use
    /// The name is always null as it is a redudant argument
    pub fn defineClass(self: *Self, loader: jobject, buf: []const u8) DefineClassError!jclass {
        var maybe_class = self.interface.DefineClass(self, null, loader, @ptrCast([*c]const jbyte, buf), @intCast(jsize, buf.len));
        return if (maybe_class) |class|
            class
        else
            return self.handleKnownError(DefineClassError);
    }

    pub const FindClassError = error{
        /// The class data does not specify a valid class
        ClassFormatError,
        /// A class or interface would be its own superclass or superinterface
        ClassCircularityError,
        /// No definition for a requested class or interface can be found
        NoClassDefFoundError,
        OutOfMemoryError,
    };

    /// This function loads a locally-defined class
    pub fn findClass(self: *Self, name: [*:0]const u8) FindClassError!jclass {
        var maybe_class = self.interface.FindClass(self, name);
        return if (maybe_class) |class|
            class
        else
            return self.handleKnownError(FindClassError);
    }

    /// Gets superclass of class
    /// If class specifies the class Object, or class represents an interface, this function returns null
    pub fn getSuperclass(self: *Self, class: jclass) jclass {
        return self.interface.GetSuperclass(self, class);
    }

    /// Determines whether an object of class1 can be safely cast to class2
    pub fn canBeCastTo(self: *Self, class1: jclass, class2: jclass) bool {
        return self.interface.IsAssignableFrom(class1, class2) == 1;
    }

    // Module Operations

    /// Returns the java.lang.Module object for the module that the class is a member of
    /// If the class is not in a named module then the unnamed module of the class loader for the class is returned
    /// If the class represents an array type then this function returns the Module object for the element type
    /// If the class represents a primitive type or void, then the Module object for the java.base module is returned
    pub fn getModule(self: *Self, class: jclass) jobject {
        return self.interface.GetModule(self, class);
    }

    // Exceptions

    /// Causes a java.lang.Throwable object to be thrown
    pub fn throw(self: *Self, throwable: jthrowable) JNIFailureError!void {
        try handleFailureError(self.interface.Throw(self, throwable));
    }

    /// Constructs an exception object from the specified class with the message specified by message and causes that exception to be thrown
    pub fn throwNew(self: *Self, class: jclass, message: [*:0]const u8) JNIFailureError!void {
        try handleFailureError(self.interface.ThrowNew(self, class, message));
    }

    /// Throws a generic java.lang.Excpetion with the specified message
    pub fn throwGeneric(self: *Self, message: [*:0]const u8) !void {
        var class = try self.findClass("java/lang/Exception");
        return self.throwNew(class, message);
    }

    /// Gets the exception object that is currently in the process of being thrown
    pub fn getPendingException(self: *Self) jthrowable {
        return self.interface.ExceptionOccurred(self);
    }

    /// Prints an exception and a backtrace of the stack to a system error-reporting channel, such as stderr
    pub fn describeException(self: *Self) void {
        self.interface.ExceptionDescribe(self);
    }

    /// Clears any exception that is currently being thrown
    pub fn clearPendingException(self: *Self) void {
        self.interface.ExceptionClear(self);
    }

    /// Raises a fatal error and does not expect the VM to recover
    pub fn fatalError(self: *Self, message: [*:0]const u8) noreturn {
        self.interface.FatalError(self, message);
    }

    /// Determines if an exception is being thrown
    pub fn hasPendingException(self: *Self) bool {
        return self.interface.ExceptionCheck(self) == 1;
    }

    // References

    pub const NewReferenceError = error{
        /// Errors/exceptions returned by New*Ref are super ambigious so sadly this is the best solution :(
        ReferenceError,
    };

    /// Create a new reference based on an existing reference
    pub fn newReference(self: *Self, kind: ObjectReferenceKind, reference: jobject) NewReferenceError!jobject {
        var maybe_reference = switch (kind) {
            .global => self.interface.NewGlobalRef(self, reference),
            .local => self.interface.NewLocalRef(self, reference),
            .weak_global => self.interface.NewWeakGlobalRef(self, reference),
            else => unreachable,
        };

        if (maybe_reference) |new_reference| {
            return new_reference;
        } else {
            self.clearPendingException();
            return error.ReferenceError;
        }
    }

    /// Deletes a reference
    pub fn deleteReference(self: *Self, kind: ObjectReferenceKind, reference: jobject) void {
        switch (kind) {
            .global => self.interface.DeleteGlobalRef(self, reference),
            .local => self.interface.DeleteLocalRef(self, reference),
            .weak_global => self.interface.DeleteWeakGlobalRef(self, reference),
            else => unreachable,
        }
    }

    /// Ensures that at least a given number of local references can be created in the current thread
    pub fn ensureLocalCapacity(self: *Self, capacity: jint) JNIFailureError!void {
        std.debug.assert(capacity >= 0);
        return handleFailureError(self.interface.EnsureLocalCapacity(self, capacity));
    }

    /// Creates a new local reference frame, in which at least a given number of local references can be created
    /// Useful for not polluting the thread frame
    /// Think of it like an ArenaAllocator for your native function
    pub fn pushLocalFrame(self: *Self, capacity: jint) JNIFailureError!void {
        std.debug.assert(capacity > 0);
        return handleFailureError(self.interface.PushLocalFrame(self, capacity));
    }

    /// Pops a local frame
    /// Result is an object you want to pass back to the previous frame
    /// If you don't want to pass anything back, it can be null
    pub fn popLocalFrame(self: *Self, result: jobject) jobject {
        return self.interface.PopLocalFrame(self, result);
    }

    // Object Operations

    pub const AllocObjectError = error{
        /// The class is an interface or an abstract class
        InstantiationException,
        OutOfMemoryError,
    };

    /// Allocates a new Java object without invoking any of the constructors for the object, then returns a reference to the object
    /// NOTE: Objects created with this function are not eligible for finalization
    pub fn allocObject(self: *Self, class: jclass) AllocObjectError!jobject {
        var maybe_object = self.interface.AllocObject(self, class);
        return if (maybe_object) |object|
            object
        else
            return self.handleKnownError(AllocObjectError);
    }

    pub const NewObjectError = error{
        /// Any exception thrown by the constructor
        Exception,
        /// The class is an interface or an abstract class
        InstantiationException,
        OutOfMemoryError,
    };

    /// Constructs a new Java object
    /// The passed method_id must be a constructor, and args must match
    /// Class must not be an array (see newArray!)
    pub fn newObject(self: *Self, class: jclass, method_id: jmethodID, args: ?[*]const jvalue) NewObjectError!jobject {
        var maybe_object = self.interface.NewObjectA(self, class, method_id, args);
        return if (maybe_object) |object|
            object
        else
            return self.handleKnownError(NewObjectError);
    }

    /// Returns the class of an object
    pub fn getObjectClass(self: *Self, object: jobject) jclass {
        std.debug.assert(object != null);
        return self.interface.GetObjectClass(self, object);
    }

    /// Returns the type of an reference, see ObjectReferenceKind for details
    pub fn getObjectReferenceKind(self: *Self, object: jobject) ObjectReferenceKind {
        return self.interface.GetObjectReferenceKind(self, object);
    }

    /// Tests whether an object is an instance of a class
    pub fn isInstanceOf(self: *Self, object: jobject, class: jclass) bool {
        return self.interface.IsInstanceOf(self, object, class) == 1;
    }

    /// Tests whether two references refer to the same Java object
    /// NOTE: This is **not** `.equals`, it's `==` - we're comparing references, not values!
    pub fn isSameObject(self: *Self, object1: jobject, object2: jobject) bool {
        return self.interface.IsSameObject(self, object1, object2) == 1;
    }

    // Accessing Fields of Objects

    pub const GetFieldIdError = error{
        /// The specified field cannot be found
        NoSuchFieldError,
        /// The class initializer fails due to an exception
        ExceptionInInitializerError,
        OutOfMemoryError,
    };

    /// Returns the field ID for an instance (nonstatic) field of a class; the field is specified by its name and signature
    pub fn getFieldId(self: *Self, class: jclass, name: [*:0]const u8, signature: [*:0]const u8) GetFieldIdError!jfieldID {
        var maybe_jfieldid = self.interface.GetFieldID(self, class, name, signature);
        return if (maybe_jfieldid) |object|
            object
        else
            return self.handleKnownError(GetFieldIdError);
    }

    /// Gets the value of a field
    pub fn getField(self: *Self, comptime native_type: NativeType, object: jobject, field_id: jfieldID) MapNativeType(native_type) {
        return (switch (native_type) {
            .object => self.interface.GetObjectField,
            .boolean => self.interface.GetBooleanField,
            .byte => self.interface.GetByteField,
            .char => self.interface.GetCharField,
            .short => self.interface.GetShortField,
            .int => self.interface.GetIntField,
            .long => self.interface.GetLongField,
            .float => self.interface.GetFloatField,
            .double => self.interface.GetDoubleField,
        })(self, object, field_id);
    }

    /// Sets the value of a field
    pub fn setField(self: *Self, comptime native_type: NativeType, object: jobject, field_id: jobject, value: MapNativeType(native_type)) void {
        (switch (native_type) {
            .object => self.interface.SetObjectField,
            .boolean => self.interface.SetBooleanField,
            .byte => self.interface.SetByteField,
            .char => self.interface.SetCharField,
            .short => self.interface.SetShortField,
            .int => self.interface.SetIntField,
            .long => self.interface.SetLongField,
            .float => self.interface.SetFloatField,
            .double => self.interface.SetDoubleField,
        })(self, object, field_id, value);
    }

    // Calling Instance Methods

    pub const GetMethodIdError = error{
        /// The specified method cannot be found
        NoSuchMethodError,
        /// The class initializer fails due to an exception
        ExceptionInInitializerError,
        OutOfMemoryError,
    };

    /// Returns the method ID for an instance (nonstatic) method of a class or interface
    pub fn getMethodId(self: *Self, class: jclass, name: [*:0]const u8, signature: [*:0]const u8) GetMethodIdError!jmethodID {
        var maybe_jmethodid = self.interface.GetMethodID(self, class, name, signature);
        return if (maybe_jmethodid) |object|
            object
        else
            return self.handleKnownError(GetMethodIdError);
    }

    pub const CallMethodError = error{Exception};

    /// Invoke an instance (nonstatic) method on a Java object
    pub fn callMethod(self: *Self, comptime native_type: NativeType, object: jobject, method_id: jmethodID, args: ?[*]const jvalue) CallMethodError!MapNativeType(native_type) {
        var value = (switch (native_type) {
            .object => self.interface.CallObjectMethodA,
            .boolean => self.interface.CallBooleanMethodA,
            .byte => self.interface.CallByteMethodA,
            .char => self.interface.CallCharMethodA,
            .short => self.interface.CallShortMethodA,
            .int => self.interface.CallIntMethodA,
            .long => self.interface.CallLongMethodA,
            .float => self.interface.CallFloatMethodA,
            .double => self.interface.CallDoubleMethodA,
        })(self, object, method_id, args);

        return if (self.hasPendingException()) error.Exception else value;
    }

    pub const CallNonVirtualMethodError = error{Exception};

    /// Invoke an instance (nonstatic) method on a Java object based on `class`'s implementation of the method
    pub fn callNonVirtualMethod(self: *Self, comptime native_type: NativeType, object: jobject, class: jclass, method_id: jmethodID, args: ?[*]const jvalue) CallNonVirtualMethodError!MapNativeType(native_type) {
        var value = (switch (native_type) {
            .object => self.interface.CallNonvirtualObjectMethodA,
            .boolean => self.interface.CallNonvirtualBooleanMethodA,
            .byte => self.interface.CallNonvirtualByteMethodA,
            .char => self.interface.CallNonvirtualCharMethodA,
            .short => self.interface.CallNonvirtualShortMethodA,
            .int => self.interface.CallNonvirtualIntMethodA,
            .long => self.interface.CallNonvirtualLongMethodA,
            .float => self.interface.CallNonvirtualFloatMethodA,
            .double => self.interface.CallNonvirtualDoubleMethodA,
        })(self, object, class, method_id, args);

        return if (self.hasPendingException()) error.Exception else value;
    }

    // Accessing Static Fields

    pub const GetStaticFieldIdError = error{
        /// The specified field cannot be found
        NoSuchFieldError,
        /// The class initializer fails due to an exception
        ExceptionInInitializerError,
        OutOfMemoryError,
    };

    pub fn getStaticFieldId(self: *Self, class: jclass, name: [*:0]const u8, signature: [*:0]const u8) GetStaticFieldIdError!jfieldID {
        var maybe_jfieldid = self.interface.GetStaticFieldID(self, class, name, signature);
        return if (maybe_jfieldid) |object|
            object
        else
            return self.handleKnownError(GetStaticFieldIdError);
    }

    /// Gets the value of a field
    pub fn getStaticField(self: *Self, comptime native_type: NativeType, class: jclass, field_id: jfieldID) MapNativeType(native_type) {
        return (switch (native_type) {
            .object => self.interface.GetStaticObjectField,
            .boolean => self.interface.GetStaticBooleanField,
            .byte => self.interface.GetStaticByteField,
            .char => self.interface.GetStaticCharField,
            .short => self.interface.GetStaticShortField,
            .int => self.interface.GetStaticIntField,
            .long => self.interface.GetStaticLongField,
            .float => self.interface.GetStaticFloatField,
            .double => self.interface.GetStaticDoubleField,
        })(self, class, field_id);
    }

    /// Sets the value of a field
    pub fn setStaticField(self: *Self, comptime native_type: NativeType, class: jclass, field_id: jobject, value: MapNativeType(native_type)) void {
        (switch (native_type) {
            .object => self.interface.SetStaticObjectField,
            .boolean => self.interface.SetStaticBooleanField,
            .byte => self.interface.SetStaticByteField,
            .char => self.interface.SetStaticCharField,
            .short => self.interface.SetStaticShortField,
            .int => self.interface.SetStaticIntField,
            .long => self.interface.SetStaticLongField,
            .float => self.interface.SetStaticFloatField,
            .double => self.interface.SetStaticDoubleField,
        })(self, class, field_id, value);
    }

    // Calling Static Methods

    pub const GetStaticMethodIdError = error{
        /// The specified method cannot be found
        NoSuchMethodError,
        /// The class initializer fails due to an exception
        ExceptionInInitializerError,
        OutOfMemoryError,
    };

    /// Returns the method ID for a static method of a class
    pub fn getStaticMethodId(self: *Self, class: jclass, name: [*:0]const u8, signature: [*:0]const u8) GetStaticMethodIdError!jmethodID {
        var maybe_jmethodid = self.interface.GetStaticMethodID(self, class, name, signature);
        return if (maybe_jmethodid) |object|
            object
        else
            return self.handleKnownError(GetStaticMethodIdError);
    }

    pub const CallStaticMethodError = error{Exception};

    /// Invoke an instance (nonstatic) method on a Java object
    pub fn callStaticMethod(self: *Self, comptime native_type: NativeType, class: jclass, method_id: jmethodID, args: ?[*]const jvalue) CallStaticMethodError!MapNativeType(native_type) {
        var value = (switch (native_type) {
            .object => self.interface.CallStaticObjectMethodA,
            .boolean => self.interface.CallStaticBooleanMethodA,
            .byte => self.interface.CallStaticByteMethodA,
            .char => self.interface.CallStaticCharMethodA,
            .short => self.interface.CallStaticShortMethodA,
            .int => self.interface.CallStaticIntMethodA,
            .long => self.interface.CallStaticLongMethodA,
            .float => self.interface.CallStaticFloatMethodA,
            .double => self.interface.CallStaticDoubleMethodA,
        })(self, class, method_id, args);

        return if (self.hasPendingException()) error.Exception else value;
    }

    // String Operations

    pub const NewStringError = error{OutOfMemoryError};

    /// Constructs a new java.lang.String object from an array of Unicode characters
    pub fn newString(self: *Self, unicode_chars: []const u16) NewStringError!jstring {
        var maybe_jstring = self.interface.NewString(self, unicode_chars, unicode_chars.len);
        return if (maybe_jstring) |string|
            string
        else
            return self.handleKnownError(NewStringError);
    }

    /// Returns the length (the count of Unicode characters) of a Java string
    pub fn getStringLength(self: *Self, string: jstring) jsize {
        return self.interface.GetStringLength(self, string);
    }

    pub const GetStringCharsError = error{Unknown};
    pub const GetStringCharsReturn = struct { chars: [*]const u16, is_copy: bool };

    /// Returns a pointer to the array of Unicode characters of the string
    /// Caller must release chars with `releaseStringChars`
    pub fn getStringChars(self: *Self, string: jstring) GetStringCharsError!GetStringCharsReturn {
        var is_copy: u8 = 0;
        var maybe_chars = self.interface.GetStringChars(self, string, &is_copy);
        return if (maybe_chars) |chars|
            GetStringCharsReturn{ .chars = chars, .is_copy = is_copy == 1 }
        else
            error.Unknown;
    }

    /// Informs the VM that the native code no longer needs access to chars
    pub fn releaseStringChars(self: *Self, string: jstring, chars: [*]const u16) void {
        self.interface.ReleaseStringChars(self, string, chars);
    }

    pub const NewStringUTFError = error{OutOfMemoryError};

    /// Constructs a new java.lang.String object from an array of characters in modified UTF-8 encoding
    pub fn newStringUTF(self: *Self, buf: [*:0]const u8) NewStringUTFError!jstring {
        var maybe_jstring = self.interface.NewStringUTF(self, buf);
        return if (maybe_jstring) |string|
            string
        else
            return self.handleKnownError(NewStringUTFError);
    }

    /// Returns the length in bytes of the modified UTF-8 representation of a string
    pub fn getStringUTFLength(self: *Self, string: jstring) jsize {
        return self.interface.GetStringUTFLength(self, string);
    }

    pub const GetStringUTFCharsError = error{Unknown};
    pub const GetStringUTFCharsReturn = struct { chars: [*]const u8, is_copy: bool };

    /// Returns a pointer to an array of bytes representing the string in modified UTF-8 encoding
    /// Caller must release chars with `releaseStringUTFChars`
    pub fn getStringUTFChars(self: *Self, string: jstring) GetStringUTFCharsError!GetStringUTFCharsReturn {
        var is_copy: u8 = 0;
        var maybe_chars = self.interface.GetStringUTFChars(self, string, &is_copy);
        return if (maybe_chars) |chars|
            GetStringUTFCharsReturn{ .chars = chars, .is_copy = is_copy == 1 }
        else
            error.Unknown;
    }

    /// Informs the VM that the native code no longer needs access to chars
    pub fn releaseStringUTFChars(self: *Self, string: jstring, chars: [*]const u8) void {
        self.interface.ReleaseStringUTFChars(self, string, chars);
    }

    pub const GetStringRegionError = error{StringIndexOutOfBoundsException};

    /// Copies len number of Unicode characters beginning at offset start to the given buffer buf
    pub fn getStringRegion(self: *Self, string: jstring, start: jsize, len: jsize, buf: []u16) GetStringRegionError!void {
        var string_length = self.getStringLength(string);
        std.debug.assert(start >= 0 and start < string_length);
        std.debug.assert(len >= 0 and start + len < string_length);

        self.interface.GetStringRegion(self, string, start, len, buf);
        if (self.hasPendingException())
            return error.StringIndexOutOfBoundsException;
    }

    pub const GetStringUTFRegionError = error{StringIndexOutOfBoundsException};

    /// Translates len number of Unicode characters beginning at offset start into modified UTF-8 encoding and place the result in the given buffer buf
    pub fn getStringUTFRegion(self: *Self, string: jstring, start: jsize, len: jsize, buf: []u8) GetStringUTFRegionError!void {
        var string_length = self.getStringUTFLength(string);
        std.debug.assert(start >= 0 and start < string_length);
        std.debug.assert(len >= 0 and start + len < string_length);

        self.interface.GetStringUTFRegion(self, string, start, len, buf);
        if (self.hasPendingException())
            return error.StringIndexOutOfBoundsException;
    }

    pub const GetStringCriticalError = error{Unknown};
    pub const GetStringCriticalReturn = struct { chars: [*]const u16, is_copy: bool };

    /// NOTE: This should only be used in non-blocking, fast-finishing functions
    /// Returns a pointer to an array of bytes representing the string in modified UTF-8 encoding
    /// Caller must release chars with `releaseStringCritical`
    pub fn getStringCritical(self: *Self, string: jstring) GetStringCriticalError!GetStringCriticalReturn {
        var is_copy: u8 = 0;
        var maybe_chars = self.interface.GetStringCritical(self, string, &is_copy);
        return if (maybe_chars) |chars|
            GetStringCriticalReturn{ .chars = chars, .is_copy = is_copy == 1 }
        else
            error.Unknown;
    }

    /// Informs the VM that the native code no longer needs access to chars
    pub fn releaseStringCritical(self: *Self, string: jstring, chars: [*]const u16) void {
        self.interface.ReleaseStringCritical(self, string, chars);
    }

    // Variety Pack
};

pub const JavaVM = extern struct {
    const Self = @This();

    interface: *const JNIInvokeInterface,

    pub fn getEnv(self: *Self, version: JNIVersion) JNIFailureError!*JNIEnv {
        var env: *JNIEnv = undefined;
        try handleFailureError(self.interface.GetEnv(self, @ptrCast([*c]?*c_void, &env), @bitCast(jint, version)));
        return env;
    }
};
