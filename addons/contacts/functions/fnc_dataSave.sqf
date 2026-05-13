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

// Collect marker deltas from contact's replicated data
// Only include markers that are newer than what we have locally
private _markerDeltas = [];
private _remoteMarkerData = _object getVariable [QEGVAR(markers,markerData), createHashMap];
private _localMarkers = missionNamespace getVariable [QEGVAR(markers,markers), createHashMap];

if (count _remoteMarkerData > 0) then {
    {
        private _markerId = _x;
        private _remoteState = _remoteMarkerData get _markerId;
        private _localState = _localMarkers getOrDefault [_markerId, createHashMap];
        
        // Only include if remote has it and either we don't or theirs is newer
        private _remoteTimestamp = _remoteState getOrDefault ["timestamp", -1];
        private _localTimestamp = _localState getOrDefault ["timestamp", -1];
        
        if (_remoteTimestamp > _localTimestamp) then {
            // Build delta with all properties from remote state
            private _delta = createHashMap;
            {
                _delta set [_x, _remoteState get _x];
            } forEach (keys _remoteState);
            _delta set ["id", _markerId];
            _markerDeltas pushBack _delta;
        };
    } forEach (keys _remoteMarkerData);
};

if (_markerDeltas isNotEqualTo []) then {
    _data set ["markerDeltas", _markerDeltas];
};

GVAR(contactData) set [netId _object, _data];

_data
