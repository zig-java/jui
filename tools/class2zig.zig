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
        const class = class_file.constant_pool.get(class_file.this_class).class;
        const classpath = class_file.constant_pool.get(class.name_index).utf8.bytes;
        const classname = std.fs.path.basename(classpath);
        const dirname = std.fs.path.dirname(classpath) orelse "";
        const zig_filename = try std.fmt.allocPrint(arena_alloc, "{s}.zig", .{classname});

        const class_dir = try out.makeOpenPath(dirname, .{});
        const zig_file = try class_dir.createFile(zig_filename, .{});

        // Declarations

        var field_decls = std.ArrayList(u8).init(arena_alloc);
        defer field_decls.deinit();

        try writeFieldDecls(class_file.fields.items, field_decls.writer());

        var method_decls = std.ArrayList(u8).init(arena_alloc);
        defer method_decls.deinit();

        try writeMethodDecls(class_file.methods.items, method_decls.writer());

        var constructors = std.ArrayList(u8).init(arena_alloc);
        defer constructors.deinit();

        try writeConstructors(class_file.methods.items, arena_alloc, constructors.writer());

        var static_field_accessors = std.ArrayList(u8).init(arena_alloc);
        var static_method_accessors = std.ArrayList(u8).init(arena_alloc);
        var field_accessors = std.ArrayList(u8).init(arena_alloc);
        var method_accessors = std.ArrayList(u8).init(arena_alloc);

        // Write to file
        const writer = zig_file.writer();
        try writer.print(
            \\const std = @import("std");
            \\const jui = @import("jui");
            \\
            \\const {[classname]s} = struct {{
            \\    const Instance = @This();
            \\    pub const Class = struct {{
            \\        fields: struct {{ {[field_decls]s} }},
            \\        methods: struct {{ {[method_decls]s} }},
            \\        class: jui.jclass,
            \\        const classpath = "{[classpath]s}";
            \\        pub fn load(env: *jui.JNIEnv) !@This() {{
            \\            const class_local = try env.findClass(classpath);
            \\            const class = try env.newReference(.global, class_local);
            \\            return @This(){{
            \\                .fields = .{{}},
            \\                .methods = .{{}},
            \\                .class = class,
            \\            }};
            \\        }}
            \\        {[constructors]s}
            \\        {[static_field_accessors]s}
            \\        {[static_method_accessors]s}
            \\    }};
            \\
            \\    class: *Class,
            \\    object: jui.jobject,
            \\
            \\    {[field_accessors]s}
            \\    {[method_accessors]s}
            \\}};
        , .{
            .classname = classname,
            .classpath = classpath,
            .field_decls = field_decls.items,
            .method_decls = method_decls.items,
            .constructors = constructors.items,
            .static_field_accessors = static_field_accessors.items,
            .static_method_accessors = static_method_accessors.items,
            .field_accessors = field_accessors.items,
            .method_accessors = method_accessors.items,
        });

        _ = try std.fmt.format(stdout.writer(), "Successfully wrote {s}\n", .{classpath});
    }
}

fn writeFieldDecls(fields: []cf.FieldInfo, writer: anytype) !void {
    for (fields) |field| {
        const name = field.getName().bytes;
        const descriptor = field.getDescriptor().bytes;
        try std.fmt.format(writer, "        @\"{s}_{s}\": ?jui.jfieldID,\n", .{ name, descriptor });
    }
}

fn writeMethodDecls(methods: []cf.MethodInfo, writer: anytype) !void {
    for (methods) |method| {
        const name = method.getName().bytes;
        const descriptor = method.getDescriptor().bytes;
        try std.fmt.format(writer, "        @\"{s}{s}\": ?jui.jmethodID,\n", .{ name, descriptor });
    }
}

