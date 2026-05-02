const std = @import("std");

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
    metrics: MangoHudMetrics,
};

pub fn get_shm_ptr() !*volatile MangoHudSHM {
    const file = try std.fs.openFileAbsolute("/dev/shm/MangoHud", .{
        .mode = .read_only,
    });
    defer file.close();

    const mapped_memory = try std.posix.mmap(
        null,
        @sizeOf(MangoHudSHM),
        std.posix.PROT.READ,
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

        const snapshot = MangoHudSHM{
            .update_count = start_seq,
            .metrics = .{
                .fps = shm_ptr.metrics.fps,
                .frametime = shm_ptr.metrics.frametime,
                .min_frametime = shm_ptr.metrics.min_frametime,
                .max_frametime = shm_ptr.metrics.max_frametime,
                .cpu_percent = shm_ptr.metrics.cpu_percent,
                .gpu_load = shm_ptr.metrics.gpu_load,
            },
        };

        const end_seq = shm_ptr.update_count;

        if (start_seq == end_seq) {
            return snapshot;
        }

        std.Thread.yield() catch {};
    }
}
