#include "script_component.hpp"

params ["_radio", "_object"];

private _data = GVAR(owners) getOrDefaultCall [_radio, { createHashmap }, true];

if (_object isKindOf "Man") then {
    _data set ["name", name _object];
};
_data set ["id", netId _object];
