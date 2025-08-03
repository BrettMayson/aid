#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
ADDON = true;

GVAR(satCacheExpiry) = 0;
GVAR(nextSignalAdjust) = 0;

[
    QGVAR(enabled),
    "CHECKBOX",
    "Enabled",
    "AID - UAV",
    true,
    1
] call CBA_fnc_addSetting;

