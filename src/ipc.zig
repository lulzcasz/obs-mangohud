const std = @import("std");

pub const IPCData = extern struct {
    update_count: u64,
    fps: f64,
    frametime: f64,
    min_frametime: f64,
    max_frametime: f64,
    cpu_percent: f64,
    gpu_load: i32,
};

pub fn get_ipc_data_ptr() !*volatile IPCData {
    const file = try std.fs.openFileAbsolute("/dev/shm/MangoHudTelemetry", .{
        .mode = .read_only,
    });
    defer file.close();

    const mapped_memory = try std.posix.mmap(
        null,
        @sizeOf(IPCData),
        std.posix.PROT.READ,
        .{ .TYPE = .SHARED },
        file.handle,
        0,
    );

    return @ptrCast(@alignCast(mapped_memory.ptr));
}

pub fn get_data_snapshot(shared_ptr: *volatile IPCData) IPCData {
    while (true) {
        const start_seq = shared_ptr.update_count;

        if (start_seq % 2 != 0) {
            std.Thread.yield() catch {};
            continue;
        }

        const snapshot = IPCData{
            .update_count = start_seq,
            .fps = shared_ptr.fps,
            .frametime = shared_ptr.frametime,
            .min_frametime = shared_ptr.min_frametime,
            .max_frametime = shared_ptr.max_frametime,
            .cpu_percent = shared_ptr.cpu_percent,
            .gpu_load = shared_ptr.gpu_load,
        };

        const end_seq = shared_ptr.update_count;

        if (start_seq == end_seq) {
            return snapshot;
        }

        std.Thread.yield() catch {};
    }
}
