#include "..\script_component.hpp"

params ["_object"];

private _data = createHashMap;

("aid" callExtension ["player:connections", [netId _object]]) params ["_ret", "_code"];
if (_code != 0) exitWith {
    if (aid_debug) then {
        systemChat format ["player:connections: %1", _code];
    };
    _data
};
private _radios = parseSimpleArray _ret;
// Vec<(Radio, (Frequency, Radio, (Strength, Vec<(Radio, Strength, f32)>)))>

private _radiosData = createHashMap;
{
    private _radioData = createHashMap;
    _x params ["", "_info"];
    _info params ["", "_radio", "_connections"];
    _connections params ["_strength", "_chain"];
    private _channelNumber = [_radio, "getCurrentChannel"] call acre_sys_data_fnc_dataEvent;
    private _channelDescription = [_radio, "getChannelDescription"] call acre_sys_data_fnc_dataEvent;
    if (isNil "_channelNumber" || isNil "_channelDescription") exitWith {
        continue;
    };
    _radioData set ["name", [_radio] call acre_api_fnc_getDisplayName];
    _radioData set ["channelNumber", _channelNumber];
    _radioData set ["channelDescription", _channelDescription];
    _radioData set ["strength", _strength];
    _radioData set ["chain", _chain];
    _radiosData set [_radio, _radioData];
} forEach _radios;

_data set ["radios", _radiosData];

if (_object isKindOf "Man") then {
    private _name = if (alive _object) then {
        name _object
    } else {
        _name = _object getVariable [QGVAR(name), "Unknown"];
    };
    if (_name != "" && _name != "Error: No unit" && {(_object getVariable [QGVAR(name), ""]) == ""}) then {
        _object setVariable [QGVAR(name), _name, true];
    } else {
        _name = _object getVariable [QGVAR(name), "Unknown"];
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

if ([_object, "gps"] call EFUNC(network,hasCapability)) then {
    _data set ["posASL", getPosASL _object];
    _data set ["speed", vectorMagnitude velocity _object];
    _data set ["bearing", getDir _object];
    _data set ["trail", [_object] call FUNC(trail)];
};

_data set ["id", netId _object];
_data set ["lastSeen", dayTime];

GVAR(contactData) set [netId _object, _data];

_data
