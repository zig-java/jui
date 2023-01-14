const std = @import("std");
const jui = @import("jui");

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

const InputStream = opaque {
    var class_global: ?jui.jclass = null;

    pub fn load(env: *jui.JNIEnv) !void {
        const class_local = try env.findClass("java/io/InputStream");
        class_global = try env.newReference(.global, class_local);
        if (class_global) |_| {} else {
            return error.ClassNotFound;
        }
    }

    pub fn unload(env: *jui.JNIEnv) void {
        if (class_global) |class| {
            env.deleteReference(.global, class);
            class_global = null;
        }
    }
};

const PrintStream = opaque {
    var class_global: ?jui.jclass = null;
    var methods: struct {
        @"print(I)V": jui.jmethodID,
        printf: jui.jmethodID,
        @"print(Ljava/lang/Object;)V": jui.jmethodID,
    } = undefined;

    pub fn load(env: *jui.JNIEnv) !void {
        const class_local = try env.findClass("java/io/PrintStream");
        class_global = try env.newReference(.global, class_local);
        if (class_global) |class| {
            methods = .{
                .@"print(I)V" = try env.getMethodId(class, "print", "(I)V"),
                .printf = try env.getMethodId(class, "printf", "(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"),
                .@"print(Ljava/lang/Object;)V" = try env.getMethodId(class, "print", "(Ljava/lang/Object;)V"),
            };
        } else {
            return error.ClassNotFound;
        }
    }

    pub fn unload(env: *jui.JNIEnv) void {
        if (class_global) |class| {
            env.deleteReference(.global, class);
            class_global = null;
        }
    }

    pub fn print(self: *PrintStream, env: *jui.JNIEnv, i: jui.jint) !void {
        const class = class_global orelse return error.ClassNotLoaded;
        _ = class;
        try env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(i)});
    }

    pub fn @"print(Ljava/lang/Object;)V"(self: *PrintStream, env: *jui.JNIEnv, obj: jui.jobject) !void {
        const class = class_global orelse return error.ClassNotLoaded;
        _ = class;
        try env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(Ljava/lang/Object;)V", &[_]jui.jvalue{jui.jvalue.toJValue(obj)});
    }
};

const Scanner = opaque {
    var class_global: ?jui.jclass = null;
    var constructors: struct {
        @"(Ljava/io/InputStream;)V": jui.jmethodID,
    } = undefined;
    var methods: struct {
        nextInt: jui.jmethodID,
    } = undefined;

    pub fn load(env: *jui.JNIEnv) !void {
        const class_local = try env.findClass("java/util/Scanner");
        class_global = try env.newReference(.global, class_local);
        if (class_global) |class| {
            constructors = .{
                .@"(Ljava/io/InputStream;)V" = try env.getMethodId(class, "<init>", "(Ljava/io/InputStream;)V"),
            };
            methods = .{
                .nextInt = try env.getMethodId(class, "nextInt", "()I"),
            };
        } else {
            return error.ClassNotFound;
        }
    }

    pub fn unload(env: *jui.JNIEnv) void {
        if (class_global) |class| {
            env.deleteReference(.global, class);
            class_global = null;
        }
    }

    pub fn create(env: *jui.JNIEnv, input_stream: *InputStream) !*Scanner {
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*Scanner, try env.newObject(class, constructors.@"(Ljava/io/InputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(@ptrCast(jui.jobject, input_stream))}));
    }

    pub fn nextInt(self: *Scanner, env: *jui.JNIEnv) !jui.jint {
        const class = class_global orelse return error.ClassNotLoaded;
        _ = class;
        return try env.callMethod(.int, @ptrCast(jui.jobject, self), methods.nextInt, null);
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

    var scanner = try Scanner.create(env, in);
    try out.@"print(Ljava/lang/Object;)V"(env, @ptrCast(jui.jobject, scanner));

    const int = try scanner.nextInt(env);
    try out.print(env, int);
}
