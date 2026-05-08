const std = @import("std");
const shm = @import("shm");
const metrics = @import("metrics");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const shm_ptr = try shm.get_shm_ptr(io);
    var last_seq: u64 = 0;

    const GPU_IDX: usize = @intCast(@intFromEnum(shm.MetricFlag.PARAM_GPU_USAGE));
    const CPU_IDX: usize = @intCast(@intFromEnum(shm.MetricFlag.PARAM_CPU_USAGE));

    while (true) {
        const data = shm.get_shm_snapshot(shm_ptr);

        if (data.update_count != last_seq) {
            last_seq = data.update_count;

            const processed = metrics.process_metrics(data.metrics);

            std.debug.print("\x1B[2J\x1B[H", .{});

            std.debug.print("FPS            : {d}\n", .{processed.fps});
            std.debug.print("Frametime      : {d:.1} ms\n", .{processed.frametime});
            std.debug.print("Min frametime  : {d:.1} ms\n", .{processed.min_frametime});
            std.debug.print("Max frametime  : {d:.1} ms\n\n", .{processed.max_frametime});

            std.debug.print("--- Active Parameters ---\n", .{});

            if (data.param_enabled[GPU_IDX]) {
                std.debug.print("GPU load       : {d}%\n", .{processed.gpu_load});
            } else {
                std.debug.print("GPU load       : DISABLED (Escondido pelo usuário)\n", .{});
            }

            if (data.param_enabled[CPU_IDX]) {
                std.debug.print("CPU percent    : {d}%\n", .{processed.cpu_percent});
            } else {
                std.debug.print("CPU percent    : DISABLED (Escondido pelo usuário)\n", .{});
            }

            std.debug.print("-------------------------\n", .{});
        }

        try io.sleep(.fromMilliseconds(5), .awake);
    }
}
