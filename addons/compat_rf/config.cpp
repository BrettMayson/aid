#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = QUOTE(COMPONENT);
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"RF_Data_Loadorder", "aid_uav"};
        skipWhenMissingDependencies = 1;
        author = "AUTHOR";
        VERSION_CONFIG;
    };
};

#include "CfgVehicles.hpp"
