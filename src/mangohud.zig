const std = @import("std");
const shm = @import("shm");
const metrics = @import("metrics");

var global_metrics: metrics.ProcessedMetrics = std.mem.zeroInit(
    metrics.ProcessedMetrics,
    .{},
);

export fn get_metrics_ptr() *metrics.ProcessedMetrics {
    return &global_metrics;
}

fn engine_loop() void {
    var threaded = std.Io.Threaded.init(std.heap.c_allocator, .{});
    defer threaded.deinit();

    const io = threaded.io();

    const shm_ptr = shm.get_shm_ptr(io) catch return;
    var last_seq: u64 = 0;

    while (true) {
        const data = shm.get_shm_snapshot(shm_ptr);
        if (data.update_count != last_seq) {
            last_seq = data.update_count;
            global_metrics = metrics.process_metrics(data.metrics);
        }

        io.sleep(.fromMilliseconds(5), .awake) catch {};
    }
}

export fn mangohud_init() void {
    const thread = std.Thread.spawn(
        .{},
        engine_loop,
        .{},
    ) catch return;
    thread.detach();
}
