#include "..\script_component.hpp"

if !(call FUNC(isISR)) exitWith {false};

private _line = parseNumber ((_this select 6) select [26,1]);

if (count GVAR(menuStack) == 0) exitWith {
    ["open", ""] call FUNC(menu_main);
    true
};

if (_line == 0) exitWith {
    private _removed = GVAR(menuStack) deleteAt (count GVAR(menuStack) - 1);
    ["close", ""] call (_removed select 1);
    if (count GVAR(menuStack) > 0) then {
        private _menu = GVAR(menuStack) select -1;
        ["return", _line] call (_menu select 1);
    } else {
        [] call FUNC(menu_draw);
    };
};

private _menu = GVAR(menuStack) select -1;
["key", _line] call (_menu select 1);

true
