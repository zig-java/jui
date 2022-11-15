const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    //Example
    {
        const lib = b.addSharedLibrary("jni_example", "test/demo.zig", .unversioned);

        if (@hasField(std.build.LibExeObjStep, "use_stage1"))
            lib.use_stage1 = true;

        lib.addPackagePath("jui", "src/jui.zig");

        lib.setTarget(target);
        lib.setBuildMode(mode);
        lib.install();
    }

    // Tests (it requires a JDK installed)
    {
        const java_home = b.env_map.get("JAVA_HOME") orelse @panic("JAVA_HOME not defined.");

        const main_tests = b.addTest("src/jui.zig");
        main_tests.setBuildMode(mode);

        if (@hasField(std.build.LibExeObjStep, "use_stage1"))
            main_tests.use_stage1 = true;

        if (@hasDecl(@TypeOf(main_tests.*), "addLibraryPath")) {
            main_tests.addLibraryPath(b.pathJoin(&.{ java_home, "/lib" }));
            main_tests.addLibraryPath(b.pathJoin(&.{ java_home, "/lib/server" }));
        } else {
            // Deprecated on zig 0.10
            main_tests.addLibPath(b.pathJoin(&.{ java_home, "/lib" }));
            main_tests.addLibPath(b.pathJoin(&.{ java_home, "/lib/server" }));
        }

        main_tests.linkSystemLibrary("jvm");
        main_tests.linkLibC();
        main_tests.target.abi = .gnu;

        var test_step = b.step("test", "Run library tests");
        test_step.dependOn(&main_tests.step);

        const argv: []const []const u8 = &.{ b.pathJoin(&.{ java_home, "/bin/javac" ++ if (builtin.os.tag == .windows) ".exe" else "" }), "test/src/com/jui/TypesTest.java" };
        _ = b.execFromStep(argv, test_step) catch |err| {
            std.debug.panic("Failed to compile Java test files: {}", .{err});
        };
    }
}
