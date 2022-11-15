//! Some JVM types, specifically jbyte, jint, and jlong are machine-dependent
//! This file contains those definitions and others

const std = @import("std");
const builtin = @import("builtin");

// builtin.zig_backend decl exists
// This code must be removed once the 0.9.1 support is not necessary.
const is_stage2 = @hasDecl(builtin, "zig_backend") and builtin.zig_backend != .stage1;

/// Stolen from https://github.com/ziglang/zig/pull/6272
/// [1]extern struct isn't allowed, see https://github.com/ziglang/zig/issues/6535
pub const va_list = switch (builtin.target.cpu.arch) {
    .aarch64 => switch (builtin.target.os.tag) {
        .windows => [*c]u8,
        .ios, .macos, .tvos, .watchos => [*c]u8,
        else => *extern struct {
            __stack: *anyopaque,
            __gr_top: *anyopaque,
            __vr_top: *anyopaque,
            __gr_offs: c_int,
            __vr_offs: c_int,
        },
    },
    .sparc, .wasm32, .wasm64 => *anyopaque,
    .powerpc => switch (builtin.target.os.tag) {
        .ios, .macos, .tvos, .watchos, .aix => [*c]u8,
        else => *extern struct {
            gpr: u8,
            fpr: u8,
            reserved: u16,
            overflow_arg_area: *anyopaque,
            reg_save_area: *anyopaque,
        },
    },
    .s390x => *extern struct {
        __gpr: c_long,
        __fpr: c_long,
        __overflow_arg_area: *anyopaque,
        __reg_save_area: *anyopaque,
    },
    .i386 => [*c]u8,
    .x86_64 => switch (builtin.target.os.tag) {
        .windows => [*c]u8,
        else => *extern struct {
            gp_offset: c_uint,
            fp_offset: c_uint,
            overflow_arg_area: *anyopaque,
            reg_save_area: *anyopaque,
        },
    },
    else => @compileError("va_list not supported for this target yet"),
};

const os = builtin.target.os.tag;
const cpu_bit_count = builtin.target.cpu.arch.ptrBitWidth();

// TODO: Add support for every other missing os / architecture
// I haven't found a place that contains `jni_md.h`s for every
// possible os-arch combo, it seems we'll have to install Java
// sources for every combo and manually extract the file

// pub const JNICALL: builtin.CallingConvention = .Stdcall;
pub const JNICALL: std.builtin.CallingConvention = .C;

pub const jint = switch (os) {
    .windows => c_long,
    else => c_int,

    // TODO:
    // @compileError("Not supported bidoof"),
};

pub const jlong = switch (os) {
    .windows => i64,
    else => i64,

    // TODO:
    // @compileError("Not supported bidoof"),
};

pub const jbyte = switch (os) {
    .windows => i8,
    else => i8,

    // TODO:
    // @compileError("Not supported bidoof"),
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
    @"void",
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
        .@"void" => void,
    };
}

