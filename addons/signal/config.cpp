#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = { "aid_main" };
        author = "AUTHOR";
        VERSION_CONFIG;
    };
};

class CfgFunctions {
    class GVAR(acre_override) {
        tag = "acre_sys_signal";
        class acre_sys_signal {
            class getSignalCore {
                file = QPATHTOF(functions\fnc_getAcreSignal.sqf);
            };
        };
    };
};

#include "CfgEventHandlers.hpp"
