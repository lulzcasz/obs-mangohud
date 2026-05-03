#pragma once
#include <stdint.h>
#include <stdbool.h>

typedef enum {
    PARAM_GPU_USAGE,
    PARAM_CPU_USAGE,
    PARAM_ENABLED_MAX
} MetricFlag;

struct MangoHudMetrics {
    float fps;
    float frametime;
    double min_frametime;
    double max_frametime;
    float cpu_percent;
    int32_t gpu_load;
};

struct MangoHudSHM {
    uint64_t update_count;
    bool param_enabled[PARAM_ENABLED_MAX];
    struct MangoHudMetrics metrics; 
};

struct ProcessedMetrics {
    int32_t fps;
    float frametime;
    float min_frametime;
    float max_frametime;
    int32_t cpu_percent;
    int32_t gpu_load;
};
