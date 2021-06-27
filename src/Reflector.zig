const std = @import("std");
const types = @import("types.zig");
const descriptors = @import("descriptors.zig");

const Reflector = @This();

allocator: *std.mem.Allocator,
env: *types.JNIEnv,

pub fn init(allocator: *std.mem.Allocator, env: *types.JNIEnv) Reflector {
    return .{ .allocator = allocator, .env = env };
}

pub fn getClass(self: *Reflector, name: [*:0]const u8) !Class {
    return Class.init(self, try self.env.newReference(.global, try self.env.findClass(name)));
}

pub fn ObjectType(name_: []const u8) type {
    return struct {
        pub const __isObject = true;
        pub const name = name_;
    };
}

pub const StringType = ObjectType("java/lang/String");

fn valueToDescriptor(comptime T: type) descriptors.Descriptor {
    if (@hasDecl(T, "__isObject")) {
        return .{ .object = @field(T, "name") };
    }

    // switch (T) {

    // }
    unreachable;
}

fn funcToMethodDescriptor(comptime func: type) descriptors.MethodDescriptor {
    const Fn = @typeInfo(func).Fn;
    var parameters: [Fn.args.len]descriptors.Descriptor = undefined;

    inline for (Fn.args) |param, u| {
        parameters[u] = valueToDescriptor(param.arg_type.?);
    }

    return .{
        .parameters = &parameters,
        .return_type = &valueToDescriptor(Fn.return_type.?),
    };
}

pub fn sm(comptime func: type) type {
    return StaticMethod(funcToMethodDescriptor(func));
}

pub const Class = struct {
    const Self = @This();

    reflector: *Reflector,
    class: types.jclass,

    pub fn init(reflector: *Reflector, class: types.jclass) Self {
        return .{ .reflector = reflector, .class = class };
    }

    pub fn getStaticMethod(self: *Self, name: [*:0]const u8, comptime func: type) !sm(func) {
        return try self.getStaticMethod_(sm(func), name);
    }

    fn getStaticMethod_(self: *Self, comptime T: type, name: [*:0]const u8) !T {
        var buf = std.ArrayList(u8).init(self.reflector.allocator);
        defer buf.deinit();

        try @field(T, "descriptor_").toStringArrayList(&buf);
        try buf.append(0);

        return T{ .class = self, .method_id = try self.reflector.env.getStaticMethodId(self.class, name, @ptrCast([*:0]const u8, buf.items)) };
    }

    pub fn getStaticMethodDescriptors(self: *Self, name: [*:0]const u8, comptime descriptor: descriptors.MethodDescriptor) !StaticMethod(descriptor) {
        var buf = std.ArrayList(u8).init(self.reflector.allocator);
        defer buf.deinit();

        try descriptor.toStringArrayList(&buf);
        try buf.append(0);

        return StaticMethod(descriptor){ .class = self, .method_id = try self.reflector.env.getStaticMethodId(self.class, name, @ptrCast([*:0]const u8, buf.items)) };
    }
};

fn MapDescriptorType(comptime value: *const descriptors.Descriptor) type {
    return switch (value.*) {
        .byte => types.jbyte,
        .char => types.jchar,

        .int => types.jint,
        .long => types.jlong,
        .short => types.jshort,

        .float => types.jfloat,
        .double => types.jdouble,

        .boolean => types.jboolean,
        .void => unreachable,

        .object => types.jobject,
        .array => types.jarray,
        .method => unreachable,
    };
}

fn MapDescriptorToNativeTypeEnum(comptime value: *const descriptors.Descriptor) types.NativeType {
    return switch (value.*) {
        .byte => .byte,
        .char => .char,

        .int => .int,
        .long => .long,
        .short => .short,

        .float => .float,
        .double => .double,

        .boolean => .boolean,

        .object, .array => .object,
        .method, .void => unreachable,
    };
}

// pub const StaticMethod = struct {
// class: *Class,
// method_id: types.jmethodID,
// descriptor: descriptors.MethodDescriptor,

// pub fn call(self: StaticMethod, args: anytype) MapDescriptorType(self.descriptor.return_type) {
//     return undefined;
// }
// };

pub fn StaticMethod(descriptor: descriptors.MethodDescriptor) type {
    return struct {
        const Self = @This();
        const descriptor_ = descriptor;

        class: *Class,
        method_id: types.jmethodID,

        pub fn call(self: Self, args: anytype) types.JNIEnv.CallStaticMethodError!MapDescriptorType(descriptor.return_type) {
            _ = self;
            _ = args;

            return self.class.reflector.env.callStaticMethod(comptime MapDescriptorToNativeTypeEnum(descriptor.return_type), self.class.class, self.method_id, null);
        }
    };
}
