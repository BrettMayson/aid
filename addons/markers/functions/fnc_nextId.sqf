#include "..\script_component.hpp"

private _id = GVAR(nextId);
[QGVAR(nextIdInc)] call CBA_fnc_serverEvent;

format ["__USER_DEFINED %1_%2", QGVAR(tracked), _id]
