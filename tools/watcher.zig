const std = @import("std");
const ipc = @import("ipc");

pub fn main() !void {
    const shm_ptr = try ipc.get_ipc_data_ptr();
    var last_seq: u64 = 0;

    while (true) {
        const data = ipc.get_data_snapshot(shm_ptr);

        if (data.update_count != last_seq) {
            last_seq = data.update_count;

            std.debug.print("\x1B[2J\x1B[H", .{});
            std.debug.print("Update count  : {d}\n", .{data.update_count});

            std.debug.print("FPS           : {d:.0}\n", .{data.fps});

            std.debug.print("Frametime     : {d:.1} ms\n", .{data.frametime});
            std.debug.print("Min frametime : {d:.1} ms\n", .{data.min_frametime});
            std.debug.print("Max frametime : {d:.1} ms\n", .{data.max_frametime});

            std.debug.print("CPU percent   : {d:.0}%\n", .{data.cpu_percent});
            std.debug.print("GPU load      : {d}%\n", .{data.gpu_load});
        }

        std.Thread.sleep(5 * std.time.ns_per_ms);
    }
}
