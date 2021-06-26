const std = @import("std");
const jui = @import("jui");

fn greet(env: *jui.JNIEnv, class: jui.jclass) !jui.jstring {
    _ = env;
    _ = class;

    var buf: [256]u8 = undefined;
    var jni_version = env.getJNIVersion();

    var out = try std.fmt.bufPrintZ(&buf, "Hello from Zig v{} running in {s}", .{ std.builtin.zig_version, jni_version });
    return env.newStringUTF(out);
}

comptime {
    const wrapped = struct {
        fn greetWrapped(env: *jui.JNIEnv, class: jui.jclass) callconv(.C) jui.jstring {
            return jui.wrapErrors(greet, .{ env, class });
        }
    };

    jui.exportUnder("com.jui.JNIExample", .{
        // .onLoad = onLoad,
        .greet = wrapped.greetWrapped,
    });
}
