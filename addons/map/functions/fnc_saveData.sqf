#include "script_component.hpp"

params ["_radio", "_object"];

private _data = GVAR(owners) getOrDefaultCall [_radio, { createHashmap }, true];

if (_object isKindOf "Man") then {
    _data set ["name", name _object];
    if (alive _object && {[_object, "team"] call EFUNC(network,hasCapability)}) then {
        _data set ["color", [_object] call FUNC(color)];
    };
};
_data set ["id", netId _object];
