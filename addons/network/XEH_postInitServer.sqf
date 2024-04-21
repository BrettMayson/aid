#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

[{
    missionNamespace setVariable [QGVAR(allRadios), +acre_sys_server_masterIdList, true];
}, 3] call CBA_fnc_addPerFrameHandler;
