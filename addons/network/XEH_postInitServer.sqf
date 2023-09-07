#include "script_component.hpp"

[{
    missionNamespace setVariable [QGVAR(allRadios), +acre_sys_server_masterIdList, true];
}, 3] call CBA_fnc_addPerFrameHandler;
