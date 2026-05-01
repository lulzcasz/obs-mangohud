const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ipc_module = b.createModule(.{
        .root_source_file = b.path("src/ipc.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    ipc_module.addIncludePath(b.path("src"));

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

    watcher.root_module.addImport("ipc", ipc_module);
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

    plugin.addIncludePath(b.path("src"));

    const ipc_obj = b.addObject(.{
        .name = "ipc_obj",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ipc.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    ipc_obj.root_module.addIncludePath(b.path("src"));
    plugin.addObject(ipc_obj);

    b.installArtifact(plugin);

    const run_watcher_cmd = b.addRunArtifact(watcher);
    run_watcher_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_watcher_cmd.addArgs(args);

    b.step("run-watcher", "Run the Zig watcher").dependOn(&run_watcher_cmd.step);
}
