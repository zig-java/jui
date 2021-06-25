const types = @import("types.zig");

const Reflector = @This();

env: *types.JNIEnv,

pub fn init(env: *types.JNIEnv) Reflector {
    return .{ .env = env };
}
