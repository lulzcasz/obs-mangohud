#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct {
    uint64_t update_count;
    double fps;
    double frametime;
    double min_frametime;
    double max_frametime;
    double cpu_percent;
    int32_t gpu_load;
} IPCData;

extern IPCData* get_ipc_data_ptr();

int main() {
    printf("C IPC watcher started!\n");

    IPCData *ipc_data = get_ipc_data_ptr();

    printf("Update count: %" PRIu64 "\n", ipc_data->update_count);
    printf("FPS: %f\n", ipc_data->fps);
    printf("Frametime: %f\n", ipc_data->frametime);
    printf("Min frametime: %f\n", ipc_data->min_frametime);
    printf("Max frametime: %f\n", ipc_data->max_frametime);
    printf("CPU percent: %f\n", ipc_data->cpu_percent);
    printf("GPU load: %d\n", ipc_data->gpu_load);

    return 0;
}
