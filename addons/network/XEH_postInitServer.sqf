#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

[QGVAR(getRadios), {
    params ["_target"];
    [QGVAR(syncRadios), +acre_sys_server_masterIdList, _target] call CBA_fnc_targetEvent;
}] call CBA_fnc_addEventHandler;

GVAR(owners) = createHashMap;
GVAR(previousRadios) = [];

[{
    private _radios = +acre_sys_server_masterIdList;
    // Check for radios in previousRadios that are not in the masterIdList
    {
        if (!(_x in _radios)) then {
            [QGVAR(removeRadio), _x] call CBA_fnc_globalEvent;
            GVAR(owners) deleteAt _x;
        };
    } forEach GVAR(previousRadios);
    // Check for radios in the masterIdList that are not in previousRadios
    {
        if (!(_x in GVAR(previousRadios))) then {
            private _owner = netId ([_x] call acre_sys_radio_fnc_getRadioObject);
            if (isNil "_owner") then {
                diag_log format ["%1: No owner found for radio %2", QGVAR(addRadio), _x];
                continue;
            };
            [QGVAR(addRadio), [_x, _owner]] call CBA_fnc_globalEvent;
            GVAR(owners) set [_x, _owner];
        };
    } forEach _radios;
    // Check if a radio owner has changed
    {
        private _owner = netId ([_x] call acre_sys_radio_fnc_getRadioObject);
        if (isNil "_owner") then {
            diag_log format ["%1: No owner found for radio %2", QGVAR(ownerChange), _x];
            continue;
        };
        if (GVAR(owners) getOrDefault [_x, ""] != _owner) then {
            GVAR(owners) set [_x, _owner];
            [QGVAR(ownerChange), [_x, _owner]] call CBA_fnc_globalEvent;
        };
    } forEach _radios;
    GVAR(previousRadios) = _radios;
}, 1] call CBA_fnc_addPerFrameHandler;

[{
    [QGVAR(syncCount), count acre_sys_server_masterIdList] call CBA_fnc_globalEvent;
}, 10] call CBA_fnc_addPerFrameHandler;
