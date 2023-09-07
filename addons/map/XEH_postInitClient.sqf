#include "script_component.hpp"

GVAR(sources) = createHashmap;
GVAR(counter) = 0;

FUNC(createMarker) = {
    params ["_id", "_unit"];
    private _name = format ["aid_%1", GVAR(counter)];
    GVAR(counter) = GVAR(counter) + 1;
    GVAR(sources) set [_id, _name];
    createMarkerLocal [_name, getPos _unit];
    _name setMarkerTypeLocal "mil_dot";
    _name setMarkerSizeLocal [0.5, 0.5];
    _name
};

[QEGVAR(network,peerInRange), {
    params ["_unit"];
    if !([_unit, "gps"] call EFUNC(network,hasCapability)) exitWith {};
    private _id = _unit call BIS_fnc_netId;
    private _name = GVAR(sources) getOrDefaultCall [_id, {
        [_id, _unit] call FUNC(createMarker)
    }, true];
    _name setMarkerPosLocal (getPos _unit);
    _name setMarkerColorLocal "ColorWEST";
}] call CBA_fnc_addEventHandler;

[QEGVAR(network,peerLost), {
    params ["_unit"];
    private _id = _unit call BIS_fnc_netId;
    private _name = GVAR(sources) getOrDefaultCall [_id, {
        [_id, _unit] call FUNC(createMarker)
    }, true];
    _name setMarkerColorLocal "ColorBlack";
}] call CBA_fnc_addEventHandler;

createMarkerLocal ["aid_player", getPos player];
"aid_player" setMarkerTypeLocal "mil_dot";
"aid_player" setMarkerSizeLocal [0.5, 0.5];
"aid_player" setMarkerColorLocal "ColorYellow";
[{
    "aid_player" setMarkerPosLocal (getPos player);
}, 2] call CBA_fnc_addPerFrameHandler;