pub fn MapArrayType(comptime native_type: NativeType) type {
    return switch (native_type) {
        .boolean => jbooleanArray,
        .byte => jbyteArray,
        .char => jcharArray,
        .short => jshortArray,
        .int => jintArray,
        .long => jlongArray,
        .float => jfloatArray,
        .double => jdoubleArray,
        .object => jobjectArray,
        .@"void" => @compileError("Array cannot be of type 'void'"),
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
        if (@typeInfo(@TypeOf(value)) == .Struct and @hasDecl(@TypeOf(value), "toJValue")) return @field(value, "toJValue")();

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
    fnPtr: ?*anyopaque,
};

// Instead of using std.meta.FnPtr for each declaration,
// Just duplicating all structs here, with fn(..) and *const fn
// This way it's easier to just delete when stage1 was removed
const JNINativeInterface = if (is_stage2)
    extern struct {
        reserved0: ?*anyopaque,
        reserved1: ?*anyopaque,
        reserved2: ?*anyopaque,
        reserved3: ?*anyopaque,

        GetVersion: *const fn ([*c]JNIEnv) callconv(JNICALL) jint,
        DefineClass: *const fn ([*c]JNIEnv, [*c]const u8, jobject, [*c]const jbyte, jsize) callconv(JNICALL) jclass,
        FindClass: *const fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) jclass,
        FromReflectedMethod: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jmethodID,
        FromReflectedField: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jfieldID,
        ToReflectedMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, jboolean) callconv(JNICALL) jobject,
        GetSuperclass: *const fn ([*c]JNIEnv, jclass) callconv(JNICALL) jclass,
        IsAssignableFrom: *const fn ([*c]JNIEnv, jclass, jclass) callconv(JNICALL) jboolean,
        ToReflectedField: *const fn ([*c]JNIEnv, jclass, jfieldID, jboolean) callconv(JNICALL) jobject,
        Throw: *const fn ([*c]JNIEnv, jthrowable) callconv(JNICALL) jint,
        ThrowNew: *const fn ([*c]JNIEnv, jclass, [*c]const u8) callconv(JNICALL) jint,
        ExceptionOccurred: *const fn ([*c]JNIEnv) callconv(JNICALL) jthrowable,
        ExceptionDescribe: *const fn ([*c]JNIEnv) callconv(JNICALL) void,
        ExceptionClear: *const fn ([*c]JNIEnv) callconv(JNICALL) void,
        FatalError: *const fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) void,
        PushLocalFrame: *const fn ([*c]JNIEnv, jint) callconv(JNICALL) jint,
        PopLocalFrame: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
        NewGlobalRef: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
        DeleteGlobalRef: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) void,
        DeleteLocalRef: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) void,
        IsSameObject: *const fn ([*c]JNIEnv, jobject, jobject) callconv(JNICALL) jboolean,
        NewLocalRef: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jobject,
        EnsureLocalCapacity: *const fn ([*c]JNIEnv, jint) callconv(JNICALL) jint,
        AllocObject: *const fn ([*c]JNIEnv, jclass) callconv(JNICALL) jobject,
        NewObject: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jobject,
        NewObjectV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
        NewObjectA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
        GetObjectClass: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jclass,
        IsInstanceOf: *const fn ([*c]JNIEnv, jobject, jclass) callconv(JNICALL) jboolean,
        GetMethodID: *const fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jmethodID,
        CallObjectMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jobject,
        CallObjectMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jobject,
        CallObjectMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
        CallBooleanMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jboolean,
        CallBooleanMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jboolean,
        CallBooleanMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
        CallByteMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jbyte,
        CallByteMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jbyte,
        CallByteMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
        CallCharMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jchar,
        CallCharMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jchar,
        CallCharMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
        CallShortMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jshort,
        CallShortMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jshort,
        CallShortMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
        CallIntMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jint,
        CallIntMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jint,
        CallIntMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
        CallLongMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jlong,
        CallLongMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jlong,
        CallLongMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
        CallFloatMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jfloat,
        CallFloatMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jfloat,
        CallFloatMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
        CallDoubleMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) jdouble,
        CallDoubleMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) jdouble,
        CallDoubleMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
        CallVoidMethod: *const fn ([*c]JNIEnv, jobject, jmethodID, ...) callconv(JNICALL) void,
        CallVoidMethodV: *const fn ([*c]JNIEnv, jobject, jmethodID, va_list) callconv(JNICALL) void,
        CallVoidMethodA: *const fn ([*c]JNIEnv, jobject, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
        CallNonvirtualObjectMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jobject,
        CallNonvirtualObjectMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
        CallNonvirtualObjectMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
        CallNonvirtualBooleanMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jboolean,
        CallNonvirtualBooleanMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jboolean,
        CallNonvirtualBooleanMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
        CallNonvirtualByteMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jbyte,
        CallNonvirtualByteMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jbyte,
        CallNonvirtualByteMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
        CallNonvirtualCharMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jchar,
        CallNonvirtualCharMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jchar,
        CallNonvirtualCharMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
        CallNonvirtualShortMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jshort,
        CallNonvirtualShortMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jshort,
        CallNonvirtualShortMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
        CallNonvirtualIntMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jint,
        CallNonvirtualIntMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jint,
        CallNonvirtualIntMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
        CallNonvirtualLongMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jlong,
        CallNonvirtualLongMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jlong,
        CallNonvirtualLongMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
        CallNonvirtualFloatMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jfloat,
        CallNonvirtualFloatMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jfloat,
        CallNonvirtualFloatMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
        CallNonvirtualDoubleMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) jdouble,
        CallNonvirtualDoubleMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) jdouble,
        CallNonvirtualDoubleMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
        CallNonvirtualVoidMethod: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, ...) callconv(JNICALL) void,
        CallNonvirtualVoidMethodV: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, va_list) callconv(JNICALL) void,
        CallNonvirtualVoidMethodA: *const fn ([*c]JNIEnv, jobject, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
        GetFieldID: *const fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jfieldID,
        GetObjectField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jobject,
        GetBooleanField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jboolean,
        GetByteField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jbyte,
        GetCharField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jchar,
        GetShortField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jshort,
        GetIntField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jint,
        GetLongField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jlong,
        GetFloatField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jfloat,
        GetDoubleField: *const fn ([*c]JNIEnv, jobject, jfieldID) callconv(JNICALL) jdouble,
        SetObjectField: *const fn ([*c]JNIEnv, jobject, jfieldID, jobject) callconv(JNICALL) void,
        SetBooleanField: *const fn ([*c]JNIEnv, jobject, jfieldID, jboolean) callconv(JNICALL) void,
        SetByteField: *const fn ([*c]JNIEnv, jobject, jfieldID, jbyte) callconv(JNICALL) void,
        SetCharField: *const fn ([*c]JNIEnv, jobject, jfieldID, jchar) callconv(JNICALL) void,
        SetShortField: *const fn ([*c]JNIEnv, jobject, jfieldID, jshort) callconv(JNICALL) void,
        SetIntField: *const fn ([*c]JNIEnv, jobject, jfieldID, jint) callconv(JNICALL) void,
        SetLongField: *const fn ([*c]JNIEnv, jobject, jfieldID, jlong) callconv(JNICALL) void,
        SetFloatField: *const fn ([*c]JNIEnv, jobject, jfieldID, jfloat) callconv(JNICALL) void,
        SetDoubleField: *const fn ([*c]JNIEnv, jobject, jfieldID, jdouble) callconv(JNICALL) void,
        GetStaticMethodID: *const fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jmethodID,
        CallStaticObjectMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jobject,
        CallStaticObjectMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jobject,
        CallStaticObjectMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jobject,
        CallStaticBooleanMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jboolean,
        CallStaticBooleanMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jboolean,
        CallStaticBooleanMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jboolean,
        CallStaticByteMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jbyte,
        CallStaticByteMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jbyte,
        CallStaticByteMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jbyte,
        CallStaticCharMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jchar,
        CallStaticCharMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jchar,
        CallStaticCharMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jchar,
        CallStaticShortMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jshort,
        CallStaticShortMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jshort,
        CallStaticShortMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jshort,
        CallStaticIntMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jint,
        CallStaticIntMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jint,
        CallStaticIntMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jint,
        CallStaticLongMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jlong,
        CallStaticLongMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jlong,
        CallStaticLongMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jlong,
        CallStaticFloatMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jfloat,
        CallStaticFloatMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jfloat,
        CallStaticFloatMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jfloat,
        CallStaticDoubleMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) jdouble,
        CallStaticDoubleMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) jdouble,
        CallStaticDoubleMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) jdouble,
        CallStaticVoidMethod: *const fn ([*c]JNIEnv, jclass, jmethodID, ...) callconv(JNICALL) void,
        CallStaticVoidMethodV: *const fn ([*c]JNIEnv, jclass, jmethodID, va_list) callconv(JNICALL) void,
        CallStaticVoidMethodA: *const fn ([*c]JNIEnv, jclass, jmethodID, [*c]const jvalue) callconv(JNICALL) void,
        GetStaticFieldID: *const fn ([*c]JNIEnv, jclass, [*c]const u8, [*c]const u8) callconv(JNICALL) jfieldID,
        GetStaticObjectField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jobject,
        GetStaticBooleanField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jboolean,
        GetStaticByteField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jbyte,
        GetStaticCharField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jchar,
        GetStaticShortField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jshort,
        GetStaticIntField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jint,
        GetStaticLongField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jlong,
        GetStaticFloatField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jfloat,
        GetStaticDoubleField: *const fn ([*c]JNIEnv, jclass, jfieldID) callconv(JNICALL) jdouble,
        SetStaticObjectField: *const fn ([*c]JNIEnv, jclass, jfieldID, jobject) callconv(JNICALL) void,
        SetStaticBooleanField: *const fn ([*c]JNIEnv, jclass, jfieldID, jboolean) callconv(JNICALL) void,
        SetStaticByteField: *const fn ([*c]JNIEnv, jclass, jfieldID, jbyte) callconv(JNICALL) void,
        SetStaticCharField: *const fn ([*c]JNIEnv, jclass, jfieldID, jchar) callconv(JNICALL) void,
        SetStaticShortField: *const fn ([*c]JNIEnv, jclass, jfieldID, jshort) callconv(JNICALL) void,
        SetStaticIntField: *const fn ([*c]JNIEnv, jclass, jfieldID, jint) callconv(JNICALL) void,
        SetStaticLongField: *const fn ([*c]JNIEnv, jclass, jfieldID, jlong) callconv(JNICALL) void,
        SetStaticFloatField: *const fn ([*c]JNIEnv, jclass, jfieldID, jfloat) callconv(JNICALL) void,
        SetStaticDoubleField: *const fn ([*c]JNIEnv, jclass, jfieldID, jdouble) callconv(JNICALL) void,
        NewString: *const fn ([*c]JNIEnv, [*c]const jchar, jsize) callconv(JNICALL) jstring,
        GetStringLength: *const fn ([*c]JNIEnv, jstring) callconv(JNICALL) jsize,
        GetStringChars: *const fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const jchar,
        ReleaseStringChars: *const fn ([*c]JNIEnv, jstring, [*c]const jchar) callconv(JNICALL) void,
        NewStringUTF: *const fn ([*c]JNIEnv, [*c]const u8) callconv(JNICALL) jstring,
        GetStringUTFLength: *const fn ([*c]JNIEnv, jstring) callconv(JNICALL) jsize,
        GetStringUTFChars: *const fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const u8,
        ReleaseStringUTFChars: *const fn ([*c]JNIEnv, jstring, [*c]const u8) callconv(JNICALL) void,
        GetArrayLength: *const fn ([*c]JNIEnv, jarray) callconv(JNICALL) jsize,
        NewObjectArray: *const fn ([*c]JNIEnv, jsize, jclass, jobject) callconv(JNICALL) jobjectArray,
        GetObjectArrayElement: *const fn ([*c]JNIEnv, jobjectArray, jsize) callconv(JNICALL) jobject,
        SetObjectArrayElement: *const fn ([*c]JNIEnv, jobjectArray, jsize, jobject) callconv(JNICALL) void,
        NewBooleanArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jbooleanArray,
        NewByteArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jbyteArray,
        NewCharArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jcharArray,
        NewShortArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jshortArray,
        NewIntArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jintArray,
        NewLongArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jlongArray,
        NewFloatArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jfloatArray,
        NewDoubleArray: *const fn ([*c]JNIEnv, jsize) callconv(JNICALL) jdoubleArray,
        GetBooleanArrayElements: *const fn ([*c]JNIEnv, jbooleanArray, [*c]jboolean) callconv(JNICALL) [*c]jboolean,
        GetByteArrayElements: *const fn ([*c]JNIEnv, jbyteArray, [*c]jboolean) callconv(JNICALL) [*c]jbyte,
        GetCharArrayElements: *const fn ([*c]JNIEnv, jcharArray, [*c]jboolean) callconv(JNICALL) [*c]jchar,
        GetShortArrayElements: *const fn ([*c]JNIEnv, jshortArray, [*c]jboolean) callconv(JNICALL) [*c]jshort,
        GetIntArrayElements: *const fn ([*c]JNIEnv, jintArray, [*c]jboolean) callconv(JNICALL) [*c]jint,
        GetLongArrayElements: *const fn ([*c]JNIEnv, jlongArray, [*c]jboolean) callconv(JNICALL) [*c]jlong,
        GetFloatArrayElements: *const fn ([*c]JNIEnv, jfloatArray, [*c]jboolean) callconv(JNICALL) [*c]jfloat,
        GetDoubleArrayElements: *const fn ([*c]JNIEnv, jdoubleArray, [*c]jboolean) callconv(JNICALL) [*c]jdouble,
        ReleaseBooleanArrayElements: *const fn ([*c]JNIEnv, jbooleanArray, [*c]jboolean, jint) callconv(JNICALL) void,
        ReleaseByteArrayElements: *const fn ([*c]JNIEnv, jbyteArray, [*c]jbyte, jint) callconv(JNICALL) void,
        ReleaseCharArrayElements: *const fn ([*c]JNIEnv, jcharArray, [*c]jchar, jint) callconv(JNICALL) void,
        ReleaseShortArrayElements: *const fn ([*c]JNIEnv, jshortArray, [*c]jshort, jint) callconv(JNICALL) void,
        ReleaseIntArrayElements: *const fn ([*c]JNIEnv, jintArray, [*c]jint, jint) callconv(JNICALL) void,
        ReleaseLongArrayElements: *const fn ([*c]JNIEnv, jlongArray, [*c]jlong, jint) callconv(JNICALL) void,
        ReleaseFloatArrayElements: *const fn ([*c]JNIEnv, jfloatArray, [*c]jfloat, jint) callconv(JNICALL) void,
        ReleaseDoubleArrayElements: *const fn ([*c]JNIEnv, jdoubleArray, [*c]jdouble, jint) callconv(JNICALL) void,
        GetBooleanArrayRegion: *const fn ([*c]JNIEnv, jbooleanArray, jsize, jsize, [*c]jboolean) callconv(JNICALL) void,
        GetByteArrayRegion: *const fn ([*c]JNIEnv, jbyteArray, jsize, jsize, [*c]jbyte) callconv(JNICALL) void,
        GetCharArrayRegion: *const fn ([*c]JNIEnv, jcharArray, jsize, jsize, [*c]jchar) callconv(JNICALL) void,
        GetShortArrayRegion: *const fn ([*c]JNIEnv, jshortArray, jsize, jsize, [*c]jshort) callconv(JNICALL) void,
        GetIntArrayRegion: *const fn ([*c]JNIEnv, jintArray, jsize, jsize, [*c]jint) callconv(JNICALL) void,
        GetLongArrayRegion: *const fn ([*c]JNIEnv, jlongArray, jsize, jsize, [*c]jlong) callconv(JNICALL) void,
        GetFloatArrayRegion: *const fn ([*c]JNIEnv, jfloatArray, jsize, jsize, [*c]jfloat) callconv(JNICALL) void,
        GetDoubleArrayRegion: *const fn ([*c]JNIEnv, jdoubleArray, jsize, jsize, [*c]jdouble) callconv(JNICALL) void,
        SetBooleanArrayRegion: *const fn ([*c]JNIEnv, jbooleanArray, jsize, jsize, [*c]const jboolean) callconv(JNICALL) void,
        SetByteArrayRegion: *const fn ([*c]JNIEnv, jbyteArray, jsize, jsize, [*c]const jbyte) callconv(JNICALL) void,
        SetCharArrayRegion: *const fn ([*c]JNIEnv, jcharArray, jsize, jsize, [*c]const jchar) callconv(JNICALL) void,
        SetShortArrayRegion: *const fn ([*c]JNIEnv, jshortArray, jsize, jsize, [*c]const jshort) callconv(JNICALL) void,
        SetIntArrayRegion: *const fn ([*c]JNIEnv, jintArray, jsize, jsize, [*c]const jint) callconv(JNICALL) void,
        SetLongArrayRegion: *const fn ([*c]JNIEnv, jlongArray, jsize, jsize, [*c]const jlong) callconv(JNICALL) void,
        SetFloatArrayRegion: *const fn ([*c]JNIEnv, jfloatArray, jsize, jsize, [*c]const jfloat) callconv(JNICALL) void,
        SetDoubleArrayRegion: *const fn ([*c]JNIEnv, jdoubleArray, jsize, jsize, [*c]const jdouble) callconv(JNICALL) void,
        RegisterNatives: *const fn ([*c]JNIEnv, jclass, [*c]const JNINativeMethod, jint) callconv(JNICALL) jint,
        UnregisterNatives: *const fn ([*c]JNIEnv, jclass) callconv(JNICALL) jint,
        MonitorEnter: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jint,
        MonitorExit: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jint,
        GetJavaVM: *const fn ([*c]JNIEnv, [*c][*c]JavaVM) callconv(JNICALL) jint,
        GetStringRegion: *const fn ([*c]JNIEnv, jstring, jsize, jsize, [*c]jchar) callconv(JNICALL) void,
        GetStringUTFRegion: *const fn ([*c]JNIEnv, jstring, jsize, jsize, [*c]u8) callconv(JNICALL) void,
        GetPrimitiveArrayCritical: *const fn ([*c]JNIEnv, jarray, [*c]jboolean) callconv(JNICALL) ?*anyopaque,
        ReleasePrimitiveArrayCritical: *const fn ([*c]JNIEnv, jarray, ?*anyopaque, jint) callconv(JNICALL) void,
        GetStringCritical: *const fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const jchar,
        ReleaseStringCritical: *const fn ([*c]JNIEnv, jstring, [*c]const jchar) callconv(JNICALL) void,
        NewWeakGlobalRef: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jweak,
        DeleteWeakGlobalRef: *const fn ([*c]JNIEnv, jweak) callconv(JNICALL) void,
        ExceptionCheck: *const fn ([*c]JNIEnv) callconv(JNICALL) jboolean,
        NewDirectByteBuffer: *const fn ([*c]JNIEnv, ?*anyopaque, jlong) callconv(JNICALL) jobject,
        GetDirectBufferAddress: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) ?*anyopaque,
        GetDirectBufferCapacity: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) jlong,
        GetObjectReferenceKind: *const fn ([*c]JNIEnv, jobject) callconv(JNICALL) ObjectReferenceKind,
        GetModule: *const fn ([*c]JNIEnv, jclass) callconv(JNICALL) jobject,
    }
