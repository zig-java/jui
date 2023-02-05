const std = @import("std");
const jui = @import("jui");
/// Opaque type corresponding to java/io/PrintStream
pub const PrintStream = opaque {
    const classpath = "java/io/PrintStream";
    var class_global: jui.jclass = null;
    var fields: struct {
        @"lock_Ljdk/internal/misc/InternalLock;": jui.jfieldID,
        @"autoFlush_Z": jui.jfieldID,
        @"trouble_Z": jui.jfieldID,
        @"formatter_Ljava/util/Formatter;": jui.jfieldID,
        @"charset_Ljava/nio/charset/Charset;": jui.jfieldID,
        @"textOut_Ljava/io/BufferedWriter;": jui.jfieldID,
        @"charOut_Ljava/io/OutputStreamWriter;": jui.jfieldID,
        @"closing_Z": jui.jfieldID,
    } = undefined;
    var methods: struct {
        @"requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;": jui.jmethodID,
        @"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;": jui.jmethodID,
        @"<init>(ZLjava/io/OutputStream;)V": jui.jmethodID,
        @"<init>(ZLjava/nio/charset/Charset;Ljava/io/OutputStream;)V": jui.jmethodID,
        @"<init>(Ljava/io/OutputStream;)V": jui.jmethodID,
        @"<init>(Ljava/io/OutputStream;Z)V": jui.jmethodID,
        @"<init>(Ljava/io/OutputStream;ZLjava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/io/OutputStream;ZLjava/nio/charset/Charset;)V": jui.jmethodID,
        @"<init>(Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/lang/String;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/lang/String;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"ensureOpen()V": jui.jmethodID,
        @"flush()V": jui.jmethodID,
        @"implFlush()V": jui.jmethodID,
        @"close()V": jui.jmethodID,
        @"implClose()V": jui.jmethodID,
        @"checkError()Z": jui.jmethodID,
        @"setError()V": jui.jmethodID,
        @"clearError()V": jui.jmethodID,
        @"write(I)V": jui.jmethodID,
        @"implWrite(I)V": jui.jmethodID,
        @"write([BII)V": jui.jmethodID,
        @"implWrite([BII)V": jui.jmethodID,
        @"write([B)V": jui.jmethodID,
        @"writeBytes([B)V": jui.jmethodID,
        @"write([C)V": jui.jmethodID,
        @"implWrite([C)V": jui.jmethodID,
        @"writeln([C)V": jui.jmethodID,
        @"implWriteln([C)V": jui.jmethodID,
        @"write(Ljava/lang/String;)V": jui.jmethodID,
        @"implWrite(Ljava/lang/String;)V": jui.jmethodID,
        @"writeln(Ljava/lang/String;)V": jui.jmethodID,
        @"implWriteln(Ljava/lang/String;)V": jui.jmethodID,
        @"newLine()V": jui.jmethodID,
        @"implNewLine()V": jui.jmethodID,
        @"print(Z)V": jui.jmethodID,
        @"print(C)V": jui.jmethodID,
        @"print(I)V": jui.jmethodID,
        @"print(J)V": jui.jmethodID,
        @"print(F)V": jui.jmethodID,
        @"print(D)V": jui.jmethodID,
        @"print([C)V": jui.jmethodID,
        @"print(Ljava/lang/String;)V": jui.jmethodID,
        @"print(Ljava/lang/Object;)V": jui.jmethodID,
        @"println()V": jui.jmethodID,
        @"println(Z)V": jui.jmethodID,
        @"println(C)V": jui.jmethodID,
        @"println(I)V": jui.jmethodID,
        @"println(J)V": jui.jmethodID,
        @"println(F)V": jui.jmethodID,
        @"println(D)V": jui.jmethodID,
        @"println([C)V": jui.jmethodID,
        @"println(Ljava/lang/String;)V": jui.jmethodID,
        @"println(Ljava/lang/Object;)V": jui.jmethodID,
        @"printf(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;": jui.jmethodID,
        @"printf(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;": jui.jmethodID,
        @"format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;": jui.jmethodID,
        @"implFormat(Ljava/lang/String;[Ljava/lang/Object;)V": jui.jmethodID,
        @"format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;": jui.jmethodID,
        @"implFormat(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)V": jui.jmethodID,
        @"append(Ljava/lang/CharSequence;)Ljava/io/PrintStream;": jui.jmethodID,
        @"append(Ljava/lang/CharSequence;II)Ljava/io/PrintStream;": jui.jmethodID,
        @"append(C)Ljava/io/PrintStream;": jui.jmethodID,
        @"charset()Ljava/nio/charset/Charset;": jui.jmethodID,
        @"append(C)Ljava/lang/Appendable;": jui.jmethodID,
        @"append(Ljava/lang/CharSequence;II)Ljava/lang/Appendable;": jui.jmethodID,
        @"append(Ljava/lang/CharSequence;)Ljava/lang/Appendable;": jui.jmethodID,
        @"<clinit>()V": jui.jmethodID,
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
                    .@"lock_Ljdk/internal/misc/InternalLock;" = try inner_env.getFieldId(class, "lock", "Ljdk/internal/misc/InternalLock;"),
                    .@"autoFlush_Z" = try inner_env.getFieldId(class, "autoFlush", "Z"),
                    .@"trouble_Z" = try inner_env.getFieldId(class, "trouble", "Z"),
                    .@"formatter_Ljava/util/Formatter;" = try inner_env.getFieldId(class, "formatter", "Ljava/util/Formatter;"),
                    .@"charset_Ljava/nio/charset/Charset;" = try inner_env.getFieldId(class, "charset", "Ljava/nio/charset/Charset;"),
                    .@"textOut_Ljava/io/BufferedWriter;" = try inner_env.getFieldId(class, "textOut", "Ljava/io/BufferedWriter;"),
                    .@"charOut_Ljava/io/OutputStreamWriter;" = try inner_env.getFieldId(class, "charOut", "Ljava/io/OutputStreamWriter;"),
                    .@"closing_Z" = try inner_env.getFieldId(class, "closing", "Z"),
                };
                methods = .{
                    .@"requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;" = try inner_env.getStaticMethodId(class, "requireNonNull", "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;"),
                    .@"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;" = try inner_env.getStaticMethodId(class, "toCharset", "(Ljava/lang/String;)Ljava/nio/charset/Charset;"),
                    .@"<init>(ZLjava/io/OutputStream;)V" = try inner_env.getMethodId(class, "<init>", "(ZLjava/io/OutputStream;)V"),
                    .@"<init>(ZLjava/nio/charset/Charset;Ljava/io/OutputStream;)V" = try inner_env.getMethodId(class, "<init>", "(ZLjava/nio/charset/Charset;Ljava/io/OutputStream;)V"),
                    .@"<init>(Ljava/io/OutputStream;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/OutputStream;)V"),
                    .@"<init>(Ljava/io/OutputStream;Z)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/OutputStream;Z)V"),
                    .@"<init>(Ljava/io/OutputStream;ZLjava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/OutputStream;ZLjava/lang/String;)V"),
                    .@"<init>(Ljava/io/OutputStream;ZLjava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/OutputStream;ZLjava/nio/charset/Charset;)V"),
                    .@"<init>(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/String;)V"),
                    .@"<init>(Ljava/lang/String;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/String;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/lang/String;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/String;Ljava/nio/charset/Charset;)V"),
                    .@"<init>(Ljava/io/File;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;)V"),
                    .@"<init>(Ljava/io/File;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;Ljava/nio/charset/Charset;)V"),
                    .@"ensureOpen()V" = try inner_env.getMethodId(class, "ensureOpen", "()V"),
                    .@"flush()V" = try inner_env.getMethodId(class, "flush", "()V"),
                    .@"implFlush()V" = try inner_env.getMethodId(class, "implFlush", "()V"),
                    .@"close()V" = try inner_env.getMethodId(class, "close", "()V"),
                    .@"implClose()V" = try inner_env.getMethodId(class, "implClose", "()V"),
                    .@"checkError()Z" = try inner_env.getMethodId(class, "checkError", "()Z"),
                    .@"setError()V" = try inner_env.getMethodId(class, "setError", "()V"),
                    .@"clearError()V" = try inner_env.getMethodId(class, "clearError", "()V"),
                    .@"write(I)V" = try inner_env.getMethodId(class, "write", "(I)V"),
                    .@"implWrite(I)V" = try inner_env.getMethodId(class, "implWrite", "(I)V"),
                    .@"write([BII)V" = try inner_env.getMethodId(class, "write", "([BII)V"),
                    .@"implWrite([BII)V" = try inner_env.getMethodId(class, "implWrite", "([BII)V"),
                    .@"write([B)V" = try inner_env.getMethodId(class, "write", "([B)V"),
                    .@"writeBytes([B)V" = try inner_env.getMethodId(class, "writeBytes", "([B)V"),
                    .@"write([C)V" = try inner_env.getMethodId(class, "write", "([C)V"),
                    .@"implWrite([C)V" = try inner_env.getMethodId(class, "implWrite", "([C)V"),
                    .@"writeln([C)V" = try inner_env.getMethodId(class, "writeln", "([C)V"),
                    .@"implWriteln([C)V" = try inner_env.getMethodId(class, "implWriteln", "([C)V"),
                    .@"write(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "write", "(Ljava/lang/String;)V"),
                    .@"implWrite(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "implWrite", "(Ljava/lang/String;)V"),
                    .@"writeln(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "writeln", "(Ljava/lang/String;)V"),
                    .@"implWriteln(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "implWriteln", "(Ljava/lang/String;)V"),
                    .@"newLine()V" = try inner_env.getMethodId(class, "newLine", "()V"),
                    .@"implNewLine()V" = try inner_env.getMethodId(class, "implNewLine", "()V"),
                    .@"print(Z)V" = try inner_env.getMethodId(class, "print", "(Z)V"),
                    .@"print(C)V" = try inner_env.getMethodId(class, "print", "(C)V"),
                    .@"print(I)V" = try inner_env.getMethodId(class, "print", "(I)V"),
                    .@"print(J)V" = try inner_env.getMethodId(class, "print", "(J)V"),
                    .@"print(F)V" = try inner_env.getMethodId(class, "print", "(F)V"),
                    .@"print(D)V" = try inner_env.getMethodId(class, "print", "(D)V"),
                    .@"print([C)V" = try inner_env.getMethodId(class, "print", "([C)V"),
                    .@"print(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "print", "(Ljava/lang/String;)V"),
                    .@"print(Ljava/lang/Object;)V" = try inner_env.getMethodId(class, "print", "(Ljava/lang/Object;)V"),
                    .@"println()V" = try inner_env.getMethodId(class, "println", "()V"),
                    .@"println(Z)V" = try inner_env.getMethodId(class, "println", "(Z)V"),
                    .@"println(C)V" = try inner_env.getMethodId(class, "println", "(C)V"),
                    .@"println(I)V" = try inner_env.getMethodId(class, "println", "(I)V"),
                    .@"println(J)V" = try inner_env.getMethodId(class, "println", "(J)V"),
                    .@"println(F)V" = try inner_env.getMethodId(class, "println", "(F)V"),
                    .@"println(D)V" = try inner_env.getMethodId(class, "println", "(D)V"),
                    .@"println([C)V" = try inner_env.getMethodId(class, "println", "([C)V"),
                    .@"println(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "println", "(Ljava/lang/String;)V"),
                    .@"println(Ljava/lang/Object;)V" = try inner_env.getMethodId(class, "println", "(Ljava/lang/Object;)V"),
                    .@"printf(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "printf", "(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"),
                    .@"printf(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "printf", "(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"),
                    .@"format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "format", "(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"),
                    .@"implFormat(Ljava/lang/String;[Ljava/lang/Object;)V" = try inner_env.getMethodId(class, "implFormat", "(Ljava/lang/String;[Ljava/lang/Object;)V"),
                    .@"format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "format", "(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"),
                    .@"implFormat(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)V" = try inner_env.getMethodId(class, "implFormat", "(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)V"),
                    .@"append(Ljava/lang/CharSequence;)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "append", "(Ljava/lang/CharSequence;)Ljava/io/PrintStream;"),
                    .@"append(Ljava/lang/CharSequence;II)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "append", "(Ljava/lang/CharSequence;II)Ljava/io/PrintStream;"),
                    .@"append(C)Ljava/io/PrintStream;" = try inner_env.getMethodId(class, "append", "(C)Ljava/io/PrintStream;"),
                    .@"charset()Ljava/nio/charset/Charset;" = try inner_env.getMethodId(class, "charset", "()Ljava/nio/charset/Charset;"),
                    .@"append(C)Ljava/lang/Appendable;" = try inner_env.getMethodId(class, "append", "(C)Ljava/lang/Appendable;"),
                    .@"append(Ljava/lang/CharSequence;II)Ljava/lang/Appendable;" = try inner_env.getMethodId(class, "append", "(Ljava/lang/CharSequence;II)Ljava/lang/Appendable;"),
                    .@"append(Ljava/lang/CharSequence;)Ljava/lang/Appendable;" = try inner_env.getMethodId(class, "append", "(Ljava/lang/CharSequence;)Ljava/lang/Appendable;"),
                    .@"<clinit>()V" = try inner_env.getStaticMethodId(class, "<clinit>", "()V"),
                };

            }
        }._load(env) catch |e| return e;
    }
    pub fn @"get_lock_Ljdk/internal/misc/InternalLock;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"lock_Ljdk/internal/misc/InternalLock;");
    }
    pub fn @"get_autoFlush_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"autoFlush_Z");
    }
    pub fn @"get_trouble_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"trouble_Z");
    }
    pub fn @"set_trouble_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"trouble_Z", arg);
    }
    pub fn @"get_formatter_Ljava/util/Formatter;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"formatter_Ljava/util/Formatter;");
    }
    pub fn @"set_formatter_Ljava/util/Formatter;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"formatter_Ljava/util/Formatter;", arg);
    }
    pub fn @"get_charset_Ljava/nio/charset/Charset;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"charset_Ljava/nio/charset/Charset;");
    }
    pub fn @"get_textOut_Ljava/io/BufferedWriter;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"textOut_Ljava/io/BufferedWriter;");
    }
    pub fn @"set_textOut_Ljava/io/BufferedWriter;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"textOut_Ljava/io/BufferedWriter;", arg);
    }
    pub fn @"get_charOut_Ljava/io/OutputStreamWriter;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"charOut_Ljava/io/OutputStreamWriter;");
    }
    pub fn @"set_charOut_Ljava/io/OutputStreamWriter;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"charOut_Ljava/io/OutputStreamWriter;", arg);
    }
    pub fn @"get_closing_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"closing_Z");
    }
    pub fn @"set_closing_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"closing_Z", arg);
    }
    pub fn @"requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;"(env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"<init>(ZLjava/io/OutputStream;)V"(env: *jui.JNIEnv, arg0: jui.jboolean, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(ZLjava/io/OutputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(ZLjava/nio/charset/Charset;Ljava/io/OutputStream;)V"(env: *jui.JNIEnv, arg0: jui.jboolean, arg1: jui.jobject, arg2: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(ZLjava/nio/charset/Charset;Ljava/io/OutputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)}));
    }
    pub fn @"<init>(Ljava/io/OutputStream;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/OutputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/io/OutputStream;Z)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jboolean) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/OutputStream;Z)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/OutputStream;ZLjava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jboolean, arg2: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/OutputStream;ZLjava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)}));
    }
    pub fn @"<init>(Ljava/io/OutputStream;ZLjava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jboolean, arg2: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/OutputStream;ZLjava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)}));
    }
    pub fn @"<init>(Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/lang/String;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/String;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/lang/String;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/String;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/File;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/io/File;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"ensureOpen()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"ensureOpen()V", null);
    }
    pub fn @"flush()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"flush()V", null);
    }
    pub fn @"implFlush()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implFlush()V", null);
    }
    pub fn @"close()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"close()V", null);
    }
    pub fn @"implClose()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implClose()V", null);
    }
    pub fn @"checkError()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"checkError()Z", null);
    }
    pub fn @"setError()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"setError()V", null);
    }
    pub fn @"clearError()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"clearError()V", null);
    }
    pub fn @"write(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"write(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"implWrite(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWrite(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"write([BII)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray, arg1: jui.jint, arg2: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"write([BII)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"implWrite([BII)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray, arg1: jui.jint, arg2: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWrite([BII)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"write([B)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"write([B)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"writeBytes([B)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"writeBytes([B)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"write([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"write([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"implWrite([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWrite([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"writeln([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"writeln([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"implWriteln([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWriteln([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"write(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"write(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"implWrite(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWrite(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"writeln(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"writeln(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"implWriteln(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implWriteln(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"newLine()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"newLine()V", null);
    }
    pub fn @"implNewLine()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implNewLine()V", null);
    }
    pub fn @"print(Z)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(Z)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jchar) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(J)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jlong) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(J)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(F)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jfloat) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(F)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(D)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jdouble) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(D)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"print(Ljava/lang/Object;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"print(Ljava/lang/Object;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println()V", null);
    }
    pub fn @"println(Z)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(Z)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jchar) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(J)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jlong) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(J)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(F)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jfloat) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(F)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(D)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jdouble) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(D)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println([C)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println([C)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"println(Ljava/lang/Object;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"println(Ljava/lang/Object;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"printf(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jarray) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"printf(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"printf(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject, arg2: jui.jarray) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"printf(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jarray) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"implFormat(Ljava/lang/String;[Ljava/lang/Object;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implFormat(Ljava/lang/String;[Ljava/lang/Object;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject, arg2: jui.jarray) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"format(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"implFormat(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject, arg2: jui.jarray) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"implFormat(Ljava/util/Locale;Ljava/lang/String;[Ljava/lang/Object;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"append(Ljava/lang/CharSequence;)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(Ljava/lang/CharSequence;)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"append(Ljava/lang/CharSequence;II)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jint, arg2: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(Ljava/lang/CharSequence;II)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"append(C)Ljava/io/PrintStream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jchar) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(C)Ljava/io/PrintStream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"charset()Ljava/nio/charset/Charset;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"charset()Ljava/nio/charset/Charset;", null);
    }
    pub fn @"append(C)Ljava/lang/Appendable;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jchar) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(C)Ljava/lang/Appendable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"append(Ljava/lang/CharSequence;II)Ljava/lang/Appendable;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jint, arg2: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(Ljava/lang/CharSequence;II)Ljava/lang/Appendable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1), jui.jvalue.toJValue(arg2)});
    }
    pub fn @"append(Ljava/lang/CharSequence;)Ljava/lang/Appendable;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"append(Ljava/lang/CharSequence;)Ljava/lang/Appendable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"<clinit>()V"(env: *jui.JNIEnv) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.void, class, methods.@"<clinit>()V", null);
    }

};
