const std = @import("std");
const jui = @import("jui");
/// Opaque type corresponding to java/io/InputStream
pub const InputStream = opaque {
    const classpath = "java/io/InputStream";
    var class_global: jui.jclass = null;
    var fields: struct {
        @"MAX_SKIP_BUFFER_SIZE_I": jui.jfieldID,
        @"DEFAULT_BUFFER_SIZE_I": jui.jfieldID,
        @"MAX_BUFFER_SIZE_I": jui.jfieldID,
    } = undefined;
    var methods: struct {
        @"<init>()V": jui.jmethodID,
        @"nullInputStream()Ljava/io/InputStream;": jui.jmethodID,
        @"read()I": jui.jmethodID,
        @"read([B)I": jui.jmethodID,
        @"read([BII)I": jui.jmethodID,
        @"readAllBytes()[B": jui.jmethodID,
        @"readNBytes(I)[B": jui.jmethodID,
        @"readNBytes([BII)I": jui.jmethodID,
        @"skip(J)J": jui.jmethodID,
        @"skipNBytes(J)V": jui.jmethodID,
        @"available()I": jui.jmethodID,
        @"close()V": jui.jmethodID,
        @"mark(I)V": jui.jmethodID,
        @"reset()V": jui.jmethodID,
        @"markSupported()Z": jui.jmethodID,
        @"transferTo(Ljava/io/OutputStream;)J": jui.jmethodID,
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
                _run(_env) catch |e| { _err = e; };
            }

            fn _run(inner_env: *jui.JNIEnv) !void {
                const class_local = try inner_env.findClass(classpath);
                class_global = try inner_env.newReference(.global, class_local);
                const class = class_global orelse return error.NoClassDefFoundError;
                // 
                fields = .{
                    .@"MAX_SKIP_BUFFER_SIZE_I" = try inner_env.getStaticFieldId(class, "MAX_SKIP_BUFFER_SIZE", "I"),
                    .@"DEFAULT_BUFFER_SIZE_I" = try inner_env.getStaticFieldId(class, "DEFAULT_BUFFER_SIZE", "I"),
                    .@"MAX_BUFFER_SIZE_I" = try inner_env.getStaticFieldId(class, "MAX_BUFFER_SIZE", "I"),
                };
                methods = .{
                    .@"<init>()V" = try inner_env.getMethodId(class, "<init>", "()V"),
                    .@"nullInputStream()Ljava/io/InputStream;" = try inner_env.getStaticMethodId(class, "nullInputStream", "()Ljava/io/InputStream;"),
                    .@"read()I" = try inner_env.getMethodId(class, "read", "()I"),
                    .@"read([B)I" = try inner_env.getMethodId(class, "read", "([B)I"),
                    .@"read([BII)I" = try inner_env.getMethodId(class, "read", "([BII)I"),
                    .@"readAllBytes()[B" = try inner_env.getMethodId(class, "readAllBytes", "()[B"),
                    .@"readNBytes(I)[B" = try inner_env.getMethodId(class, "readNBytes", "(I)[B"),
                    .@"readNBytes([BII)I" = try inner_env.getMethodId(class, "readNBytes", "([BII)I"),
                    .@"skip(J)J" = try inner_env.getMethodId(class, "skip", "(J)J"),
                    .@"skipNBytes(J)V" = try inner_env.getMethodId(class, "skipNBytes", "(J)V"),
                    .@"available()I" = try inner_env.getMethodId(class, "available", "()I"),
                    .@"close()V" = try inner_env.getMethodId(class, "close", "()V"),
                    .@"mark(I)V" = try inner_env.getMethodId(class, "mark", "(I)V"),
                    .@"reset()V" = try inner_env.getMethodId(class, "reset", "()V"),
                    .@"markSupported()Z" = try inner_env.getMethodId(class, "markSupported", "()Z"),
                    .@"transferTo(Ljava/io/OutputStream;)J" = try inner_env.getMethodId(class, "transferTo", "(Ljava/io/OutputStream;)J"),
                };

            }
        }._load(env) catch |e| return e;
    }
    pub fn @"get_MAX_SKIP_BUFFER_SIZE_I"(env: *jui.JNIEnv) !jui.jint {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.int, class, fields.@"MAX_SKIP_BUFFER_SIZE_I");
    }
    pub fn @"get_DEFAULT_BUFFER_SIZE_I"(env: *jui.JNIEnv) !jui.jint {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.int, class, fields.@"DEFAULT_BUFFER_SIZE_I");
    }
    pub fn @"get_MAX_BUFFER_SIZE_I"(env: *jui.JNIEnv) !jui.jint {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.int, class, fields.@"MAX_BUFFER_SIZE_I");
    }
    pub fn @"<init>()V"(env: *jui.JNIEnv) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>()V", null));
    }
    pub fn @"nullInputStream()Ljava/io/InputStream;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"nullInputStream()Ljava/io/InputStream;", null);
    }
    pub fn @"read()I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, self, methods.@"read()I", null);
    }
    pub fn @"read([B)I"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, self, methods.@"read([B)I", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"read([BII)I"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray, arg1: jui.jint, arg2: jui.jint) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, self, methods.@"read([BII)I", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"readAllBytes()[B"(self: *@This(), env: *jui.JNIEnv) !jui.jarray {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.array, self, methods.@"readAllBytes()[B", null);
    }
    pub fn @"readNBytes(I)[B"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jarray {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.array, self, methods.@"readNBytes(I)[B", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"readNBytes([BII)I"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray, arg1: jui.jint, arg2: jui.jint) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, self, methods.@"readNBytes([BII)I", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"skip(J)J"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jlong) !jui.jlong {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.long, self, methods.@"skip(J)J", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"skipNBytes(J)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jlong) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, self, methods.@"skipNBytes(J)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"available()I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, self, methods.@"available()I", null);
    }
    pub fn @"close()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, self, methods.@"close()V", null);
    }
    pub fn @"mark(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, self, methods.@"mark(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"reset()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, self, methods.@"reset()V", null);
    }
    pub fn @"markSupported()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, self, methods.@"markSupported()Z", null);
    }
    pub fn @"transferTo(Ljava/io/OutputStream;)J"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jlong {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.long, self, methods.@"transferTo(Ljava/io/OutputStream;)J", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }

};
