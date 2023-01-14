const std = @import("std");
const jui = @import("jui");

const Descriptor = jui.descriptors.Descriptor;

pub fn main() !void {
    const JNI_1_10 = jui.JNIVersion{ .major = 10, .minor = 0 };
    const args = jui.JavaVMInitArgs{
        .version = JNI_1_10,
        .options = &.{
            .{ .option = "-Djava.class.path=./test/src" },
        },
        .ignore_unrecognized = true,
    };
    var result = jui.JavaVM.createJavaVM(&args) catch |err| {
        std.debug.panic("Cannot create JVM {!}", .{err});
    };

    var env = result.env;
    var jvm = try env.getJavaVM();
    var created_jvm = try jui.JavaVM.getCreatedJavaVM();

    std.debug.assert(created_jvm != null);
    std.debug.assert(jvm == created_jvm.?);

    var System = try env.findClass("java/lang/System");
    const System_in = try env.getStaticFieldId(System, "in", "Ljava/io/InputStream;");
    const system_input_stream = env.getStaticField(.object, System, System_in);

    var Scanner = try env.findClass("java/util/Scanner");
    const Scanner_constructor = try env.getMethodId(Scanner, "<init>", "(Ljava/io/InputStream;)V");
    const Scanner_nextInt = try env.getMethodId(Scanner, "nextInt", "()I");

    const jvalue = jui.jvalue;
    var scanner = try env.newObject(Scanner, Scanner_constructor, &[_]jvalue{jvalue.toJValue(system_input_stream)});
    const int = try env.callMethod(.int, scanner, Scanner_nextInt, null);

    std.log.info("Entered int: {}", .{int});
}
