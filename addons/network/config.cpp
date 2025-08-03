#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {QGVAR(item)};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { "aid_main" };
        author = "AUTHOR";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
