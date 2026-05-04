const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shm_module = b.createModule(.{
        .root_source_file = b.path("src/shm.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    shm_module.addIncludePath(b.path("include"));

    const metrics_module = b.createModule(.{
        .root_source_file = b.path("src/metrics.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    metrics_module.addIncludePath(b.path("include"));
    metrics_module.addImport("shm", shm_module);

    const engine_obj = b.addObject(.{
        .name = "engine_obj",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mangohud.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    engine_obj.root_module.addImport("shm", shm_module);
    engine_obj.root_module.addImport("metrics", metrics_module);

    const watcher = b.addExecutable(.{
        .name = "watcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/watcher.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    watcher.use_llvm = true;
    watcher.use_lld = true;
    watcher.root_module.addImport("shm", shm_module);
    watcher.root_module.addImport("metrics", metrics_module);

    watcher.linkLibC();
    watcher.addIncludePath(b.path("include"));

    b.installArtifact(watcher);

    const plugin = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "mangohud",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    plugin.out_filename = "mangohud.so";
    plugin.linkSystemLibrary("obs");
    plugin.addIncludePath(.{ .cwd_relative = "/usr/include/obs" });
    plugin.addCSourceFile(.{
        .file = b.path("src/mangohud.c"),
        .flags = &[_][]const u8{
            "-Wall",
            "-Wextra",
            "-DPLUGIN_NAME=\"mangohud\"",
            "-DPLUGIN_VERSION=\"0.0.0\"",
        },
    });

    plugin.addIncludePath(b.path("include"));

    const shm_obj = b.addObject(.{
        .name = "shm_obj",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/shm.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    shm_obj.root_module.addIncludePath(b.path("include"));

    plugin.addObject(shm_obj);
    plugin.addObject(engine_obj);
    b.installArtifact(plugin);

    const harness = b.addExecutable(.{
        .name = "harness",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    harness.addCSourceFile(.{
        .file = b.path("tools/harness.c"),
        .flags = &[_][]const u8{ "-Wall", "-Wextra" },
    });

    harness.addIncludePath(b.path("include"));

    harness.addObject(engine_obj);
    b.installArtifact(harness);

    const run_watcher_cmd = b.addRunArtifact(watcher);
    run_watcher_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_watcher_cmd.addArgs(args);
    b.step("run-watcher", "Run the Zig watcher").dependOn(&run_watcher_cmd.step);

    const run_harness_cmd = b.addRunArtifact(harness);
    run_harness_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_harness_cmd.addArgs(args);
    b.step("run-harness", "Run the C harness tool").dependOn(&run_harness_cmd.step);
}
