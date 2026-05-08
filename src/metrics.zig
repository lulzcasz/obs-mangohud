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

pub fn process_metrics(raw_metrics: shm.MangoHudMetrics) ProcessedMetrics {
    return ProcessedMetrics{
        .fps = @intFromFloat(@round(raw_metrics.fps)),
        .frametime = raw_metrics.frametime,
        .min_frametime = @floatCast(raw_metrics.min_frametime),
        .max_frametime = @floatCast(raw_metrics.max_frametime),
        .cpu_percent = @intFromFloat(@round(raw_metrics.cpu_percent)),
        .gpu_load = raw_metrics.gpu_load,
    };
}