fn writeConstructors(methods: []cf.MethodInfo, allocator: std.mem.Allocator, writer: anytype) !void {
    for (methods) |method| {
        const name = method.getName().bytes;
        if (!std.mem.eql(u8, name, "<init>")) continue;

        const descriptor = method.getDescriptor().bytes;
        var descriptor_info = try jui.descriptors.parseString(allocator, descriptor);
        std.debug.assert(descriptor_info.* == .method);
        try std.fmt.format(writer,
            \\        pub fn @"<init>{[descriptor]s}"(self: @This(), env: *jui.JNIEnv, args: anytype) !*@This() {{
            \\            const arg_info = @typeInfo(args);
            \\            const method_id = self.methods.@"<init>{[descriptor]s}";
            \\            comptime var arg_array = [_]jui.jvalue{{}};
            \\            inline for (args) |arg| {{
            \\                arg_array ++ .{{jui.jvalue.fromValue(arg)}};
            \\            }}
            \\            const object = try env.newObject(self.class, method_id, &arg_array);
            \\            return Instance {{ .class = self, .object = object }};
            \\        }}
            \\
        , .{
            .descriptor = descriptor,
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

    const is_constructor = std.mem.eql(u8, name, "<init>");

    // Parse the descriptor
    var descriptor_info = try jui.descriptors.parseString(alloc, descriptor);
    defer descriptor_info.deinit(alloc);

    const self = if (method.access_flags.static) "" else "self: *@This(), ";
    const self2 = if (method.access_flags.static) "class" else "@ptrCast(jui.jobject, self)";
    const class_assign = if (method.access_flags.static) "const class" else "_";
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
        try std.fmt.format(call_parameters.writer(), "{s}jui.jvalue.toJValue(arg{})", .{
            if (i == 0) "" else ", ",
            i,
        });
    }

    if (has_parameters)
        try std.fmt.format(call_parameters.writer(), "}}", .{});

    if (is_constructor) {
        try std.fmt.format(call_entry.writer(),
            \\    pub fn @"{[name]s}{[descriptor]s}"(env: *jui.JNIEnv{[parameters]s}) !*@This() {{
            \\        try load(env);
            \\        const class = class_global orelse return error.ClassNotLoaded;
            \\        return @ptrCast(*@This(), try env.newObject(class, methods.@"{[name]s}{[descriptor]s}", {[call_parameters]s}));
            \\    }}
            \\
        , .{
            .name = name,
            .descriptor = descriptor,
            .parameters = parameters.items,
            .call_parameters = call_parameters.items,
        });
    } else {
        try std.fmt.format(call_entry.writer(),
            \\    pub fn @"{[name]s}{[descriptor]s}"({[self]s}env: *jui.JNIEnv{[parameters]s}) !{[return_type]s} {{
            \\        try load(env);
            \\        {[class_assign]s} = class_global orelse return error.ClassNotFound;
            \\        return env.call{[static]s}Method(.{[call_return_type]s}, {[self2]s}, methods.@"{[name]s}{[descriptor]s}", {[call_parameters]s});
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
            .class_assign = class_assign,
        });
    }
}

fn writeFieldBindingFunction(call_entry: *std.ArrayList(u8), alloc: std.mem.Allocator, field: cf.FieldInfo) !void {
    // Get name and descriptor
    const name = field.getName().bytes;
    const descriptor = field.getDescriptor().bytes;

    // Parse the descriptor
    var descriptor_info = try jui.descriptors.parseString(alloc, descriptor);
    defer descriptor_info.deinit(alloc);

    const self = if (field.access_flags.static) "" else "self: *@This(), ";
    const self2 = if (field.access_flags.static) "class" else "@ptrCast(jui.jobject, self)";
    const class_assign = if (field.access_flags.static) "const class" else "_";
    const static = if (field.access_flags.static) "Static" else "";

    const return_type = descriptorAsTypeString(descriptor_info.*);

    try std.fmt.format(call_entry.writer(),
        \\    pub fn @"get_{[name]s}_{[descriptor]s}"({[self]s}env: *jui.JNIEnv) !{[return_type]s} {{
        \\        try load(env);
        \\        {[class_assign]s} = class_global orelse return error.ClassNotFound;
        \\        return env.get{[static]s}Field(.{[call_return_type]s}, {[self2]s}, fields.@"{[name]s}_{[descriptor]s}");
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
        .class_assign = class_assign,
    });

    if (!field.access_flags.final) {
        try std.fmt.format(call_entry.writer(),
            \\    pub fn @"set_{[name]s}_{[descriptor]s}"({[self]s}env: *jui.JNIEnv, arg: {[return_type]s}) !void {{
            \\        try load(env);
            \\        {[class_assign]s} = class_global orelse return error.ClassNotFound;
            \\        try env.call{[static]s}Field(.{[call_return_type]s}, {[self2]s}, fields.@"{[name]s}_{[descriptor]s}", arg);
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
            .class_assign = class_assign,
        });
    }
}
