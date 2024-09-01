#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

[QGVAR(getRadios), {
    params ["_target"];
    [QGVAR(syncRadios), +acre_sys_server_masterIdList, _target] call CBA_fnc_targetEvent;
}] call CBA_fnc_addEventHandler;

[{
    private _radios = +acre_sys_server_masterIdList;
    // Check for radios in allRadios that are not in the masterIdList
    {
        if (!(_x in _radios)) then {
            [QGVAR(removeRadio), _x] call CBA_fnc_globalEvent;
        };
    } forEach GVAR(allRadios);
    // Check for radios in the masterIdList that are not in allRadios
    {
        if (!(_x in GVAR(allRadios))) then {
            [QGVAR(addRadio), _x] call CBA_fnc_globalEvent;
        };
    } forEach _radios;
    [{
        [QGVAR(syncCount), _x] call CBA_fnc_globalEvent;
    }, count _radios, 1] call CBA_fnc_waitAndExecute;
}, 3] call CBA_fnc_addPerFrameHandler;
