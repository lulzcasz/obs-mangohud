const std = @import("std");
const shm = @import("shm");

pub fn main() !void {
    const shm_ptr = try shm.get_shm_ptr();
    var last_seq: u64 = 0;

    while (true) {
        const data = shm.get_shm_snapshot(shm_ptr);

        if (data.update_count != last_seq) {
            last_seq = data.update_count;

            std.debug.print("\x1B[2J\x1B[H", .{});
            std.debug.print("Update count  : {d}\n", .{data.update_count});

            std.debug.print("FPS           : {d:.0}\n", .{data.metrics.fps});

            std.debug.print("Frametime     : {d:.1} ms\n", .{data.metrics.frametime});
            std.debug.print("Min frametime : {d:.1} ms\n", .{data.metrics.min_frametime});
            std.debug.print("Max frametime : {d:.1} ms\n", .{data.metrics.max_frametime});

            std.debug.print("CPU percent   : {d:.0}%\n", .{data.metrics.cpu_percent});
            std.debug.print("GPU load      : {d}%\n", .{data.metrics.gpu_load});
        }

        std.Thread.sleep(5 * std.time.ns_per_ms);
    }
}
