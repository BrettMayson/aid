#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

[QGVAR(getRadios), {
    params ["_target"];
    [QGVAR(syncRadios), +acre_sys_server_masterIdList, _target] call CBA_fnc_targetEvent;
}] call CBA_fnc_addEventHandler;

GVAR(owners) = createHashMap;

[{
    private _radios = +acre_sys_server_masterIdList;
    // Check for radios in allRadios that are not in the masterIdList
    {
        if (!(_x in _radios)) then {
            [QGVAR(removeRadio), _x] call CBA_fnc_globalEvent;
            GVAR(owners) deleteAt _x;
        };
    } forEach GVAR(allRadios);
    // Check for radios in the masterIdList that are not in allRadios
    {
        if (!(_x in GVAR(allRadios))) then {
            private _owner = netId ([_x] call acre_sys_radio_fnc_getRadioObject);
            [QGVAR(addRadio), [_x, _owner]] call CBA_fnc_globalEvent;
            GVAR(owners) set [_x, _owner];
        };
    } forEach _radios;
    // Check if a radio owner has changed
    {
        private _owner = netId ([_x] call acre_sys_radio_fnc_getRadioObject);
        if (GVAR(owners) get _x != _owner) then {
            GVAR(owners) set [_x, _owner];
            [QGVAR(ownerChange), [_x, _owner]] call CBA_fnc_globalEvent;
        };
    } forEach _radios;
    [{
        [QGVAR(syncCount), _this] call CBA_fnc_globalEvent;
    }, count _radios, 1] call CBA_fnc_waitAndExecute;
}, 3] call CBA_fnc_addPerFrameHandler;
