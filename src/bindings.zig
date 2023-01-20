const std = @import("std");
const jui = @import("jui");

fn returnTypeLookup(comptime descriptor: []const u8, comptime descriptor_table: []const []const u8, comptime return_type: []const type) type {
    inline for (descriptor_table) |desc, i| {
        if (std.mem.eql(u8, desc, descriptor)) {
            return return_type[i];
        }
    }
    @compileError("Return Type Lookup: No descriptor " ++ descriptor ++ " found in descriptor_table");
}
