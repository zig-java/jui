const std = @import("std");
const jui = @import("jui");

var reflector: jui.Reflector = undefined;

fn onLoad(vm: *jui.JavaVM) !jui.jint {
    const version = jui.JNIVersion{ .major = 10, .minor = 0 };
    reflector = jui.Reflector.init(std.heap.page_allocator, try vm.getEnv(version));
    return @bitCast(jui.jint, version);
}

fn onUnload(vm: *jui.JavaVM) void {
    _ = vm;
}

fn greet(env: *jui.JNIEnv, this_object: jui.jobject) !jui.jstring {
    _ = this_object;

    var System = try reflector.getClass("java/lang/Integer");
    var toString = try System.getStaticMethod("toString", fn (int: jui.jint) jui.Reflector.String);
    var str = try toString.call(.{12});

    var chars = try env.getStringUTFChars(str);
    defer env.releaseStringUTFChars(str, chars.chars);

    var length = env.getStringUTFLength(str);

    var buf: [256]u8 = undefined;
    return try env.newStringUTF(try std.fmt.bufPrintZ(&buf, "Your number toString-ed is: {s}", .{chars.chars[0..@intCast(usize, length)]}));
}

comptime {
    const wrapped = struct {
        fn onLoadWrapped(vm: *jui.JavaVM) callconv(.C) jui.jint {
            return jui.wrapErrors(onLoad, .{vm});
        }

        fn onUnloadWrapped(vm: *jui.JavaVM) callconv(.C) void {
            return jui.wrapErrors(onUnload, .{vm});
        }

        fn greetWrapped(env: *jui.JNIEnv, class: jui.jclass) callconv(.C) jui.jstring {
            return jui.wrapErrors(greet, .{ env, class });
        }
    };

    jui.exportUnder("com.jui.JNIExample", .{
        .onLoad = wrapped.onLoadWrapped,
        .onUnload = wrapped.onUnloadWrapped,
        .greet = wrapped.greetWrapped,
    });
}
