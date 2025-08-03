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

class CfgVehicles {
    class NonStrategic;
    class Lightning_F: NonStrategic {
        class EventHandlers {
            init = "systemChat 'lightning struck!';";
        };
        class SimpleObject {
            init = "systemChat 'lightning struck! (simple object)';";
        };
    };
    class Lightning1_F: NonStrategic {
        class EventHandlers {
            init = "systemChat 'lightning struck!';";
        };
        class SimpleObject {
            init = "systemChat 'lightning struck! (simple object)';";
        };
    };
};

#include "CfgEventHandlers.hpp"
