const std = @import("std");
const shm = @import("shm");
const processor = @import("processor");

var global_metrics: processor.ProcessedMetrics = std.mem.zeroInit(
    processor.ProcessedMetrics,
    .{},
);

export fn get_metrics_ptr() *processor.ProcessedMetrics {
    return &global_metrics;
}

fn engine_loop() void {
    const shm_ptr = shm.get_shm_ptr() catch return;
    var last_seq: u64 = 0;

    while (true) {
        const data = shm.get_shm_snapshot(shm_ptr);

        if (data.update_count != last_seq) {
            last_seq = data.update_count;

            global_metrics = processor.process_metrics(data.metrics);
        }

        std.Thread.sleep(5 * std.time.ns_per_ms);
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
