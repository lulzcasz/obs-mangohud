#pragma once
#include <stdint.h>

struct ProcessedMetrics {
    int32_t fps;
    float frametime;
    float min_frametime;
    float max_frametime;
    int32_t cpu_percent;
    int32_t gpu_load;
};
