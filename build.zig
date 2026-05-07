const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_shm = b.addTranslateC(.{
        .root_source_file = b.path("include/shm.h"),
        .target = target,
        .optimize = optimize,
    });

    const translate_metrics = b.addTranslateC(.{
        .root_source_file = b.path("include/metrics.h"),
        .target = target,
        .optimize = optimize,
    });

    const module_shm = b.createModule(.{
        .root_source_file = b.path("src/shm.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "shm",
                .module = translate_shm.createModule(),
            },
        },
    });

    const module_metrics = b.createModule(.{
        .root_source_file = b.path("src/metrics.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "metrics",
                .module = translate_metrics.createModule(),
            },
        },
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

    const test_exe = b.addExecutable(.{
        .name = "test_mangohud",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    test_exe.root_module.addCSourceFile(.{
        .file = b.path("tests/test_mangohud.c"),
        .flags = &[_][]const u8{ "-Wall", "-Wextra" },
    });

    test_exe.root_module.addIncludePath(b.path("include"));

    test_exe.root_module.addObject(obj_mangohud);

    const run_test = b.addRunArtifact(test_exe);

    const test_step = b.step("test", "run integration tests");
    test_step.dependOn(&run_test.step);
}
