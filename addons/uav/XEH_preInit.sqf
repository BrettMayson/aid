#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
ADDON = true;

GVAR(freq) = 1300;
GVAR(power) = 2000;

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