else
    extern struct {
        reserved0: ?*anyopaque,
        reserved1: ?*anyopaque,
        reserved2: ?*anyopaque,
        reserved3: ?*anyopaque,

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
        GetPrimitiveArrayCritical: fn ([*c]JNIEnv, jarray, [*c]jboolean) callconv(JNICALL) ?*anyopaque,
        ReleasePrimitiveArrayCritical: fn ([*c]JNIEnv, jarray, ?*anyopaque, jint) callconv(JNICALL) void,
        GetStringCritical: fn ([*c]JNIEnv, jstring, [*c]jboolean) callconv(JNICALL) [*c]const jchar,
        ReleaseStringCritical: fn ([*c]JNIEnv, jstring, [*c]const jchar) callconv(JNICALL) void,
        NewWeakGlobalRef: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jweak,
        DeleteWeakGlobalRef: fn ([*c]JNIEnv, jweak) callconv(JNICALL) void,
        ExceptionCheck: fn ([*c]JNIEnv) callconv(JNICALL) jboolean,
        NewDirectByteBuffer: fn ([*c]JNIEnv, ?*anyopaque, jlong) callconv(JNICALL) jobject,
        GetDirectBufferAddress: fn ([*c]JNIEnv, jobject) callconv(JNICALL) ?*anyopaque,
        GetDirectBufferCapacity: fn ([*c]JNIEnv, jobject) callconv(JNICALL) jlong,
        GetObjectReferenceKind: fn ([*c]JNIEnv, jobject) callconv(JNICALL) ObjectReferenceKind,
        GetModule: fn ([*c]JNIEnv, jclass) callconv(JNICALL) jobject,
    };

// Instead of using std.meta.FnPtr for each declaration,
// Just duplicating all structs here, with fn(..) and *const fn
// This way it's easier to just delete when stage1 was removed
const JNIInvokeInterface = if (is_stage2)
    extern struct {
        reserved0: ?*anyopaque,
        reserved1: ?*anyopaque,
        reserved2: ?*anyopaque,

        DestroyJavaVM: *const fn ([*c]JavaVM) callconv(JNICALL) jint,
        AttachCurrentThread: *const fn ([*c]JavaVM, [*c]?*anyopaque, ?*anyopaque) callconv(JNICALL) jint,
        DetachCurrentThread: *const fn ([*c]JavaVM) callconv(JNICALL) jint,
        GetEnv: *const fn ([*c]JavaVM, [*c]?*anyopaque, jint) callconv(JNICALL) jint,
        AttachCurrentThreadAsDaemon: *const fn ([*c]JavaVM, [*c]?*anyopaque, ?*anyopaque) callconv(JNICALL) jint,
    }
