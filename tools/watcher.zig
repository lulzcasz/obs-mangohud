const std = @import("std");
const ipc = @import("ipc");

pub fn main() !void {
    std.debug.print("Zig IPC watcher started!\n", .{});

    const msg = ipc.message_from_ipc();
    std.debug.print("Message from IPC: {s}\n", .{msg});
}
