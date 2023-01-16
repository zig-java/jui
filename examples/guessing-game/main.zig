const std = @import("std");
const jui = @import("jui");
const Scanner = @import("gen/java/util/Scanner.zig").Scanner;
const InputStream = @import("gen/java/io/InputStream.zig").InputStream;
const PrintStream = @import("gen/java/io/PrintStream.zig").PrintStream;

const Descriptor = jui.descriptors.Descriptor;

const System = opaque {
    var class_global: ?jui.jclass = null;
    var static_fields: struct {
        in: jui.jfieldID,
        out: jui.jfieldID,
    } = undefined;

    pub fn load(env: *jui.JNIEnv) !void {
        struct {
            var runner = std.once(_runner);
            var _env: *jui.JNIEnv = undefined;
            var _err: ?Error = null;

            const Error =
                jui.JNIEnv.FindClassError ||
                jui.JNIEnv.NewReferenceError ||
                jui.JNIEnv.GetFieldIdError ||
                jui.JNIEnv.GetMethodIdError ||
                jui.JNIEnv.GetStaticFieldIdError ||
                jui.JNIEnv.GetStaticMethodIdError;

            fn _load(arg: *jui.JNIEnv) !void {
                _env = arg;
                runner.call();
                if (_err) |e| return e;
            }

            fn _runner() void {
                const class_local = _env.findClass("java/lang/System") catch |e| {
                    _err = e;
                    return;
                };
                class_global = _env.newReference(.global, class_local) catch |e| {
                    _err = e;
                    return;
                };
                if (class_global) |class| {
                    static_fields = .{
                        .in = _env.getStaticFieldId(class, "in", "Ljava/io/InputStream;") catch |e| {
                            _err = e;
                            return;
                        },
                        .out = _env.getStaticFieldId(class, "out", "Ljava/io/PrintStream;") catch |e| {
                            _err = e;
                            return;
                        },
                    };
                } else {
                    _err = error.NoClassDefFoundError;
                }
            }
        }._load(env) catch |e| return e;
    }

    pub fn unload(env: *jui.JNIEnv) void {
        if (class_global) |class| {
            env.deleteReference(.global, class);
            class_global = null;
        }
    }

    pub fn getIn(env: *jui.JNIEnv) !*InputStream {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return @ptrCast(*InputStream, env.getStaticField(.object, class, static_fields.in));
    }

    pub fn getOut(env: *jui.JNIEnv) !*PrintStream {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return @ptrCast(*PrintStream, env.getStaticField(.object, class, static_fields.out));
    }
};

pub fn main() !void {
    // Construct vm...
    const JNI_1_10 = jui.JNIVersion{ .major = 10, .minor = 0 };
    const args = jui.JavaVMInitArgs{
        .version = JNI_1_10,
        .options = &.{
            .{ .option = "-Djava.class.path=./test/src" },
        },
        .ignore_unrecognized = true,
    };
    var result = jui.JavaVM.createJavaVM(&args) catch |err| {
        std.debug.panic("Cannot create JVM {!}", .{err});
    };

    var env = result.env;
    var jvm = try env.getJavaVM();
    var created_jvm = try jui.JavaVM.getCreatedJavaVM();

    std.debug.assert(created_jvm != null);
    std.debug.assert(jvm == created_jvm.?);

    try jniMain(env);
    // jui.wrapErrors(jniMain, .{env});
}

pub fn jniMain(env: *jui.JNIEnv) !void {
    // Load classes
    try System.load(env);
    try Scanner.load(env);
    try PrintStream.load(env);
    try InputStream.load(env);

    // Use the classes!
    const in = try System.getIn(env);
    const out = try System.getOut(env);

    var scanner = try Scanner.@"<init>(Ljava/io/InputStream;)V"(env, @ptrCast(jui.jobject, in));
    try out.@"print(Ljava/lang/Object;)V"(env, @ptrCast(jui.jobject, scanner));

    const int = try scanner.@"nextInt()I"(env);
    try out.@"print(I)V"(env, int);
}
