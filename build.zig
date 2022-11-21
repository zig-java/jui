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

        const libjvm_path = if (builtin.os.tag == .windows) "/lib" else "/lib/server";
        if (@hasDecl(@TypeOf(main_tests.*), "addLibraryPath")) {
            main_tests.addLibraryPath(b.pathJoin(&.{ java_home, libjvm_path }));
        } else {
            // Deprecated on zig 0.10
            main_tests.addLibPath(b.pathJoin(&.{ java_home, libjvm_path }));
        }

        main_tests.linkSystemLibrary("jvm");
        main_tests.linkLibC();

        // TODO: Depending on the JVM available to the distro:
        if (builtin.os.tag == .linux) {
            main_tests.target.abi = .gnu;
        }

        if (builtin.os.tag == .windows) {

            // Sets the DLL path:
            const setDllDirectory = struct {
                pub extern "kernel32" fn SetDllDirectoryA(path: [*:0]const u8) callconv(.C) std.os.windows.BOOL;
            }.SetDllDirectoryA;

            var java_bin_path = std.fs.path.joinZ(b.allocator, &.{ java_home, "\\bin" }) catch unreachable;
            defer b.allocator.free(java_bin_path);
            _ = setDllDirectory(java_bin_path);

            var java_bin_server_path = std.fs.path.joinZ(b.allocator, &.{ java_home, "\\bin\\server" }) catch unreachable;
            defer b.allocator.free(java_bin_server_path);
            _ = setDllDirectory(java_bin_server_path);

            // TODO: Define how we can disable the SEGV handler just for a single call:
            // The function `JNI_CreateJavaVM` tries to detect the stack size
            // and causes a SEGV that is handled by the Zig side
            // https://bugzilla.redhat.com/show_bug.cgi?id=1572811#c7
            //
            // The simplest workarround is just run the tests in "ReleaseFast" mode,
            // and for some reason it is not needed on Linux.
            main_tests.setBuildMode(.ReleaseFast);
        } else {
            main_tests.setBuildMode(mode);
        }

        var test_step = b.step("test", "Run library tests");
        test_step.dependOn(&main_tests.step);

        const argv: []const []const u8 = &.{ b.pathJoin(&.{ java_home, "/bin/javac" ++ if (builtin.os.tag == .windows) ".exe" else "" }), "test/src/com/jui/TypesTest.java" };
        _ = b.execFromStep(argv, test_step) catch |err| {
            std.debug.panic("Failed to compile Java test files: {}", .{err});
        };
    }
}
