const std = @import("std");
const jui = @import("jui");

fn greet(env: *jui.JNIEnv, class: jui.jclass) !jui.jstring {
    _ = class;

    var reflector = jui.Reflector.init(std.heap.page_allocator, env);

    var System = try reflector.getClass("java/lang/System");
    var lineSep = try System.getStaticMethod("lineSeparator", fn () jui.Reflector.StringType);

    var str = try lineSep.call(.{});

    var chars = try env.getStringUTFChars(str);
    defer env.releaseStringUTFChars(str, chars.chars);

    var length = env.getStringUTFLength(str);

    var buf: [256]u8 = undefined;
    return try env.newStringUTF(try std.fmt.bufPrintZ(&buf, "Hello, your system's newline chars are: {d}", .{chars.chars[0..@intCast(usize, length)]}));
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
