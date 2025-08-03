#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(iconCache) = createHashMap;
GVAR(colorCache) = createHashMap;

GVAR(menuStack) = [];

_fnc_numpad = {
    params ["_line"];
    switch (_line) do {
        case 0: { DIK_NUMPAD0 };
        case 1: { DIK_NUMPAD1 };
        case 2: { DIK_NUMPAD2 };
        case 3: { DIK_NUMPAD3 };
        case 4: { DIK_NUMPAD4 };
        case 5: { DIK_NUMPAD5 };
        case 6: { DIK_NUMPAD6 };
        case 7: { DIK_NUMPAD7 };
        case 8: { DIK_NUMPAD8 };
        case 9: { DIK_NUMPAD9 };
    };
};

[
    "AID - ISR",
    "aid_isr_menuLine0",
    "Back / Exit",
    {
        _this call FUNC(menu_keybind);
    },
    {},
    [[0] call _fnc_numpad, [false, false, false]]
] call CBA_fnc_addKeybind;
for "_i" from 1 to 9 do {
    [
        "AID - ISR",
        format ["aid_isr_menuLine%1", _i],
        format ["Menu %1", _i],
        {
            _this call FUNC(menu_keybind);
        },
        {},
        [[_i] call _fnc_numpad, [false, false, false]]
    ] call CBA_fnc_addKeybind;
};

ADDON = true;
