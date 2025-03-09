#include "script_component.hpp"

params ["_from"];

private _max = 0;

{
    private _data = [_x] call FUNC(radioData);
    private _freq = _data getVariable "frequencyTX";
    if (_from == _x) then { continue };
    ("aid" callExtension ["mesh:get", [_from, _x, _freq]]) params ["_ret", "_code"];
    if (_code == 0) then {
        _ret = parseSimpleArray _ret;
        _max = _max max (_ret select 0);
    } else {
        if aid_debug then {
            WARNING_1("Failed to get chain: %1",_ret);
        };
    };
} forEach ([] call acre_api_fnc_getCurrentRadioList);

_max
