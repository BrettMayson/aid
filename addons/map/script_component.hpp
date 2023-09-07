#define COMPONENT map
#include "..\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_NETWORK
    #define DEBUG_MODE_FULL
#endif
    #ifdef DEBUG_SETTINGS_OTHER
    #define DEBUG_SETTINGS DEBUG_SETTINGS_NETWORK
#endif

#include "..\main\script_macros.hpp"

#define ID_EG_MAP_CONTROL 63909
#define ID_EG_MAP_CONTROLGROUP 62609
#define ID_DIARY_MAP 51
