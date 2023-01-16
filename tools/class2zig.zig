const std = @import("std");
const jui = @import("jui");
const cf = @import("cf");
const ClassFile = @import("cf").ClassFile;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const allocator = gpa.allocator();
    const stdout = std.io.getStdOut();
    const cwd = std.fs.cwd();

    // Handle cli
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const arg_class_in = args[1];
    const arg_out_dir = args[2];

    // Open class file
    var class_file: ClassFile = undefined;
    {
        const file = try cwd.openFile(arg_class_in, .{});
        const reader = file.reader();

        class_file = try ClassFile.decode(allocator, reader);
    }
    defer class_file.deinit();

    const out = try cwd.makeOpenPath(arg_out_dir, .{});

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var arena_alloc = arena.allocator();
    // Generate zig bindings
    {
        _ = try std.fmt.format(stdout.writer(), "There are {} entries in the constant pool\n", .{class_file.constant_pool.entries.items.len});

        const class = class_file.constant_pool.get(class_file.this_class).class;
        const classpath = class_file.constant_pool.get(class.name_index).utf8.bytes;
        const classname = std.fs.path.basename(classpath);
        const dirname = std.fs.path.dirname(classpath) orelse "";
        const zig_filename = try std.fmt.allocPrint(arena_alloc, "{s}.zig", .{classname});

        const class_dir = try out.makeOpenPath(dirname, .{});
        const zig_file = try class_dir.createFile(zig_filename, .{});

        _ = try std.fmt.format(stdout.writer(), "{s}\n{s}\n{s}\n", .{ classpath, classname, dirname });

        const doc = doc: {
            var docs = std.ArrayList(u8).init(arena_alloc);
            defer docs.deinit();
            try docs.appendSlice("/// Opaque type corresponding to ");
            try docs.appendSlice(classpath);
            break :doc try docs.toOwnedSlice();
        };

        const loadfn = @embedFile("loadfn.zig");

        const body = body: {
            var body = std.ArrayList(u8).init(arena_alloc);
            defer body.deinit();
            try std.fmt.format(body.writer(), "    const classpath = \"{s}\";\n", .{classpath});
            try std.fmt.format(body.writer(), "    var class_global: jui.jclass = null;\n", .{});

            var load_entry = std.ArrayList(u8).init(arena_alloc);
            defer load_entry.deinit();

            var call_entry = std.ArrayList(u8).init(arena_alloc);
            defer call_entry.deinit();

            // Add a newline to leave the comment in loadfn
            try load_entry.append('\n');

            const will_write_fields = class_file.fields.items.len != 0;
            const will_write_methods = class_file.methods.items.len != 0;

            // Write fields
            if (will_write_fields) {
                try std.fmt.format(body.writer(), "    var fields: struct {{\n", .{});
                try std.fmt.format(load_entry.writer(), "                fields = .{{\n", .{});
            }

            for (class_file.fields.items) |field| {
                const name = field.getName().bytes;
                const descriptor = field.getDescriptor().bytes;
                const static = if (field.access_flags.static) "Static" else "";
                try std.fmt.format(body.writer(), "        @\"{s}{s}\": jui.jfieldID,\n", .{ name, descriptor });
                try std.fmt.format(load_entry.writer(), "                    .@\"{0s}_{1s}\" = try inner_env.get{2s}FieldId(class, \"{0s}\", \"{1s}\"),\n", .{ name, descriptor, static });
                try writeFieldBindingFunction(&call_entry, arena_alloc, field);
            }

            if (will_write_fields) {
                try std.fmt.format(body.writer(), "    }} = undefined;\n", .{});
                try std.fmt.format(load_entry.writer(), "                }};\n", .{});
            }

            // Write methods
            if (will_write_methods) {
                try std.fmt.format(body.writer(), "    var methods: struct {{\n", .{});
                try std.fmt.format(load_entry.writer(), "                methods = .{{\n", .{});
            }

            for (class_file.methods.items) |method| {
                const name = method.getName().bytes;
                const descriptor = method.getDescriptor().bytes;
                const static = if (method.access_flags.static) "Static" else "";
                try std.fmt.format(body.writer(), "        @\"{s}{s}\": jui.jmethodID,\n", .{ name, descriptor });
                try std.fmt.format(load_entry.writer(), "                    .@\"{0s}{1s}\" = try inner_env.get{2s}MethodId(class, \"{0s}\", \"{1s}\"),\n", .{ name, descriptor, static });
                try writeBindingFunction(&call_entry, arena_alloc, method);
            }

            if (will_write_methods) {
                try std.fmt.format(body.writer(), "    }} = undefined;\n", .{});
                try std.fmt.format(load_entry.writer(), "                }};\n", .{});
            }

            try std.fmt.format(body.writer(), loadfn, .{ .load_entry = load_entry.items });
            try body.appendSlice(try call_entry.toOwnedSlice());
            break :body try body.toOwnedSlice();
        };

        _ = try std.fmt.format(zig_file.writer(),
            \\const std = @import("std");
            \\const jui = @import("jui");
            \\{[doc]s}
            \\pub const {[classname]s} = opaque {{
            \\{[body]s}
            \\}};
            \\
        , .{
            .doc = doc,
            .classname = classname,
            .body = body,
        });
    }
}

