const std = @import("std");
const shm = @import("shm");

const c = @cImport({
    @cInclude("metrics.h");
});

pub const ProcessedMetrics = c.struct_ProcessedMetrics;

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
