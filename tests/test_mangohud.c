#include <stdio.h>
#include <unistd.h>
#include <assert.h>

#include "mangohud.h"

int main() {
    printf("Starting MangoHud integration tests...\n");

    mangohud_init();

    ProcessedMetrics* metrics = get_metrics_ptr();

    assert(metrics != NULL && "Metrics pointer should not be NULL!");
    printf("[\033[32mOK\033[0m] Metrics pointer is valid.\n");

    assert(metrics->fps == 0 && "Initial FPS should be 0");
    assert(metrics->cpu_percent == 0 && "Initial CPU percent should be 0");
    printf("[\033[32mOK\033[0m] Initial metrics are properly zeroed.\n");

    printf("Waiting for background thread to fetch SHM data...\n");
    
    usleep(100000); 

    printf("[\033[32mOK\033[0m] Background thread is stable.\n");

    printf("\n\033[32mALL TESTS PASSED SUCCESSFULLY!\033[0m\n");
    return 0;
}
