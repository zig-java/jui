const std = @import("std");
const builtin = @import("builtin");

pub const descriptors = @import("descriptors.zig");
pub const Reflector = @import("Reflector.zig");
const types = @import("types.zig");

// We support Zig 0.9.1 (old stable), 0.10.0 (current stable) and 0.11.0-dev (latest master).
// We also support both stage1 and stage2 compilers.
// This can be simplified once we drop support for Zig 0.9.1 and stage1:
pub const is_zig_9_1 = builtin.zig_version.major >= 0 and builtin.zig_version.minor == 9;
pub const is_zig_master = builtin.zig_version.major >= 0 and builtin.zig_version.minor >= 11;
pub const is_stage2 = @hasDecl(builtin, "zig_backend") and builtin.zig_backend != .stage1;

pub usingnamespace types;

pub fn exportAs(comptime name: []const u8, function: anytype) void {
    var z: [name.len]u8 = undefined;
    for (name) |v, i| z[i] = switch (v) {
        '.' => '_',
        else => v,
    };

    @export(function, .{ .name = "Java_" ++ &z, .linkage = .Strong });
}

pub fn exportUnder(comptime class_name: []const u8, functions: anytype) void {
    inline for (std.meta.fields(@TypeOf(functions))) |field| {
        const z = @field(functions, field.name);

        if (std.mem.eql(u8, field.name, "onLoad"))
            @export(z, .{ .name = "JNI_OnLoad", .linkage = .Strong })
        else if (std.mem.eql(u8, field.name, "onUnload"))
            @export(z, .{ .name = "JNI_OnUnload", .linkage = .Strong })
        else
            exportAs(class_name ++ "." ++ field.name, z);
    }
}

fn printSourceAtAddressJava(allocator: std.mem.Allocator, debug_info: *std.debug.DebugInfo, writer: anytype, address: usize) !void {
    const module = debug_info.getModuleForAddress(address) catch |err| switch (err) {
        error.MissingDebugInfo, error.InvalidDebugInfo => {
            return try writer.writeAll((" " ** 8) ++ "at unknown (missing/invalud debug info)");
        },
        else => return err,
    };

    const symbol_info = if (comptime is_zig_master)
        try module.getSymbolAtAddress(allocator, address)
    else
        try module.getSymbolAtAddress(address);

    defer if (comptime is_zig_master) symbol_info.deinit(allocator) else symbol_info.deinit();

    if (symbol_info.line_info) |li| {
        try writer.print((" " ** 8) ++ "at {s}({s}:{d}:{d})", .{ symbol_info.symbol_name, li.file_name, li.line, li.column });
    } else {
        try writer.print((" " ** 8) ++ "at {s}({s}:unknown)", .{ symbol_info.symbol_name, symbol_info.compile_unit_name });
    }
}

fn writeStackTraceJava(
    allocator: std.mem.Allocator,
    stack_trace: std.builtin.StackTrace,
    writer: anytype,
    debug_info: *std.debug.DebugInfo,
) !void {
    if (builtin.strip_debug_info) return error.MissingDebugInfo;

    var frame_index: usize = 0;
    var frames_left: usize = std.math.min(stack_trace.index, stack_trace.instruction_addresses.len);

    while (frames_left != 0) : ({
        frames_left -= 1;
        frame_index = (frame_index + 1) % stack_trace.instruction_addresses.len;
    }) {
        const return_address = stack_trace.instruction_addresses[frame_index];
        try printSourceAtAddressJava(allocator, debug_info, writer, return_address - 1);
        if (frames_left != 1) try writer.writeByte('\n');
    }
}

fn formatStackTraceJava(writer: anytype, trace: std.builtin.StackTrace) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const debug_info = std.debug.getSelfDebugInfo() catch return;
    try writer.writeAll("\n");
    writeStackTraceJava(arena.allocator(), trace, writer, debug_info) catch |err| {
        try writer.print("Unable to print stack trace: {s}\n", .{@errorName(err)});
    };
}

// --- Code ~~stolen~~ adapted from debug.zig ends here ---

fn splitError(comptime T: type) struct { error_set: ?type = null, payload: type } {
    return switch (@typeInfo(T)) {
        .ErrorUnion => |u| .{ .error_set = u.error_set, .payload = u.payload },
        else => .{ .payload = T },
    };
}

/// NOTE: This is sadly required as @Type for Fn is not implemented so we cannot autowrap functions
pub fn wrapErrors(function: anytype, args: anytype) splitError(@typeInfo(@TypeOf(function)).Fn.return_type.?).payload {
    const se = splitError(@typeInfo(@TypeOf(function)).Fn.return_type.?);
    var env: *types.JNIEnv = undefined;

    switch (@TypeOf(args[0])) {
        *types.JNIEnv => env = args[0],
        *types.JavaVM => env = args[0].getEnv(types.JNIVersion{ .major = 10, .minor = 0 }) catch unreachable,
        else => unreachable,
    }

    if (se.error_set) |_| {
        return @call(.auto, function, args) catch |err| {
            var maybe_ert = @errorReturnTrace();
            if (maybe_ert) |ert| {
                var err_buf = std.ArrayList(u8).init(std.heap.page_allocator);
                defer err_buf.deinit();

                err_buf.writer().writeAll(@errorName(err)) catch unreachable;
                formatStackTraceJava(err_buf.writer(), ert.*) catch unreachable;
                err_buf.writer().writeByte(0) catch unreachable;

                env.throwGeneric(@ptrCast([*c]const u8, err_buf.items)) catch unreachable;
            } else {
                var buf: [512]u8 = undefined;
                var msg = std.fmt.bufPrintZ(&buf, "{s}", .{@errorName(err)}) catch unreachable;
                env.throwGeneric(msg) catch unreachable;
            }

            // Even though an exception technically kills execution we
            // must still return something; just return undefined
            return undefined;
        };
    } else {
        return @call(.auto, function, args);
    }
}

test {
    std.testing.refAllDecls(@This());
}
