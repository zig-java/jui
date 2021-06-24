const std = @import("std");
const jui = @import("jui");

fn greetWrapped(env: *jui.JNIEnv, class: jui.jclass) callconv(.C) jui.jstring {
    return jui.wrapErrors(greet, .{ env, class });
}

fn greet(env: *jui.JNIEnv, class: jui.jclass) !jui.jstring {
    var buf: [256]u8 = undefined;
    var jni_version = try env.getJNIVersion();

    var out = try std.fmt.bufPrintZ(&buf, "Hello from Zig v{} running in {s}", .{ std.builtin.zig_version, jni_version });
    return env.newStringUTF(out);
}

comptime {
    jui.exportAs("com.jui.JNIExample.greet", greetWrapped);
}
