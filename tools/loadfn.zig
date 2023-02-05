    pub fn load(env: *jui.JNIEnv) !void {{
        struct {{
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

            fn _load(arg: *jui.JNIEnv) !void {{
                _env = arg;
                runner.call();
                if (_err) |e| return e;
            }}

            fn _runner() void {{
                _run(_env) catch |e| {{ _err = e; }};
            }}

            fn _run(inner_env: *jui.JNIEnv) !void {{
                const class_local = try inner_env.findClass(classpath);
                class_global = try inner_env.newReference(.global, class_local);
                const class = class_global orelse return error.NoClassDefFoundError;
                // {[load_entry]s}
            }}
        }}._load(env) catch |e| return e;
    }}
