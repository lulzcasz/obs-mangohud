const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module_shm = b.createModule(.{
        .root_source_file = b.path("src/shm.zig"),
        .target = target,
        .optimize = optimize,
    });

    const module_metrics = b.createModule(.{
        .root_source_file = b.path("src/metrics.zig"),
        .target = target,
        .optimize = optimize,
    });

    module_metrics.addImport("shm", module_shm);

    const obj_mangohud = b.addObject(.{
        .name = "engine_obj",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mangohud.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    obj_mangohud.root_module.addImport("shm", module_shm);
    obj_mangohud.root_module.addImport("metrics", module_metrics);

    module_metrics.addImport("shm", module_shm);

    const exe_watcher = b.addExecutable(.{
        .name = "watcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/watcher.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe_watcher.root_module.addImport("shm", module_shm);
    exe_watcher.root_module.addImport("metrics", module_metrics);

    b.installArtifact(exe_watcher);

    const run_watcher = b.addRunArtifact(exe_watcher);
    b.step("run-watcher", "run watcher").dependOn(&run_watcher.step);
}
