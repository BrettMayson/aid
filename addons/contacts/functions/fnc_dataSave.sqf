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
        _object getVariable [QGVAR(name), "Unknown"]
    };
    if (_name != "" && _name != "Error: No unit") then {
        _object setVariable [QGVAR(name), _name];
    };
    _data set ["name", _name];
    if ([_object, "team"] call EFUNC(network,hasCapability)) then {
        private _color = [_object] call FUNC(color);
        if (_color != "") then {
            _data set ["color", _color];
        };
    };
} else {
    _data set ["name", _object getVariable [QGVAR(name), getText (configOf _object >> "displayName")]];
};

if ([_object, "gps"] call EFUNC(network,hasCapability)) then {
    _data set ["posASL", getPosASL _object];
    _data set ["speed", vectorMagnitude velocity _object];
    _data set ["bearing", getDir _object];
    _data set ["trail", [_object] call FUNC(trail)];
};

_data set ["id", netId _object];
_data set ["lastSeen", dayTime];

// Collect marker deltas if markers addon is available
private _markerDeltas = [];
private _remoteMarkers = missionNamespace getVariable [QEGVAR(markers,remoteMarkers), createHashMap];
private _allMarkers = missionNamespace getVariable [QEGVAR(markers,markers), createHashMap];
if (count _remoteMarkers > 0) then {
    private _contactNetId = ((netId _object) splitString ":") select 0;
    {
        private _markerId = _x;
        private _markerData = _remoteMarkers get _markerId;
        
        // Only include markers from this contact
        if ((_markerData getOrDefault ["source_netId", -1]) == _contactNetId) then {
            // Get the full delta if available
            private _markerState = _allMarkers getOrDefault [_markerId, createHashMap];
            if (count _markerState > 0) then {
                private _delta = createHashMap;
                {
                    _delta set [_x, _markerState get _x];
                } forEach (keys _markerState);
                _delta set ["id", _markerId];
                _markerDeltas pushBack _delta;
            };
        };
    } forEach (keys _remoteMarkers);
};

if (_markerDeltas isNotEqualTo []) then {
    _data set ["markerDeltas", _markerDeltas];
};

GVAR(contactData) set [netId _object, _data];

_data