else
    extern struct {
        reserved0: ?*anyopaque,
        reserved1: ?*anyopaque,
        reserved2: ?*anyopaque,

        DestroyJavaVM: fn ([*c]JavaVM) callconv(JNICALL) jint,
        AttachCurrentThread: fn ([*c]JavaVM, [*c]?*anyopaque, ?*anyopaque) callconv(JNICALL) jint,
        DetachCurrentThread: fn ([*c]JavaVM) callconv(JNICALL) jint,
        GetEnv: fn ([*c]JavaVM, [*c]?*anyopaque, jint) callconv(JNICALL) jint,
        AttachCurrentThreadAsDaemon: fn ([*c]JavaVM, [*c]?*anyopaque, ?*anyopaque) callconv(JNICALL) jint,
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
    pub fn isAssignableFrom(self: *Self, class1: jclass, class2: jclass) bool {
        return self.interface.IsAssignableFrom(self, class1, class2) == 1;
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
        unreachable;
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
            .void => @compileError("Field cannot be of type 'void'"),
        })(self, object, field_id);
    }

    /// Sets the value of a field
    pub fn setField(self: *Self, comptime native_type: NativeType, object: jobject, field_id: jfieldID, value: MapNativeType(native_type)) void {
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
            .void => @compileError("Field cannot be of type 'void'"),
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
            .void => self.interface.CallVoidMethodA,
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
            .void => self.interface.CallNonvirtualVoidMethodA,
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
            .void => @compileError("Field cannot be of type 'void'"),
        })(self, class, field_id);
    }

    /// Sets the value of a field
    pub fn setStaticField(self: *Self, comptime native_type: NativeType, class: jclass, field_id: jfieldID, value: MapNativeType(native_type)) void {
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
            .void => unreachable,
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
            .void => self.interface.CallStaticVoidMethodA,
        })(self, class, method_id, args);

        return if (self.hasPendingException()) error.Exception else value;
    }

    // String Operations

    pub const NewStringError = error{OutOfMemoryError};

    /// Constructs a new java.lang.String object from an array of Unicode characters
    pub fn newString(self: *Self, unicode_chars: []const u16) NewStringError!jstring {
        var maybe_jstring = self.interface.NewString(self, @ptrCast([*]const u16, unicode_chars), @intCast(jsize, unicode_chars.len));
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

    pub fn getJavaVM(self: *Self) JNIFailureError!*JavaVM {
        var vm: *JavaVM = undefined;
        try handleFailureError(self.interface.GetJavaVM(self, @ptrCast([*c][*c]JavaVM, &vm)));
        return vm;
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

    /// Returns the memory region referenced by the given direct java.nio.Buffer.
    /// This function allows native code to access the same memory region that is accessible to Java code via the buffer object.
    pub fn getDirectBufferAddress(self: *Self, buf: jobject) []u8 {
        const ptr = self.interface.GetDirectBufferAddress(self, buf);
        const len = @bitCast(usize, self.interface.GetDirectBufferCapacity(self, buf));

        return @ptrCast([*]u8, @alignCast(@alignOf(u8), ptr))[0..len];
    }

    pub const NewDirectByteBufferError = error{Unknown};

    pub fn newDirectByteBuffer(self: *Self, ptr: *anyopaque, len: usize) NewDirectByteBufferError!jobject {
        var maybe_obj = self.interface.NewDirectByteBuffer(self, ptr, @bitCast(jlong, len));
        return if (maybe_obj) |obj|
            obj
        else
            error.Unknown;
    }

    // Arrays

    pub const NewObjectArrayError = error{
        /// if the system runs out of memory
        OutOfMemoryError,

        /// if the array cannot be constructed
        Unknown,
    };

    /// Constructs a new array holding objects in class elementClass. All elements are initially set to initial_element.
    pub fn newObjectArray(self: *Self, length: jsize, class: jclass, initial_element: jobject) NewObjectArrayError!jobjectArray {
        var maybe_array = self.interface.NewObjectArray(self, length, class, initial_element);
        return if (maybe_array) |array|
            array
        else if (self.hasPendingException())
            self.handleKnownError(NewObjectArrayError)
        else
            error.Unknown;
    }

    pub const GetObjectArrayElementError = error{
        /// if index does not specify a valid index in the array
        ArrayIndexOutOfBoundsException,
    };

    /// Returns an element of an Object array.
    pub fn getObjectArrayElement(
        self: *Self,
        array: jobjectArray,
        index: jsize,
    ) GetObjectArrayElementError!jobject {
        var maybe_obj = self.interface.GetObjectArrayElement(self, array, index);
        return if (maybe_obj) |obj|
            obj
        else
            self.handleKnownError(GetObjectArrayElementError);
    }

    pub const SetObjectArrayElementError = error{
        /// if index does not specify a valid index in the array
        ArrayIndexOutOfBoundsException,

        /// if the class of value is not a subclass of the element class of the array
        ArrayStoreException,
    };

    /// Returns an element of an Object array.
    pub fn setObjectArrayElement(
        self: *Self,
        array: jobjectArray,
        index: jsize,
        value: jobject,
    ) SetObjectArrayElementError!void {
        self.interface.SetObjectArrayElement(self, array, index, value);
        return if (self.hasPendingException())
            self.handleKnownError(GetObjectArrayElementError);
    }

    pub const NewPrimitiveArrayError = error{
        /// if the array cannot be constructed
        Unknown,
    };

    /// Constructs a new primitive array object.
    pub fn newPrimitiveArray(
        self: *Self,
        comptime native_type: NativeType,
        size: jsize,
    ) NewPrimitiveArrayError!MapArrayType(native_type) {
        return (switch (native_type) {
            .boolean => self.interface.NewBooleanArray,
            .byte => self.interface.NewByteArray,
            .char => self.interface.NewCharArray,
            .short => self.interface.NewShortArray,
            .int => self.interface.NewIntArray,
            .long => self.interface.NewLongArray,
            .float => self.interface.NewFloatArray,
            .double => self.interface.NewDoubleArray,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, size) orelse
            error.Unknown;
    }

    pub const GetPrimitiveArrayElementsError = error{
        Unknown,
    };
    pub fn GetPrimitiveArrayElementsReturn(comptime native_type: NativeType) type {
        return struct { elements: [*]MapNativeType(native_type), is_copy: bool };
    }

    /// Returns the body of the primitive array.
    /// The result is valid until releasePrimitiveArrayElements() function is called.
    /// Since the returned array may be a copy of the Java array,
    /// changes made to the returned array will not necessarily be reflected in the original array
    /// until releasePrimitiveArrayElements() is called.
    pub fn getPrimitiveArrayElements(
        self: *Self,
        comptime native_type: NativeType,
        array: MapArrayType(native_type),
    ) GetPrimitiveArrayElementsError!GetPrimitiveArrayElementsReturn(native_type) {
        var is_copy: jboolean = 0;
        var maybe_elements = (switch (native_type) {
            .boolean => self.interface.GetBooleanArrayElements,
            .byte => self.interface.GetByteArrayElements,
            .char => self.interface.GetCharArrayElements,
            .short => self.interface.GetShortArrayElements,
            .int => self.interface.GetIntArrayElements,
            .long => self.interface.GetLongArrayElements,
            .float => self.interface.GetFloatArrayElements,
            .double => self.interface.GetDoubleArrayElements,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, array, &is_copy);

        return if (maybe_elements) |elements|
            GetPrimitiveArrayElementsReturn(native_type){ .elements = elements, .is_copy = is_copy == 1 }
        else
            error.Unknown;
    }

    /// The mode argument provides information on how the array buffer should be released.
    /// Mode has no effect if elems is not a copy of the elements in array.
    pub const ReleasePrimitiveArrayElementsMode = enum(jint) {
        /// Copy back the content and free the elems buffer
        default = 0,

        /// Copy back the content but do not free the elems buffer
        commit,

        /// Free the buffer without copying back the possible changes
        abort,
    };

    /// Informs the VM that the native code no longer needs access to elems.
    /// The elems argument is a pointer derived from array using getPrimitiveArrayElements() function.
    /// If necessary, this function copies back all changes made to elems to the original array.
    pub fn releasePrimitiveArrayElements(
        self: *Self,
        comptime native_type: NativeType,
        array: MapArrayType(native_type),
        elements: [*]MapNativeType(native_type),
        mode: ReleasePrimitiveArrayElementsMode,
    ) void {
        (switch (native_type) {
            .boolean => self.interface.ReleaseBooleanArrayElements,
            .byte => self.interface.ReleaseByteArrayElements,
            .char => self.interface.ReleaseCharArrayElements,
            .short => self.interface.ReleaseShortArrayElements,
            .int => self.interface.ReleaseIntArrayElements,
            .long => self.interface.ReleaseLongArrayElements,
            .float => self.interface.ReleaseFloatArrayElements,
            .double => self.interface.ReleaseDoubleArrayElements,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, array, elements, @enumToInt(mode));
    }

    pub const GetPrimitiveArrayRegionError = error{
        /// if one of the indexes in the region is not valid
        ArrayIndexOutOfBoundsException,
    };

    /// Copies a region of a primitive array into a buffer.
    pub fn getPrimitiveArrayRegion(
        self: *Self,
        comptime native_type: NativeType,
        array: MapArrayType(native_type),
        start: jsize,
        length: jsize,
        buffer: [*]MapNativeType(native_type),
    ) GetPrimitiveArrayRegionError!void {
        (switch (native_type) {
            .boolean => self.interface.GetBooleanArrayRegion,
            .byte => self.interface.GetByteArrayRegion,
            .char => self.interface.GetCharArrayRegion,
            .short => self.interface.GetShortArrayRegion,
            .int => self.interface.GetIntArrayRegion,
            .long => self.interface.GetLongArrayRegion,
            .float => self.interface.GetFloatArrayRegion,
            .double => self.interface.GetDoubleArrayRegion,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, array, start, length, buffer);
        return if (self.hasPendingException())
            self.handleKnownError(GetPrimitiveArrayRegionError);
    }

    pub const SetPrimitiveArrayRegionError = error{
        /// if one of the indexes in the region is not valid
        ArrayIndexOutOfBoundsException,
    };

    /// Copies back a region of a primitive array from a buffer.
    pub fn setPrimitiveArrayRegion(
        self: *Self,
        comptime native_type: NativeType,
        array: MapArrayType(native_type),
        start: jsize,
        length: jsize,
        buffer: [*]MapNativeType(native_type),
    ) SetPrimitiveArrayRegionError!void {
        (switch (native_type) {
            .boolean => self.interface.GetBooleanArrayRegion,
            .byte => self.interface.GetByteArrayRegion,
            .char => self.interface.GetCharArrayRegion,
            .short => self.interface.GetShortArrayRegion,
            .int => self.interface.GetIntArrayRegion,
            .long => self.interface.GetLongArrayRegion,
            .float => self.interface.GetFloatArrayRegion,
            .double => self.interface.GetDoubleArrayRegion,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, array, start, length, buffer);
        return if (self.hasPendingException())
            self.handleKnownError(SetPrimitiveArrayRegionError);
    }

    pub const GetPrimitiveArrayCriticalError = error{
        /// if one of the indexes in the critical region is not valid
        ArrayIndexOutOfBoundsException,
    };
    pub fn GetPrimitiveArrayCriticalReturn(comptime native_type: NativeType) type {
        return struct { region: [*]MapNativeType(native_type), is_copy: bool };
    }

    /// If possible, the VM returns a pointer to the primitive array; otherwise, a copy is made.
    /// However, there are significant restrictions on how these functions can be used.
    /// After calling getPrimitiveArrayCritical,
    /// the native code should not run for an extended period of time before it calls releasePrimitiveArrayCritical.
    /// We must treat the code inside this pair of functions as running in a "critical region."
    /// Inside a critical region, native code must not call other JNI functions,
    /// or any system call that may cause the current thread to block and wait for another Java thread.
    /// These restrictions make it more likely that the native code will obtain an uncopied version of the array,
    /// even if the VM does not support pinning.
    /// For example, a VM may temporarily disable garbage collection when the native code is holding a pointer
    /// to an array obtained via getPrimitiveArrayCritical.
    pub fn getPrimitiveArrayCritical(
        self: *Self,
        comptime native_type: NativeType,
        array: MapArrayType(native_type),
        start: jsize,
        length: jsize,
    ) GetPrimitiveArrayCriticalError!GetPrimitiveArrayCriticalReturn(native_type) {
        var is_copy: jboolean = 0;
        var maybe_region = (switch (native_type) {
            .boolean => self.interface.GetBooleanArrayCritical,
            .byte => self.interface.GetByteArrayCritical,
            .char => self.interface.GetCharArrayCritical,
            .short => self.interface.GetShortArrayCritical,
            .int => self.interface.GetIntArrayCritical,
            .long => self.interface.GetLongArrayCritical,
            .float => self.interface.GetFloatArrayCritical,
            .double => self.interface.GetDoubleArrayCritical,
            .object => @compileError("Only primitive types are allowed"),
            .void => unreachable,
        })(self, array, start, length, &is_copy);

        return if (maybe_region) |region|
            GetPrimitiveArrayCriticalReturn(native_type){
                .region = @ptrCast([*]MapNativeType(native_type), region),
                .is_copy = is_copy == 1,
            }
        else if (self.hasPendingException())
            self.handleKnownError(GetPrimitiveArrayRegionError)
        else
            error.Unknown;
    }
};

pub const JavaVMOption = extern struct {
    option: [*:0]const u8,
    extraInfo: ?*const anyopaque = null,
};

pub const JavaVMInitArgs = struct {
    version: JNIVersion,
    options: []const JavaVMOption,
    ignore_unrecognized: bool,
};

pub const JavaVM = extern struct {
    const Self = @This();

    interface: *const JNIInvokeInterface,

    extern fn JNI_CreateJavaVM(pvm: **JavaVM, penv: **JNIEnv, args: *anyopaque) jint;
    extern fn JNI_GetCreatedJavaVMs([*c][*c]JavaVM, jsize, [*c]jsize) jint;

    pub fn getCreatedJavaVMs(buffer: []*JavaVM) JNIFailureError![]*JavaVM {
        var size: jsize = undefined;
        try handleFailureError(JNI_GetCreatedJavaVMs(
            @ptrCast([*c][*c]JavaVM, buffer.ptr),
            @intCast(jsize, buffer.len),
            &size,
        ));
        return buffer[0..@intCast(usize, size)];
    }

    pub fn getCreatedJavaVM() JNIFailureError!?*JavaVM {
        var buffer: [1]*JavaVM = undefined;
        var result = try getCreatedJavaVMs(&buffer);
        return if (result.len == 0)
            null
        else
            result[0];
    }

    pub const CreateJavaVMReturn = struct { jvm: *JavaVM, env: *JNIEnv };

    pub fn createJavaVM(args: *const JavaVMInitArgs) JNIFailureError!CreateJavaVMReturn {
        var args_: extern struct {
            version: jint,
            nOptions: jint,
            options: [*c]const JavaVMOption,
            ignoreUnrecognized: jboolean,
        } = .{
            .version = @bitCast(jint, args.version),
            .nOptions = @intCast(jint, args.options.len),
            .options = args.options.ptr,
            .ignoreUnrecognized = if (args.ignore_unrecognized) 1 else 0,
        };

        var jvm: *JavaVM = undefined;
        var env: *JNIEnv = undefined;
        try handleFailureError(JNI_CreateJavaVM(
            &jvm,
            &env,
            &args_,
        ));
        return CreateJavaVMReturn{
            .jvm = jvm,
            .env = env,
        };
    }

    /// Unloads a Java VM and reclaims its resources.
    pub fn destroyJavaVM(self: *Self) JNIFailureError!void {
        try handleFailureError(self.interface.DestroyJavaVM(self));
    }

    /// Attaches the current thread to a Java VM. Returns a JNI interface pointer in the JNIEnv argument.
    /// Trying to attach a thread that is already attached is a no-op.
    pub fn attachCurrentThread(self: *Self) JNIFailureError!*JNIEnv {
        var env: *JNIEnv = undefined;
        try handleFailureError(self.interface.AttachCurrentThread(self, @ptrCast([*c]?*anyopaque, &env), null));
        return env;
    }

    /// Same semantics as attachCurrentThread, but the newly-created java.lang.Thread instance is a daemon.
    /// If the thread has already been attached via either AttachCurrentThread or AttachCurrentThreadAsDaemon,
    /// this routine simply sets the value pointed to by penv to the JNIEnv of the current thread.
    /// In this case neither AttachCurrentThread nor this routine have any effect on the daemon status of the thread.
    pub fn attachCurrentThreadAsDaemon(self: *Self) JNIFailureError!*JNIEnv {
        var env: *JNIEnv = undefined;
        try handleFailureError(self.interface.AttachCurrentThreadAsDaemon(self, @ptrCast([*c]?*anyopaque, &env), null));
        return env;
    }

    /// Detaches the current thread from a Java VM.
    /// All Java monitors held by this thread are released. All Java threads waiting for this thread to die are notified.
    pub fn detachCurrentThread(self: *Self) JNIFailureError!void {
        try handleFailureError(self.interface.DetachCurrentThread(self));
    }

    pub fn getEnv(self: *Self, version: JNIVersion) JNIFailureError!*JNIEnv {
        var env: *JNIEnv = undefined;
        try handleFailureError(self.interface.GetEnv(self, @ptrCast([*c]?*anyopaque, &env), @bitCast(jint, version)));
        return env;
    }
};

// Tests

const testing = std.testing;

const getTestingJNIEnv = struct {
    var init = std.once(createJVM);
    var env: *JNIEnv = undefined;

    fn createJVM() void {
        const JNI_1_10 = JNIVersion{ .major = 10, .minor = 0 };
        const args = JavaVMInitArgs{
            .version = JNI_1_10,
            .options = &.{
                .{ .option = "-Djava.class.path=./test/src" },
            },
            .ignore_unrecognized = true,
        };
        var result = JavaVM.createJavaVM(&args) catch |err| {
            std.debug.panic("Cannot create JVM {}", .{err});
        };
        env = result.env;
    }

    pub fn getEnv() *JNIEnv {
        init.call();
        return env;
    }
}.getEnv;

test "Check created JVM" {
    var env = getTestingJNIEnv();

    var jvm = try env.getJavaVM();
    var created_jvm = try JavaVM.getCreatedJavaVM();
    try testing.expect(created_jvm != null);
    try testing.expectEqual(jvm, created_jvm.?);
}

test "getClassNameOfObject" {
    var env = getTestingJNIEnv();

    var class = try env.findClass("com/jui/TypesTest");
    try testing.expect(class != null);
    defer env.deleteReference(.local, class);

    var obj = try env.allocObject(class);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    var className = env.getClassNameOfObject(obj);
    try testing.expect(className != null);
    defer env.deleteReference(.local, className);

    var utf = try env.getStringUTFChars(className);
    defer env.releaseStringUTFChars(className, utf.chars);

    var len = env.getStringUTFLength(className);
    try testing.expectEqual(@as(jsize, 17), len);

    try testing.expectEqualStrings("com.jui.TypesTest", utf.chars[0..@intCast(usize, len)]);
}

test "getJNIVersion" {
    var env = getTestingJNIEnv();

    const version = env.getJNIVersion();
    try testing.expectEqual(JNIVersion{ .major = 10, .minor = 0 }, version);
}

test "defineClass" {
    return error.SkipZigTest;
}

test "findClass" {
    var env = getTestingJNIEnv();

    var objectClass = try env.findClass("java/lang/Object");
    try testing.expect(objectClass != null);
    defer env.deleteReference(.local, objectClass);

    if (env.findClass("no/such/Class")) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.NoClassDefFoundError);
    }
}

test "getSuperclass" {
    var env = getTestingJNIEnv();

    var objectClass = try env.findClass("java/lang/Object");
    try testing.expect(objectClass != null);
    defer env.deleteReference(.local, objectClass);

    try testing.expect(env.getSuperclass(objectClass) == null);

    var stringClass = try env.findClass("java/lang/String");
    try testing.expect(stringClass != null);
    defer env.deleteReference(.local, stringClass);

    var superClass = env.getSuperclass(stringClass);
    try testing.expect(superClass != null);
    defer env.deleteReference(.local, superClass);

    try testing.expect(env.isSameObject(objectClass, superClass));
}

test "isAssignableFrom" {
    var env = getTestingJNIEnv();

    var objectClass = try env.findClass("java/lang/Object");
    try testing.expect(objectClass != null);
    defer env.deleteReference(.local, objectClass);

    try testing.expect(env.getSuperclass(objectClass) == null);

    var stringClass = try env.findClass("java/lang/String");
    try testing.expect(stringClass != null);
    defer env.deleteReference(.local, stringClass);

    var longClass = try env.findClass("java/lang/Long");
    try testing.expect(longClass != null);
    defer env.deleteReference(.local, longClass);

    try testing.expect(env.isAssignableFrom(stringClass, objectClass));
    try testing.expect(!env.isAssignableFrom(stringClass, longClass));
}

test "getModule" {
    return error.SkipZigTest;
}

test "throw" {
    return error.SkipZigTest;
}

test "throwNew" {
    var env = getTestingJNIEnv();

    var exceptionClass = try env.findClass("java/lang/Exception");
    try testing.expect(exceptionClass != null);
    defer env.deleteReference(.local, exceptionClass);

    try testing.expect(!env.hasPendingException());

    try env.throwNew(exceptionClass, "");
    defer env.clearPendingException();

    try testing.expect(env.hasPendingException());
}

test "throwGeneric" {
    var env = getTestingJNIEnv();

    try testing.expect(!env.hasPendingException());

    try env.throwGeneric("");
    defer env.clearPendingException();

    try testing.expect(env.hasPendingException());
}

test "getPendingException" {
    var env = getTestingJNIEnv();

    try testing.expect(env.getPendingException() == null);

    try env.throwGeneric("");
    defer env.clearPendingException();

    var pendingException = env.getPendingException();
    try testing.expect(pendingException != null);
    defer env.deleteReference(.local, pendingException);
}

test "describeException" {
    var env = getTestingJNIEnv();

    try testing.expect(!env.hasPendingException());

    try env.throwGeneric("DESCRIBED CORRECTLY");
    defer env.clearPendingException();

    env.describeException();
}

test "clearPendingException" {
    var env = getTestingJNIEnv();

    try testing.expect(!env.hasPendingException());

    try env.throwGeneric("");

    try testing.expect(env.hasPendingException());
    env.clearPendingException();
    try testing.expect(!env.hasPendingException());
}

test "fatalError" {
    // TODO: Wait until Zig has support for "expectPanic"
    if (true) return error.SkipZigTest;
    var env = getTestingJNIEnv();

    try testing.expect(!env.hasPendingException());

    env.fatalError("FATAL");
}

test "hasPendingException" {
    var env = getTestingJNIEnv();

    try testing.expect(!env.hasPendingException());

    try env.throwGeneric("");

    try testing.expect(env.hasPendingException());
    env.clearPendingException();
    try testing.expect(!env.hasPendingException());
}

test "references: newReference, deleteReference, getObjectReferenceKind, isSameObject" {
    var env = getTestingJNIEnv();

    var booleanClass = try env.findClass("java/lang/Boolean");
    try testing.expect(booleanClass != null);
    defer env.deleteReference(.local, booleanClass);

    var obj = try env.allocObject(booleanClass);
    defer env.deleteReference(.local, obj);
    try testing.expect(obj != null);
    try testing.expect(env.getObjectReferenceKind(obj) == .local);

    var local_ref = try env.newReference(.local, obj);
    defer env.deleteReference(.local, local_ref);
    try testing.expect(local_ref != null);
    try testing.expect(env.isSameObject(obj, local_ref));
    try testing.expect(env.getObjectReferenceKind(local_ref) == .local);

    var global_ref = try env.newReference(.global, obj);
    defer env.deleteReference(.global, global_ref);
    try testing.expect(global_ref != null);
    try testing.expect(env.isSameObject(obj, global_ref));
    try testing.expect(env.getObjectReferenceKind(global_ref) == .global);

    var weak_ref = try env.newReference(.weak_global, obj);
    defer env.deleteReference(.weak_global, weak_ref);
    try testing.expect(weak_ref != null);
    try testing.expect(env.isSameObject(obj, weak_ref));
    try testing.expect(env.getObjectReferenceKind(weak_ref) == .weak_global);
}

test "ensureLocalCapacity" {
    return error.SkipZigTest;
}

test "pushLocalFrame" {
    return error.SkipZigTest;
}

test "popLocalFrame" {
    return error.SkipZigTest;
}

test "allocObject" {
    var env = getTestingJNIEnv();
    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var obj = try env.allocObject(testClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    var interface = try env.findClass("com/jui/TypesTest$Interface");
    try testing.expect(interface != null);
    defer env.deleteReference(.local, interface);

    if (env.allocObject(interface)) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.InstantiationException);
    }

    var abstract = try env.findClass("com/jui/TypesTest$Abstract");
    try testing.expect(abstract != null);
    defer env.deleteReference(.local, abstract);

    if (env.allocObject(abstract)) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.InstantiationException);
    }
}

test "newObject" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    // Default constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "()V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, null);
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);
    }

    // Boolean constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(Z)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jboolean, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "booleanValue", "Z");
        try testing.expect(fieldId != null);

        var value = try env.getField(.boolean, obj, fieldId);
        try testing.expectEqual(@intCast(jboolean, 1), value);
    }

    // Byte constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(B)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jbyte, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "byteValue", "B");
        try testing.expect(fieldId != null);

        var value = try env.getField(.byte, obj, fieldId);
        try testing.expectEqual(@intCast(jbyte, 1), value);
    }

    // Char constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(C)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jchar, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "charValue", "C");
        try testing.expect(fieldId != null);

        var value = try env.getField(.char, obj, fieldId);
        try testing.expectEqual(@intCast(jchar, 1), value);
    }

    // Short constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(S)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jshort, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "shortValue", "S");
        try testing.expect(fieldId != null);

        var value = try env.getField(.short, obj, fieldId);
        try testing.expectEqual(@intCast(jshort, 1), value);
    }

    // Int constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(I)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jint, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "intValue", "I");
        try testing.expect(fieldId != null);

        var value = try env.getField(.int, obj, fieldId);
        try testing.expectEqual(@intCast(jint, 1), value);
    }

    // Long constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(J)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jlong, 1))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "longValue", "J");
        try testing.expect(fieldId != null);

        var value = try env.getField(.long, obj, fieldId);
        try testing.expectEqual(@intCast(jlong, 1), value);
    }

    // Float constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(F)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jfloat, 1.0))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "floatValue", "F");
        try testing.expect(fieldId != null);

        var value = try env.getField(.float, obj, fieldId);
        try testing.expectEqual(@intCast(jfloat, 1.0), value);
    }

    // Double constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(D)V");
        try testing.expect(ctor != null);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(@as(jdouble, 1.0))});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "doubleValue", "D");
        try testing.expect(fieldId != null);

        var value = try env.getField(.double, obj, fieldId);
        try testing.expectEqual(@intCast(jdouble, 1.0), value);
    }

    // Object constructor
    {
        var ctor = try env.getMethodId(testClass, "<init>", "(Ljava/lang/Object;)V");
        try testing.expect(ctor != null);

        var arg = env.allocObject(testClass);
        try testing.expect(arg != null);
        defer env.deleteReference(.local, arg);

        var obj = try env.newObject(testClass, ctor, &[_]jvalue{jvalue.toJValue(arg)});
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        var fieldId = try env.getFieldId(testClass, "objectValue", "Ljava/lang/Object;");
        try testing.expect(fieldId != null);

        var value = try env.getField(.object, obj, fieldId);
        try testing.expect(value != null);
        defer env.deleteReference(.local, value);

        try testing.expect(env.isSameObject(arg, value));
    }

    // Abstract class
    {
        var abstractClass = try env.findClass("com/jui/TypesTest$Abstract");
        try testing.expect(abstractClass != null);

        var ctor = try env.getMethodId(abstractClass, "<init>", "()V");
        try testing.expect(ctor != null);

        if (env.newObject(abstractClass, ctor, null)) |_| {
            try testing.expect(false);
        } else |err| {
            try testing.expect(err == error.InstantiationException);
        }
    }
}

