#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

typedef struct {
    int32_t fps;
    float frametime;
    float min_frametime;
    float max_frametime;
    int32_t cpu_percent;
    int32_t gpu_load;
} ProcessedMetrics;

extern void mangohud_init(void);
extern ProcessedMetrics* get_metrics_ptr(void);

int main() {
    mangohud_init();

    ProcessedMetrics* metrics = get_metrics_ptr();

    while (1) {
        printf("\033[2J\033[H");
        printf("FPS           : %d\n", metrics->fps);
        printf("Frametime     : %.1f ms\n", metrics->frametime);
        printf("Min frametime : %.1f ms\n", metrics->min_frametime);
        printf("Max frametime : %.1f ms\n", metrics->max_frametime);
        printf("CPU percent   : %d%%\n", metrics->cpu_percent);
        printf("GPU load      : %d%%\n", metrics->gpu_load);

        usleep(5000);
    }

    return 0;
}
