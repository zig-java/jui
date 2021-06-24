const std = @import("std");

pub usingnamespace @import("types.zig");

pub fn exportAs(comptime name: []const u8, function: anytype) void {
    var z: [name.len]u8 = undefined;
    for (name) |v, i| z[i] = switch (v) {
        '.' => '_',
        else => v,
    };

    @export(function, .{ .name = "Java_" ++ &z, .linkage = .Strong });
}

// This should work in theory but it doesn't, huh.
// pub fn exportUnder(comptime class_name: []const u8, functions: anytype) void {
//     inline for (std.meta.declarations(functions)) |decl| {
//         if (!decl.is_pub) continue;
//         switch (decl.data) {
//             .Var => |v| if (@typeInfo(v) == .Fn) exportAs(class_name ++ "." ++ decl.name, v),
//             .Fn => |f| exportAs(class_name ++ "." ++ decl.name, f.fn_type),
//             else => continue,
//         }
//     }
// }

fn splitError(comptime T: std.builtin.TypeInfo) struct { error_set: ?type = null, payload: type } {
    return switch (T) {
        .ErrorUnion => |u| .{ .error_set = u.error_set, .payload = u.payload },
        else => .{ .payload = T },
    };
}

pub fn wrapErrors(function: anytype, args: anytype) splitError(@typeInfo(@typeInfo(@TypeOf(function)).Fn.return_type.?)).payload {
    const se = splitError(@typeInfo(@typeInfo(@TypeOf(function)).Fn.return_type.?));
    var env: *JNIEnv = args[0];

    if (se.error_set) |set| {
        return @call(.{}, function, args) catch |err| {
            var buf: [512]u8 = undefined;
            var msg = std.fmt.bufPrint(&buf, "Zig Error Encountered: {s}", .{err}) catch unreachable;
            env.throwGeneric(@ptrCast([*c]const u8, msg)) catch unreachable;
            return null;
        };
    } else {
        return @call(.{}, function, args);
    }
}
