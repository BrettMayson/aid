#include "script_component.hpp"

GVAR(sources) = createHashmap;
GVAR(owners) = createHashmap;

#define OUTER_SIZE 0.6
#define INNER_SIZE 0.3

FUNC(createMarker) = {
    params ["_radio"];
    private _inner = format ["aid_inner_%1", _radio];
    private _outer = format ["aid_outer_%1", _radio];
    private _markers = GVAR(sources) getOrDefault [_radio, [], true];
    _markers pushBack [_inner, _outer];
    createMarkerLocal [_outer, [0,0,0]];
    _outer setMarkerTypeLocal "mil_dot";
    _outer setMarkerSizeLocal [OUTER_SIZE, OUTER_SIZE];
    _outer setMarkerColorLocal "ColorBlack";
    _outer setMarkerShadowLocal false;
    _outer setMarkerAlphaLocal 0;
    createMarkerLocal [_inner, [0,0,0]];
    _inner setMarkerTypeLocal "mil_dot";
    _inner setMarkerSizeLocal [INNER_SIZE, INNER_SIZE];
    _inner setMarkerShadowLocal false;
    _inner setMarkerAlphaLocal 0;
    [_inner, _outer]
};

[QEGVAR(network,peerDiscovered), {
    params ["_radio", "_object"];
    if !([_object, "gps"] call EFUNC(network,hasCapability)) exitWith {};
    [_radio] call FUNC(createMarker);
}] call CBA_fnc_addEventHandler;

[QEGVAR(network,peerInRange), {
    params ["_radio", "_object"];
    private _gps = [_object, "gps"] call EFUNC(network,hasCapability);
    private _status = if (_gps) then {
        "ColorWhite"
    } else {
        "ColorGrey"
    };
    [_radio, _object] call FUNC(saveData);
    private _color = [_object] call FUNC(color);
    private _markers = GVAR(sources) getOrDefaultCall [_radio, {
        [[_radio] call FUNC(createMarker)]
    }];
    {
        _x params ["_inner", "_outer"];
        if (_gps) then {
            _inner setMarkerPosLocal (getPos _object);
            _outer setMarkerPosLocal (getPos _object);
            _inner setMarkerAlphaLocal 1;
            _outer setMarkerAlphaLocal 1;
        };
        _inner setMarkerColorLocal _status;
        if (_color != "") then {
            _outer setMarkerColorLocal _color;
        };
    } forEach _markers;
}] call CBA_fnc_addEventHandler;

[QEGVAR(network,peerLost), {
    params ["_radio"];
    private _markers = GVAR(sources) getOrDefault [_radio, []];
    {
        _x params ["_inner", "_outer"];
        _inner setMarkerColorLocal "ColorBlack";
        _inner setMarkerAlphaLocal INNER_SIZE;
        _outer setMarkerAlphaLocal INNER_SIZE;
    } forEach _markers;
}] call CBA_fnc_addEventHandler;

createMarkerLocal ["aid_player_outer", getPos player];
"aid_player_outer" setMarkerTypeLocal "mil_dot";
"aid_player_outer" setMarkerSizeLocal [OUTER_SIZE, OUTER_SIZE];
"aid_player_outer" setMarkerColorLocal "ColorWhite";
"aid_player_outer" setMarkerShadowLocal false;
createMarkerLocal ["aid_player_inner", getPos player];
"aid_player_inner" setMarkerTypeLocal "mil_dot";
"aid_player_inner" setMarkerSizeLocal [INNER_SIZE, INNER_SIZE];
"aid_player_inner" setMarkerColorLocal "ColorYellow";
"aid_player_inner" setMarkerShadowLocal false;
[{
    private _color = [player] call FUNC(color);
    if (_color != "") then {
        "aid_player_outer" setMarkerColorLocal _color;
    };
    "aid_player_inner" setMarkerPosLocal (getPos player);
    "aid_player_outer" setMarkerPosLocal (getPos player);
}] call CBA_fnc_addPerFrameHandler;

["visibleMap", {
    GVAR(cursorMoved) = diag_tickTime;
    GVAR(cursorChecked) = false;
}, true] call CBA_fnc_addPlayerEventHandler;
