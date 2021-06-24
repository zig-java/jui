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

// --- Code ~~stolen~~ adapted from debug.zig starts here ---
// Copyright (c) 2015-2021 Zig Contributors
// This code is part of [zig](https://ziglang.org/), which is MIT licensed.
// The MIT license requires this copyright notice to be included in all copies
// and substantial portions of the software.

/// This is required because SymbolInfo doesn't expose its deinit for some weird reason
fn deinitSymbolInfo(self: std.debug.SymbolInfo) void {
    if (self.line_info) |li| {
        deinitLineInfo(li);
    }
}

/// This is required because LineInfo doesn't expose its deinit for some weird reason
fn deinitLineInfo(self: std.debug.LineInfo) void {
    const allocator = self.allocator orelse return;
    allocator.free(self.file_name);
}

fn printSourceAtAddressJava(debug_info: *std.debug.DebugInfo, writer: anytype, address: usize) !void {
    const module = debug_info.getModuleForAddress(address) catch |err| switch (err) {
        error.MissingDebugInfo, error.InvalidDebugInfo => {
            return try writer.writeAll((" " ** 8) ++ "at unknown (missing/invalud debug info)");
        },
        else => return err,
    };

    const symbol_info = try module.getSymbolAtAddress(address);
    defer deinitSymbolInfo(symbol_info);

    if (symbol_info.line_info) |li| {
        try writer.print((" " ** 8) ++ "at {s}({s}:{d}:{d})", .{ symbol_info.symbol_name, li.file_name, li.line, li.column });
    } else {
        try writer.print((" " ** 8) ++ "at {s}({s}:unknown)", .{ symbol_info.symbol_name, symbol_info.compile_unit_name });
    }
}

fn writeStackTraceJava(
    stack_trace: std.builtin.StackTrace,
    writer: anytype,
    debug_info: *std.debug.DebugInfo,
) !void {
    if (std.builtin.strip_debug_info) return error.MissingDebugInfo;

    var frame_index: usize = 0;
    var frames_left: usize = std.math.min(stack_trace.index, stack_trace.instruction_addresses.len);

    while (frames_left != 0) : ({
        frames_left -= 1;
        frame_index = (frame_index + 1) % stack_trace.instruction_addresses.len;
    }) {
        const return_address = stack_trace.instruction_addresses[frame_index];
        try printSourceAtAddressJava(debug_info, writer, return_address - 1);
        if (frames_left != 1) try writer.writeByte('\n');
    }
}

fn formatStackTraceJava(writer: anytype, trace: std.builtin.StackTrace) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const debug_info = std.debug.getSelfDebugInfo() catch return;
    try writer.writeAll("\n");
    writeStackTraceJava(trace, writer, debug_info) catch |err| {
        try writer.print("Unable to print stack trace: {s}\n", .{@errorName(err)});
    };
}

// --- Code ~~stolen~~ adapted from debug.zig ends here ---

fn splitError(comptime T: std.builtin.TypeInfo) struct { error_set: ?type = null, payload: type } {
    return switch (T) {
        .ErrorUnion => |u| .{ .error_set = u.error_set, .payload = u.payload },
        else => .{ .payload = T },
    };
}

/// NOTE: This is sadly required as @Type for Fn is not implemented so we cannot autowrap functions 
pub fn wrapErrors(function: anytype, args: anytype) splitError(@typeInfo(@typeInfo(@TypeOf(function)).Fn.return_type.?)).payload {
    const se = splitError(@typeInfo(@typeInfo(@TypeOf(function)).Fn.return_type.?));
    var env: *JNIEnv = args[0];

    if (se.error_set) |set| {
        return @call(.{}, function, args) catch |err| {
            var maybe_ert = @errorReturnTrace();
            if (maybe_ert) |ert| {
                var err_buf = std.ArrayList(u8).init(std.heap.page_allocator);
                defer err_buf.deinit();

                err_buf.writer().writeAll(@errorName(err)) catch unreachable;
                formatStackTraceJava(err_buf.writer(), ert.*) catch unreachable;
                err_buf.writer().writeByte(0) catch unreachable;

                env.throwGeneric(@ptrCast([*c]const u8, err_buf.items)) catch unreachable;

                // Even though an exception technically kills execution we
                // must still return something; just return a zeroed payload
                return std.mem.zeroes(se.payload);
            } else {
                var buf: [512]u8 = undefined;
                var msg = std.fmt.bufPrintZ(&buf, "{s}", .{err}) catch unreachable;
                env.throwGeneric(msg) catch unreachable;

                return std.mem.zeroes(se.payload);
            }
        };
    } else {
        return @call(.{}, function, args);
    }
}
