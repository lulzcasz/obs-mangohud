const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const watcher = b.addExecutable(.{
        .name = "watcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/watcher.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    watcher.addIncludePath(b.path("."));

    const ipc_module = b.createModule(.{
        .root_source_file = b.path("src/ipc.zig"),
    });
    watcher.root_module.addImport("ipc", ipc_module);

    b.installArtifact(watcher);

    const run_zig_cmd = b.addRunArtifact(watcher);
    run_zig_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_zig_cmd.addArgs(args);
    }
    const run_zig_step = b.step("run-watcher", "R");
    run_zig_step.dependOn(&run_zig_cmd.step);
}
