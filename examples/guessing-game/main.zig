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
        const class_local = try env.findClass("java/lang/System");
        class_global = try env.newReference(.global, class_local);
        if (class_global) |class| {
            static_fields = .{
                .in = try env.getStaticFieldId(class, "in", "Ljava/io/InputStream;"),
                .out = try env.getStaticFieldId(class, "out", "Ljava/io/PrintStream;"),
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

    pub fn getIn(env: *jui.JNIEnv) !*InputStream {
        const class = class_global orelse return error.ClasNotFound;
        return @ptrCast(*InputStream, env.getStaticField(.object, class, static_fields.in));
    }

    pub fn getOut(env: *jui.JNIEnv) !*PrintStream {
        const class = class_global orelse return error.ClasNotFound;
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
        // printf: jui.jmethodID,
    } = undefined;

    pub fn load(env: *jui.JNIEnv) !void {
        const class_local = try env.findClass("java/io/PrintStream");
        class_global = try env.newReference(.global, class_local);
        if (class_global) |class| {
            methods = .{
                .@"print(I)V" = try env.getMethodId(class, "print", "(I)V"),
                // .printf = try env.getMethodId(class, "printf", "(Ljava/lang/String;[java/lang/Object;)V"),
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
        const class = class_global orelse return error.ClasNotLoaded;
        _ = class;
        try env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(i)});
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
        const class = class_global orelse return error.ClasNotLoaded;
        return @ptrCast(*Scanner, try env.newObject(class, constructors.@"(Ljava/io/InputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(@ptrCast(jui.jobject, input_stream))}));
    }

    pub fn nextInt(self: *Scanner, env: *jui.JNIEnv) !jui.jint {
        const class = class_global orelse return error.ClasNotLoaded;
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
    const system_input_stream = try System.getIn(env);

    var scanner = try Scanner.create(env, system_input_stream);
    const int = try scanner.nextInt(env);

    std.log.info("Entered int: {}", .{int});
}
