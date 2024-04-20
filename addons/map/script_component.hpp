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

#define ID_DIARY_MAP 51

#define PEER_WIDTH 0.3
#define IDC_PEER 436500
#define IDC_PEER_NAME 436501
#define IDC_PEER_INFO 436502
