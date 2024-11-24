#include "..\script_component.hpp"

params ["_object", "_radios"];

private _data = createHashMap;

private _radiosData = createHashMap;
{
    private _radioData = createHashMap;
    _radioData set ["name", [_x] call acre_api_fnc_getDisplayName];
    _radioData set ["channelNumber", [_x, "getCurrentChannel"] call acre_sys_data_fnc_dataEvent];
    _radioData set ["channelDescription", [_x, "getChannelDescription"] call acre_sys_data_fnc_dataEvent];
    _radiosData set [_x, _radioData];
} forEach _radios;

_data set ["radios", _radiosData];

if (_object isKindOf "Man") then {
    private _name = name _object;
    if (_name != "" && {(_object getVariable [QGVAR(name), ""]) == ""}) then {
        _object setVariable [QGVAR(name), _name, true];
    } else {
        _name = _object getVariable [QGVAR(name), ""];
    };
    _data set ["name", _name];
    if ([_object, "team"] call EFUNC(network,hasCapability)) then {
        private _color = [_object] call FUNC(color);
        if (_color != "") then {
            _data set ["color", _color];
        };
    };
} else {
    _data set ["name", getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName")];
};
_data set ["id", netId _object];
_data set ["lastSeen", dayTime];
_data set ["speed", vectorMagnitude velocity _object];
_data set ["bearing", getDir _object];
_data set ["altitude", getPosASL _object select 2];

_data set ["trail", [_object] call FUNC(trail)];

GVAR(contactData) set [netId _object, _data];

_data
