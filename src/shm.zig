const std = @import("std");

pub const PARAM_ENABLED_MAX: usize = 2;

pub const MetricFlag = enum(c_int) {
    PARAM_GPU_USAGE = 0,
    PARAM_CPU_USAGE = 1,
    PARAM_ENABLED_MAX = PARAM_ENABLED_MAX,
};

pub const MangoHudMetrics = extern struct {
    fps: f32,
    frametime: f32,
    min_frametime: f64,
    max_frametime: f64,
    cpu_percent: f32,
    gpu_load: i32,
};

pub const MangoHudSHM = extern struct {
    update_count: u64,
    param_enabled: [PARAM_ENABLED_MAX]bool,
    metrics: MangoHudMetrics,
};

pub fn get_shm_ptr(io: std.Io) !*volatile MangoHudSHM {
    const file = try std.Io.Dir.openFileAbsolute(io, "/dev/shm/MangoHud", .{
        .mode = .read_only,
    });
    defer file.close(io);

    const mapped_memory = try std.posix.mmap(
        null,
        @sizeOf(MangoHudSHM),
        .{ .READ = true },
        .{ .TYPE = .SHARED },
        file.handle,
        0,
    );

    return @ptrCast(@alignCast(mapped_memory.ptr));
}

pub fn get_shm_snapshot(shm_ptr: *volatile MangoHudSHM) MangoHudSHM {
    while (true) {
        const start_seq = shm_ptr.update_count;

        if (start_seq % 2 != 0) {
            std.Thread.yield() catch {};
            continue;
        }

        var snapshot: MangoHudSHM = undefined;
        snapshot.update_count = start_seq;

        for (0..PARAM_ENABLED_MAX) |i| {
            snapshot.param_enabled[i] = shm_ptr.param_enabled[i];
        }

        snapshot.metrics.fps = shm_ptr.metrics.fps;
        snapshot.metrics.frametime = shm_ptr.metrics.frametime;
        snapshot.metrics.min_frametime = shm_ptr.metrics.min_frametime;
        snapshot.metrics.max_frametime = shm_ptr.metrics.max_frametime;
        snapshot.metrics.cpu_percent = shm_ptr.metrics.cpu_percent;
        snapshot.metrics.gpu_load = shm_ptr.metrics.gpu_load;

        const end_seq = shm_ptr.update_count;

        if (start_seq == end_seq) {
            return snapshot;
        }

        std.Thread.yield() catch {};
    }
}
