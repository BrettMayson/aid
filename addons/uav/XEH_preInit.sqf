#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
ADDON = true;

[
    QGVAR(pixelate),
    "CHECKBOX",
    "Pixelate",
    "AID - UAV",
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(showSignal),
    "CHECKBOX",
    "Show Signal",
    "AID - UAV",
    true,
    0
] call CBA_fnc_addSetting;
