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

[
    QGVAR(disableTISignal),
    "SLIDER",
    "TI Signal Threshold",
    "AID - UAV",
    [0,1,0.7,2,true],
    1
] call CBA_fnc_addSetting;

