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

var ipc_data: IPCData = undefined;

pub export fn get_ipc_data_ptr() *IPCData {
    ipc_data = .{
        .update_count = 123,
        .fps = 123.456,
        .frametime = 23.23154,
        .min_frametime = 2.4348,
        .max_frametime = 25.1238545,
        .cpu_percent = 0.9192385,
        .gpu_load = 98,
    };

    return &ipc_data;
}
