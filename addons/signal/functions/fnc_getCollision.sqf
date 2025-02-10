#include "..\script_component.hpp"

params ["_f", "_start", "_end", ["_ig1", objNull], ["_ig2", objNull]];

private _disruptStrength = 0;
private _hits = 0;

// change the impact based on the frequency
private _frequencyRatio = linearConversion [10, 10000, _f, 1, 20, true];
private _terrainDisrupt = 0.015 * _frequencyRatio;
private _objectDisrupt = 0.005 * _frequencyRatio;

while {true} do {
    private _intersects = lineIntersectsSurfaces [_start, _end, _ig1, _ig2, true, 1];
    if (count _intersects == 0) then {break};
    (_intersects select 0) params ["_pos", "_normal", "_obj"];
    // Ignore the first hit if it's too close to the start
    if (_hits == 0 && {_pos distance _start < 1}) then {
        _pos = _pos vectorAdd (vectorNormalized (_start vectorFromTo _end) vectorMultiply 3);
        _hits = 1;
    } else {
        if (isNull _obj) then { // terrain
            _disruptStrength = _disruptStrength + _terrainDisrupt;
            _pos = _pos vectorAdd (vectorNormalized (_start vectorFromTo _end) vectorMultiply 25);
        } else {
            _disruptStrength = _disruptStrength + _objectDisrupt;
            _pos = _pos vectorAdd (vectorNormalized (_start vectorFromTo _end) vectorMultiply 3);
        };
    };
    if (_pos distance _end < 15) then {break};
    if (_disruptStrength >= 1) then {break};
    _start = _pos;
    _ig1 = _obj;
};

if (_disruptStrength >= 1) exitWith { 1 };

_disruptStrength + (linearConversion [100, 3000, _start distance _end, 0, 1, true] * ((rain / 10) * _frequencyRatio));
