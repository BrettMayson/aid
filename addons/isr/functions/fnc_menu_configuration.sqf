#include "..\script_component.hpp"

params ["_command", "_arg"];

_fnc_draw = {
    private _menu = [
        "CONFIGURATION",
        format ["SPEED: %1", GVAR(speedCurrentMode)],
        format ["ALTITUDE: %1", GVAR(altCurrentMode)]
    ];
    if (GVAR(isUAV)) then {
        _menu pushBack "POWER SETTINGS";
    };
    _menu call FUNC(menu_draw);
};

switch (_command) do {
    case "open": {
        GVAR(menuStack) pushBack ["configuration", { _this call FUNC(menu_configuration) }, []];
        call _fnc_draw;
    };
    case "return": {
        call _fnc_draw;
    };
    case "key": {
        switch (_arg) do {
            case 1: {
                if (GVAR(speedCurrentMode) == "KM/H") then {
                    GVAR(speedCurrentMode) = "M/S";
                } else {
                    GVAR(speedCurrentMode) = "KM/H";
                };
                call _fnc_draw;
            };
            case 2: {
                if (GVAR(altCurrentMode) == "ASL") then {
                    GVAR(altCurrentMode) = "AGL";
                } else {
                    GVAR(altCurrentMode) = "ASL";
                };
                call _fnc_draw;
            };
            case 3: {
                ["open", ""] call FUNC(menu_power);
            };
        };
    };
};