test "newObject" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var obj = try env.allocObject(testClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    var objClass = env.getObjectClass(obj);
    try testing.expect(objClass != null);
    defer env.deleteReference(.local, objClass);

    try testing.expect(env.isSameObject(testClass, objClass));
}

test "isInstanceOf" {
    var env = getTestingJNIEnv();

    var booleanClass = try env.findClass("java/lang/Boolean");
    try testing.expect(booleanClass != null);
    defer env.deleteReference(.local, booleanClass);

    var obj = try env.allocObject(booleanClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    try testing.expect(env.isInstanceOf(obj, booleanClass));

    var longClass = try env.findClass("java/lang/Long");
    try testing.expect(longClass != null);
    defer env.deleteReference(.local, longClass);

    try testing.expect(!env.isInstanceOf(obj, longClass));
}

test "getFieldId" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var fieldId = try env.getFieldId(testClass, "booleanValue", "Z");
    try testing.expect(fieldId != null);

    if (env.getFieldId(testClass, "not_a_valid_field", "I")) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.NoSuchFieldError);
    }
}

test "fields: getField and setField" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var obj = try env.allocObject(testClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    // Boolean
    {
        var fieldId = try env.getFieldId(testClass, "booleanValue", "Z");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.boolean, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.boolean, obj, fieldId, @as(jboolean, 1));

        var v2 = env.getField(.boolean, obj, fieldId);
        try testing.expect(v2 == 1);
    }

    // Byte
    {
        var fieldId = try env.getFieldId(testClass, "byteValue", "B");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.byte, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.byte, obj, fieldId, @as(jbyte, 127));

        var v2 = env.getField(.byte, obj, fieldId);
        try testing.expect(v2 == 127);
    }

    // Char
    {
        var fieldId = try env.getFieldId(testClass, "charValue", "C");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.char, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.char, obj, fieldId, @as(jchar, 'A'));

        var v2 = env.getField(.char, obj, fieldId);
        try testing.expect(v2 == 'A');
    }

    // Short
    {
        var fieldId = try env.getFieldId(testClass, "shortValue", "S");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.char, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.short, obj, fieldId, @as(jshort, 9999));

        var v2 = env.getField(.short, obj, fieldId);
        try testing.expect(v2 == 9999);
    }

    // Int
    {
        var fieldId = try env.getFieldId(testClass, "intValue", "I");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.int, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.int, obj, fieldId, @as(jint, 999_999));

        var v2 = env.getField(.int, obj, fieldId);
        try testing.expect(v2 == 999_999);
    }

    // Long
    {
        var fieldId = try env.getFieldId(testClass, "longValue", "J");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.long, obj, fieldId);
        try testing.expect(v1 == 0);

        env.setField(.long, obj, fieldId, @as(jlong, 9_999_999_999));

        var v2 = env.getField(.long, obj, fieldId);
        try testing.expect(v2 == 9_999_999_999);
    }

    // Float
    {
        var fieldId = try env.getFieldId(testClass, "floatValue", "F");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.float, obj, fieldId);
        try testing.expect(v1 == 0.0);

        env.setField(.float, obj, fieldId, @as(jfloat, 9.99));

        var v2 = env.getField(.float, obj, fieldId);
        try testing.expect(v2 == 9.99);
    }

    // Double
    {
        var fieldId = try env.getFieldId(testClass, "doubleValue", "D");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.double, obj, fieldId);
        try testing.expect(v1 == 0.0);

        env.setField(.double, obj, fieldId, @as(jdouble, 9.99));

        var v2 = env.getField(.double, obj, fieldId);
        try testing.expect(v2 == 9.99);
    }

    // Object
    {
        var fieldId = try env.getFieldId(testClass, "objectValue", "Ljava/lang/Object;");
        try testing.expect(fieldId != null);

        var v1 = env.getField(.object, obj, fieldId);
        try testing.expect(v1 == null);

        env.setField(.object, obj, fieldId, obj);

        var v2 = env.getField(.object, obj, fieldId);
        try testing.expect(v2 != null);
        defer env.deleteReference(.local, v2);

        try testing.expect(env.isSameObject(obj, v2));
    }
}