fn descriptorAsTypeString(descriptor: jui.descriptors.Descriptor) []const u8 {
    return switch (descriptor) {
        .byte => "jui.jbyte",
        .char => "jui.jchar",
        .int => "jui.jint",
        .short => "jui.jshort",
        .long => "jui.jlong",
        .float => "jui.jfloat",
        .double => "jui.jdouble",
        .boolean => "jui.jboolean",
        .void => "void",
        .object => "jui.jobject",
        .array => "jui.jarray",
        .method => "jui.jmethodId",
    };
}

fn writeBindingFunction(call_entry: *std.ArrayList(u8), alloc: std.mem.Allocator, method: cf.MethodInfo) !void {
    // Get name and descriptor
    const name = method.getName().bytes;
    const descriptor = method.getDescriptor().bytes;

    // Parse the descriptor
    var descriptor_info = try jui.descriptors.parseString(alloc, descriptor);
    defer descriptor_info.deinit(alloc);

    const self = if (method.access_flags.static) "" else "self: @This(), ";
    const self2 = if (method.access_flags.static) "class" else "self";
    const static = if (method.access_flags.static) "Static" else "";

    const return_type = descriptorAsTypeString(descriptor_info.method.return_type.*);

    var parameters = std.ArrayList(u8).init(alloc);
    defer parameters.deinit();

    var call_parameters = std.ArrayList(u8).init(alloc);
    defer call_parameters.deinit();

    const has_parameters = (descriptor_info.method.parameters.len != 0);

    if (has_parameters)
        try std.fmt.format(call_parameters.writer(), "&[_]jui.jvalue{{", .{})
    else
        try call_parameters.appendSlice("null");

    for (descriptor_info.method.parameters) |parameter, i| {
        const type_string = descriptorAsTypeString(parameter.*);
        try std.fmt.format(parameters.writer(), ", arg{}: {s}", .{
            i,
            type_string,
        });
        try std.fmt.format(call_parameters.writer(), "{s}arg{}", .{
            if (i == 0) "" else ", ",
            i,
        });
    }

    if (has_parameters)
        try std.fmt.format(call_parameters.writer(), "}}", .{});

    try std.fmt.format(call_entry.writer(),
        \\    pub fn @"{[name]s}{[descriptor]s}"({[self]s}env: *jui.JNIEnv{[parameters]s}) !{[return_type]s} {{
        \\        try load(env);
        \\        const class = class_global orelse return error.ClassNotFound;
        \\        return env.call{[static]s}Method(.{[call_return_type]s}, {[self2]s}, {[call_parameters]s});
        \\    }}
        \\
    , .{
        .name = name,
        .descriptor = descriptor,
        .self = self,
        .self2 = self2,
        .return_type = return_type,
        .call_return_type = try descriptor_info.method.return_type.humanStringifyConst(),
        .static = static,
        .parameters = parameters.items,
        .call_parameters = call_parameters.items,
    });
}

fn writeFieldBindingFunction(call_entry: *std.ArrayList(u8), alloc: std.mem.Allocator, field: cf.FieldInfo) !void {
    // Get name and descriptor
    const name = field.getName().bytes;
    const descriptor = field.getDescriptor().bytes;

    // Parse the descriptor
    var descriptor_info = try jui.descriptors.parseString(alloc, descriptor);
    defer descriptor_info.deinit(alloc);

    const self = if (field.access_flags.static) "" else "self: @This(), ";
    const self2 = if (field.access_flags.static) "class" else "self";
    const static = if (field.access_flags.static) "Static" else "";

    const return_type = descriptorAsTypeString(descriptor_info.*);

    try std.fmt.format(call_entry.writer(),
        \\    pub fn @"get_{[name]s}_{[descriptor]s}"({[self]s}env: *jui.JNIEnv) !{[return_type]s} {{
        \\        try load(env);
        \\        const class = class_global orelse return error.ClassNotFound;
        \\        return env.get{[static]s}Field(.{[call_return_type]s}, {[self2]s}, methods.@"{[name]s}{[descriptor]s}");
        \\    }}
        \\
    , .{
        .name = name,
        .descriptor = descriptor,
        .self = self,
        .self2 = self2,
        .return_type = return_type,
        .call_return_type = try descriptor_info.humanStringifyConst(),
        .static = static,
    });

    if (!field.access_flags.final) {
        try std.fmt.format(call_entry.writer(),
            \\    pub fn @"set_{[name]s}_{[descriptor]s}"({[self]s}env: *jui.JNIEnv, arg: {[return_type]s}) !void {{
            \\        try load(env);
            \\        const class = class_global orelse return error.ClassNotFound;
            \\        try env.call{[static]s}Field(.{[call_return_type]s}, {[self2]s}, fields.@"{[name]s}{[descriptor]s}", arg);
            \\    }}
            \\
        , .{
            .name = name,
            .descriptor = descriptor,
            .self = self,
            .self2 = self2,
            .return_type = return_type,
            .call_return_type = try descriptor_info.humanStringifyConst(),
            .static = static,
        });
    }
}
