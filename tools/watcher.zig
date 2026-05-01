const std = @import("std");
const ipc = @import("ipc");

pub fn main() !void {
    std.debug.print("Zig IPC watcher started!\n", .{});

    const ipc_data = ipc.get_ipc_data_ptr();

    std.debug.print("Update count: {d}\n", .{ipc_data.update_count});
    std.debug.print("FPS: {d:.2}\n", .{ipc_data.fps}); // :.2 limits to 2 decimal places
    std.debug.print("Frametime: {d:.4}\n", .{ipc_data.frametime});
    std.debug.print("Min frametime: {d:.4}\n", .{ipc_data.min_frametime});
    std.debug.print("Max frametime: {d:.4}\n", .{ipc_data.max_frametime});
    std.debug.print("CPU percent: {d:.2}%\n", .{ipc_data.cpu_percent});
    std.debug.print("GPU load: {d}\n", .{ipc_data.gpu_load});
}
