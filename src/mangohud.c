#include <obs-module.h>

OBS_DECLARE_MODULE()
OBS_MODULE_USE_DEFAULT_LOCALE(PLUGIN_NAME, "en-US")

bool obs_module_load(void) {
    blog(LOG_INFO, "[%s] plugin loaded successfully (version %s)", PLUGIN_NAME, PLUGIN_VERSION);
    return true;
}

void obs_module_unload(void) {
    blog(LOG_INFO, "[%s] plugin unloaded", PLUGIN_NAME);
}