test "getMethodId" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var methodId = try env.getMethodId(testClass, "getBooleanValue", "()Z");
    try testing.expect(methodId != null);

    if (env.getMethodId(testClass, "not_a_valid_method", "()Z")) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.NoSuchMethodError);
    }
}

test "methods: callMethod and callNonVirtualMethod" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var obj = try env.allocObject(testClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    // With arguments
    {
        var methodId = try env.getMethodId(testClass, "initialize", "(ZBCSIJFDLjava/lang/Object;)V");
        try testing.expect(methodId != null);

        const args = &[_]jvalue{
            jvalue.toJValue(@as(jboolean, 1)),
            jvalue.toJValue(@as(jbyte, 127)),
            jvalue.toJValue(@as(jchar, 'A')),
            jvalue.toJValue(@as(jshort, 9999)),
            jvalue.toJValue(@as(jint, 999_999)),
            jvalue.toJValue(@as(jlong, 9_999_999_999)),
            jvalue.toJValue(@as(jfloat, 9.99)),
            jvalue.toJValue(@as(jdouble, 9.99)),
            jvalue.toJValue(obj),
        };

        try env.callMethod(.void, obj, methodId, args);

        try env.callNonVirtualMethod(.void, obj, testClass, methodId, args);
    }

    // Return Boolean
    {
        var methodId = try env.getMethodId(testClass, "getBooleanValue", "()Z");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.boolean, obj, methodId, null);
        try testing.expect(v1 == 1);

        var v2 = try env.callNonVirtualMethod(.boolean, obj, testClass, methodId, null);
        try testing.expect(v2 == 1);
    }

    // Return Byte
    {
        var methodId = try env.getMethodId(testClass, "getByteValue", "()B");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.byte, obj, methodId, null);
        try testing.expect(v1 == 127);

        var v2 = try env.callNonVirtualMethod(.byte, obj, testClass, methodId, null);
        try testing.expect(v2 == 127);
    }

    // Return Char
    {
        var methodId = try env.getMethodId(testClass, "getCharValue", "()C");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.char, obj, methodId, null);
        try testing.expect(v1 == 'A');

        var v2 = try env.callNonVirtualMethod(.char, obj, testClass, methodId, null);
        try testing.expect(v2 == 'A');
    }

    // Return Short
    {
        var methodId = try env.getMethodId(testClass, "getShortValue", "()S");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.short, obj, methodId, null);
        try testing.expect(v1 == 9999);

        var v2 = try env.callNonVirtualMethod(.short, obj, testClass, methodId, null);
        try testing.expect(v2 == 9999);
    }

    // Return Integer
    {
        var methodId = try env.getMethodId(testClass, "getIntValue", "()I");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.int, obj, methodId, null);
        try testing.expect(v1 == 999_999);

        var v2 = try env.callNonVirtualMethod(.int, obj, testClass, methodId, null);
        try testing.expect(v2 == 999_999);
    }

    // Return Long
    {
        var methodId = try env.getMethodId(testClass, "getLongValue", "()J");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.long, obj, methodId, null);
        try testing.expect(v1 == 9_999_999_999);

        var v2 = try env.callNonVirtualMethod(.long, obj, testClass, methodId, null);
        try testing.expect(v2 == 9_999_999_999);
    }

    // Return Float
    {
        var methodId = try env.getMethodId(testClass, "getFloatValue", "()F");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.float, obj, methodId, null);
        try testing.expect(v1 == 9.99);

        var v2 = try env.callNonVirtualMethod(.float, obj, testClass, methodId, null);
        try testing.expect(v2 == 9.99);
    }

    // Return Double
    {
        var methodId = try env.getMethodId(testClass, "getDoubleValue", "()D");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.double, obj, methodId, null);
        try testing.expect(v1 == 9.99);

        var v2 = try env.callNonVirtualMethod(.double, obj, testClass, methodId, null);
        try testing.expect(v2 == 9.99);
    }

    // Return Object
    {
        var methodId = try env.getMethodId(testClass, "getObjectValue", "()Ljava/lang/Object;");
        try testing.expect(methodId != null);

        var v1 = try env.callMethod(.object, obj, methodId, null);
        try testing.expect(v1 != null);
        defer env.deleteReference(.local, v1);

        try testing.expect(env.isSameObject(obj, v1));

        var v2 = try env.callNonVirtualMethod(.object, obj, testClass, methodId, null);
        try testing.expect(v2 != null);
        defer env.deleteReference(.local, v2);

        try testing.expect(env.isSameObject(obj, v2));
    }
}

