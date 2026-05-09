#include <obs/obs-module.h>
#include "mangohud.h"

OBS_DECLARE_MODULE()
OBS_MODULE_USE_DEFAULT_LOCALE("mangohud", "en-US")

bool obs_module_load(void)
{
    mangohud_load();
    blog(LOG_INFO, "mangohud plugin loaded");
    return true;
}

void obs_module_unload(void)
{
    mangohud_unload();
    blog(LOG_INFO, "mangohud plugin unloaded");
}
