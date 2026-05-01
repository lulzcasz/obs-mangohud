const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_exe = b.addExecutable(.{
        .name = "watcher-zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/watcher.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    zig_exe.addIncludePath(b.path("."));

    const ipc_module = b.createModule(.{
        .root_source_file = b.path("src/ipc.zig"),
    });
    zig_exe.root_module.addImport("ipc", ipc_module);

    b.installArtifact(zig_exe);

    const run_zig_cmd = b.addRunArtifact(zig_exe);
    run_zig_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_zig_cmd.addArgs(args);
    }
    const run_zig_step = b.step("run-zig", "R");
    run_zig_step.dependOn(&run_zig_cmd.step);

    const c_exe = b.addExecutable(.{
        .name = "watcher-c",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    c_exe.addCSourceFile(.{
        .file = b.path("tools/watcher.c"),
        .flags = &[_][]const u8{ "-Wall", "-Wextra" },
    });
    c_exe.linkLibC();

    b.installArtifact(c_exe);

    const ipc_obj = b.addObject(.{
        .name = "ipc_obj",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ipc.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    c_exe.addObject(ipc_obj);

    const run_c_cmd = b.addRunArtifact(c_exe);
    run_c_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_c_cmd.addArgs(args);
    }
    const run_c_step = b.step("run-c", "Roda o monitor escrito em C");
    run_c_step.dependOn(&run_c_cmd.step);
}