test "getStaticFieldId" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var fieldId = try env.getStaticFieldId(testClass, "staticBooleanValue", "Z");
    try testing.expect(fieldId != null);

    if (env.getStaticFieldId(testClass, "not_a_valid_field", "Z")) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.NoSuchFieldError);
    }
}

test "fields: getStaticField and setStaticField" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    // Boolean
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticBooleanValue", "Z");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.boolean, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.boolean, testClass, fieldId, @as(jboolean, 1));

        var v2 = env.getStaticField(.boolean, testClass, fieldId);
        try testing.expect(v2 == 1);
    }

    // Byte
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticByteValue", "B");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.byte, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.byte, testClass, fieldId, @as(jbyte, 127));

        var v2 = env.getStaticField(.byte, testClass, fieldId);
        try testing.expect(v2 == 127);
    }

    // Char
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticCharValue", "C");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.char, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.char, testClass, fieldId, @as(jchar, 'A'));

        var v2 = env.getStaticField(.char, testClass, fieldId);
        try testing.expect(v2 == 'A');
    }

    // Short
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticShortValue", "S");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.char, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.short, testClass, fieldId, @as(jshort, 9999));

        var v2 = env.getStaticField(.short, testClass, fieldId);
        try testing.expect(v2 == 9999);
    }

    // Int
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticIntValue", "I");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.int, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.int, testClass, fieldId, @as(jint, 999_999));

        var v2 = env.getStaticField(.int, testClass, fieldId);
        try testing.expect(v2 == 999_999);
    }

    // Long
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticLongValue", "J");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.long, testClass, fieldId);
        try testing.expect(v1 == 0);

        env.setStaticField(.long, testClass, fieldId, @as(jlong, 9_999_999_999));

        var v2 = env.getStaticField(.long, testClass, fieldId);
        try testing.expect(v2 == 9_999_999_999);
    }

    // Float
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticFloatValue", "F");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.float, testClass, fieldId);
        try testing.expect(v1 == 0.0);

        env.setStaticField(.float, testClass, fieldId, @as(jfloat, 9.99));

        var v2 = env.getStaticField(.float, testClass, fieldId);
        try testing.expect(v2 == 9.99);
    }

    // Double
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticDoubleValue", "D");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.double, testClass, fieldId);
        try testing.expect(v1 == 0.0);

        env.setStaticField(.double, testClass, fieldId, @as(jdouble, 9.99));

        var v2 = env.getStaticField(.double, testClass, fieldId);
        try testing.expect(v2 == 9.99);
    }

    // Object
    {
        var fieldId = try env.getStaticFieldId(testClass, "staticObjectValue", "Ljava/lang/Object;");
        try testing.expect(fieldId != null);

        var v1 = env.getStaticField(.object, testClass, fieldId);
        try testing.expect(v1 == null);

        var obj = try env.allocObject(testClass);
        try testing.expect(obj != null);
        defer env.deleteReference(.local, obj);

        env.setStaticField(.object, testClass, fieldId, obj);

        var v2 = env.getStaticField(.object, testClass, fieldId);
        try testing.expect(v2 != null);
        defer env.deleteReference(.local, v2);

        try testing.expect(env.isSameObject(obj, v2));
    }
}

