const std = @import("std");
const shm = @import("shm");
const processor = @import("processor");

pub fn main() !void {
    const shm_ptr = try shm.get_shm_ptr();
    var last_seq: u64 = 0;

    while (true) {
        const data = shm.get_shm_snapshot(shm_ptr);

        if (data.update_count != last_seq) {
            last_seq = data.update_count;

            const processed = processor.process_metrics(data.metrics);

            std.debug.print("\x1B[2J\x1B[H", .{});

            std.debug.print("FPS           : {d}\n", .{processed.fps});

            std.debug.print("Frametime     : {d:.1} ms\n", .{processed.frametime});
            std.debug.print("Min frametime : {d:.1} ms\n", .{processed.min_frametime});
            std.debug.print("Max frametime : {d:.1} ms\n", .{processed.max_frametime});

            std.debug.print("CPU percent   : {d}%\n", .{processed.cpu_percent});
            std.debug.print("GPU load      : {d}%\n", .{processed.gpu_load});
        }

        std.Thread.sleep(5 * std.time.ns_per_ms);
    }
}
