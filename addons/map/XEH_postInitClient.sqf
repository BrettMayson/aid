#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

// Altitude offset
GVAR(altitudeOffset) = 0;
[{
    GVAR(altitudeOffset) = missionNamespace getVariable ["ace_common_mapAltitude", getNumber (configFile >> "CfgWorlds" >> worldName >> "elevationOffset")]
}, 1] call CBA_fnc_waitAndExecute;

GVAR(sources) = createHashMap;

#define OUTER_SIZE 0.6
#define INNER_SIZE 0.3

FUNC(createMarker) = {
    params ["_netId"];
    private _inner = format ["aid_inner_%1", _netId];
    private _outer = format ["aid_outer_%1", _netId];
    private _markers = GVAR(sources) getOrDefault [_netId, [], true];
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

[QEGVAR(contacts,update), {
    params ["_id", "_data"];
    if (!GVAR(bft_enabled)) exitWith {};
    private _object = objectFromNetId _id;
    private _gps = [_object, "gps"] call EFUNC(network,hasCapability);
    private _status = ["ColorGrey", "ColorWhite"] select _gps;
    private _markers = GVAR(sources) getOrDefaultCall [_id, {
        [[_id] call FUNC(createMarker)]
    }];
    {
        _x params ["_inner", "_outer"];
        if (_gps) then {
            _inner setMarkerPosLocal (getPos _object);
            _outer setMarkerPosLocal (getPos _object);
            _inner setMarkerAlphaLocal 1;
            _outer setMarkerAlphaLocal 1;
        } else {
            _inner setMarkerAlphaLocal 0.6;
            _outer setMarkerAlphaLocal 0.6;
        };
        _inner setMarkerColorLocal _status;
        _outer setMarkerColorLocal (_data getOrDefault ["color", "ColorGrey"]);
    } forEach _markers;
}] call CBA_fnc_addEventHandler;

[QEGVAR(contacts,lost), {
    params ["_id"];
    if (!GVAR(bft_enabled)) exitWith {};
    private _object = objectFromNetId _id;
    if (player distance _object < 40) then {
        WARNING_2("Lost contact with %1 at range of only %2m",_object,round (player distance _object));
    };
    private _markers = GVAR(sources) getOrDefault [_id, []];
    {
        _x params ["_inner", "_outer"];
        _inner setMarkerColorLocal "ColorBlack";
        _inner setMarkerAlphaLocal 0.3;
        _outer setMarkerAlphaLocal 0.3;
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
    // TODO: Don't run PFH if not enabled
    if (GVAR(bft_enabled)) exitWith {};
    if !([acre_player, "gps"] call EFUNC(network,hasCapability)) exitWith {
        "aid_player_inner" setMarkerAlphaLocal 0;
        "aid_player_outer" setMarkerAlphaLocal 0;
    };
    "aid_player_inner" setMarkerAlphaLocal 1;
    "aid_player_outer" setMarkerAlphaLocal 1;
    private _color = [acre_player] call EFUNC(contacts,color);
    if (_color != "") then {
        "aid_player_outer" setMarkerColorLocal _color;
    };
    "aid_player_inner" setMarkerPosLocal (getPos acre_player);
    "aid_player_outer" setMarkerPosLocal (getPos acre_player);
}, 0.1] call CBA_fnc_addPerFrameHandler;

["visibleMap", {
    if (!GVAR(bft_enabled)) exitWith {};
    GVAR(cursorMoved) = diag_tickTime;
    GVAR(cursorChecked) = false;
}, true] call CBA_fnc_addPlayerEventHandler;
