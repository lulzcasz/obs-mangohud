const std = @import("std");

export fn mangohud_load() void {
    std.log.info("mangohud_load called from Zig", .{});
}

export fn mangohud_unload() void {
    std.log.info("mangohud_unload called from Zig", .{});
}
