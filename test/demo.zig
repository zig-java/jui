const std = @import("std");
const jui = @import("jui");

fn greet(env: *jui.JNIEnv, class: jui.jclass) !jui.jstring {
    _ = class;

    var buf: [256]u8 = undefined;

    var math = try env.findClass("java/lang/Math");
    var random = try env.getStaticMethodId(math, "random", "()D");

    var inv = try env.callStaticMethod(.double, math, random, null);

    var out = try std.fmt.bufPrintZ(&buf, "Here's a random number: {d}", .{inv * 100});
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
