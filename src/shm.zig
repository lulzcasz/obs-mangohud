const std = @import("std");

pub const c = @cImport({
    @cInclude("shm.h");
});

pub const MangoHudMetrics = c.struct_MangoHudMetrics;
pub const MangoHudSHM = c.struct_MangoHudSHM;

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

        var snapshot: MangoHudSHM = undefined;
        snapshot.update_count = start_seq;

        for (0..c.PARAM_ENABLED_MAX) |i| {
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
