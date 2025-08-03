#include "..\script_component.hpp"

params ["_command", "_arg"];

_fnc_draw = {
    [
        "ISR MENU",
        "CONFIGURATION"
    ] call FUNC(menu_draw);
};

switch (_command) do {
    case "open": {
        GVAR(menuStack) = [["main_menu", { _this call FUNC(menu_main) }, []]];
        call _fnc_draw;
    };
    case "key": {
        if (_arg == 1) then {
            ["open", ""] call FUNC(menu_configuration);
        };
    };
    case "return": {
        call _fnc_draw;
    };
};
