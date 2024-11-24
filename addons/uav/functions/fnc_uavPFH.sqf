#include "..\script_component.hpp"

params ["_args", "_handle"];

private _uav = GVAR(uav);

if (isNull _uav) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    GVAR(ppResolution) ppEffectEnable false;
};

// TODO define communication type, radio vs satcom

private _distance = ace_player distance _uav;

private _rayIgnore = _uav;
private _rayStart = getPosASL _uav;

private _disruptStrength = 0;
private _hits = 0;

while {true} do {
    private _intersects = lineIntersectsSurfaces [_rayStart, eyePos ace_player, _rayIgnore, ace_player, true, 1];
    if (count _intersects == 0) then {break};
    _hits = _hits + 1;
    (_intersects select 0) params ["_pos", "_normal", "_obj"];
    if (isNull _obj) then { // terrain
        _disruptStrength = _disruptStrength + 0.1;
        _pos = _pos vectorAdd (vectorNormalized (getPosASL _uav vectorFromTo getPosASL ace_player) vectorMultiply 15);
    } else {
        _disruptStrength = _disruptStrength + 0.05;
        _pos = _pos vectorAdd (vectorNormalized (getPosASL _uav vectorFromTo getPosASL ace_player) vectorMultiply 5);
    };
    if (_pos distance eyePos ace_player < 20) then {break};
    _rayStart = _pos;
    _rayIgnore = _obj;
};

private _distanceLOS = linearConversion [8, 12000, _distance, 0, 0.75, true];

_disruptStrength = _disruptStrength + _distanceLOS;

if (_distance > 8) then {
    // old film grain
    // GVAR(ppResolution) ppEffectAdjust [1.5 min _disruptStrength, 0.1 max (1 - _disruptStrength), 1.25, 0.75, 0.75];
    GVAR(ppResolution) ppEffectAdjust [GVAR(maxRes) / (1 + _disruptStrength * 6)];
    GVAR(ppResolution) ppEffectCommit 0.25;
    GVAR(ppResolution) ppEffectEnable true;
    equipmentDisabled _uav params ["", "_ti"];
    private _desired = _disruptStrength > 0.15;
    if (_desired != _ti) then {
        _uav disableTIEquipment _desired;
    };
} else {
    GVAR(ppResolution) ppEffectEnable false;
};