test "getStaticMethodId" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    var methodId = try env.getStaticMethodId(testClass, "getStaticBooleanValue", "()Z");
    try testing.expect(methodId != null);

    if (env.getStaticMethodId(testClass, "not_a_valid_method", "()Z")) |_| {
        try testing.expect(false);
    } else |err| {
        try testing.expect(err == error.NoSuchMethodError);
    }
}

test "methods: callStaticMethod" {
    var env = getTestingJNIEnv();

    var testClass = try env.findClass("com/jui/TypesTest");
    try testing.expect(testClass != null);
    defer env.deleteReference(.local, testClass);

    // With arguments

    var initMethodId = try env.getStaticMethodId(testClass, "staticInitialize", "(ZBCSIJFDLjava/lang/Object;)V");
    try testing.expect(initMethodId != null);

    var obj = try env.allocObject(testClass);
    try testing.expect(obj != null);
    defer env.deleteReference(.local, obj);

    try env.callStaticMethod(
        .void,
        testClass,
        initMethodId,
        &[_]jvalue{
            jvalue.toJValue(@as(jboolean, 1)),
            jvalue.toJValue(@as(jbyte, 127)),
            jvalue.toJValue(@as(jchar, 'A')),
            jvalue.toJValue(@as(jshort, 9999)),
            jvalue.toJValue(@as(jint, 999_999)),
            jvalue.toJValue(@as(jlong, 9_999_999_999)),
            jvalue.toJValue(@as(jfloat, 9.99)),
            jvalue.toJValue(@as(jdouble, 9.99)),
            jvalue.toJValue(obj),
        },
    );

    defer env.callStaticMethod(
        .void,
        testClass,
        initMethodId,
        &[_]jvalue{
            jvalue.toJValue(@as(jboolean, 0)),
            jvalue.toJValue(@as(jbyte, 0)),
            jvalue.toJValue(@as(jchar, 0)),
            jvalue.toJValue(@as(jshort, 0)),
            jvalue.toJValue(@as(jint, 0)),
            jvalue.toJValue(@as(jlong, 0)),
            jvalue.toJValue(@as(jfloat, 0)),
            jvalue.toJValue(@as(jdouble, 0)),
            jvalue.toJValue(@as(jobject, null)),
        },
    ) catch unreachable;

    // Return Boolean
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticBooleanValue", "()Z");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.boolean, testClass, methodId, null);
        try testing.expect(v1 == 1);
    }

    // Return Byte
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticByteValue", "()B");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.byte, testClass, methodId, null);
        try testing.expect(v1 == 127);
    }

    // Return Char
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticCharValue", "()C");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.char, testClass, methodId, null);
        try testing.expect(v1 == 'A');
    }

    // Return Short
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticShortValue", "()S");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.short, testClass, methodId, null);
        try testing.expect(v1 == 9999);
    }

    // Return Integer
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticIntValue", "()I");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.int, testClass, methodId, null);
        try testing.expect(v1 == 999_999);
    }

    // Return Long
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticLongValue", "()J");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.long, testClass, methodId, null);
        try testing.expect(v1 == 9_999_999_999);
    }

    // Return Float
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticFloatValue", "()F");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.float, testClass, methodId, null);
        try testing.expect(v1 == 9.99);
    }

    // Return Double
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticDoubleValue", "()D");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.double, testClass, methodId, null);
        try testing.expect(v1 == 9.99);
    }

    // Return Object
    {
        var methodId = try env.getStaticMethodId(testClass, "getStaticObjectValue", "()Ljava/lang/Object;");
        try testing.expect(methodId != null);

        var v1 = try env.callStaticMethod(.object, testClass, methodId, null);
        try testing.expect(v1 != null);
        defer env.deleteReference(.local, v1);

        try testing.expect(env.isSameObject(obj, v1));
    }
}
