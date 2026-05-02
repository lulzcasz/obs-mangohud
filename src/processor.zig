const std = @import("std");
const shm = @import("shm");

pub const ProcessedMetrics = extern struct {
    fps: i32,
    frametime: f32,
    min_frametime: f32,
    max_frametime: f32,
    cpu_percent: i32,
    gpu_load: i32,
};

pub fn process_metrics(metrics: shm.MangoHudMetrics) ProcessedMetrics {
    return ProcessedMetrics{
        .fps = @intFromFloat(@round(metrics.fps)),
        .frametime = metrics.frametime,
        .min_frametime = @floatCast(metrics.min_frametime),
        .max_frametime = @floatCast(metrics.max_frametime),
        .cpu_percent = @intFromFloat(@round(metrics.cpu_percent)),
        .gpu_load = metrics.gpu_load,
    };
}
