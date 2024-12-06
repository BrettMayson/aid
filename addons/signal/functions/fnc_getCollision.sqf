#include "..\script_component.hpp"

params ["_start", "_end", ["_ig1", objNull], ["_ig2", objNull]];

private _disruptStrength = 0;
private _hits = 0;

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
            _disruptStrength = _disruptStrength + 0.05;
            _pos = _pos vectorAdd (vectorNormalized (_start vectorFromTo _end) vectorMultiply 12);
        } else {
            _disruptStrength = _disruptStrength + 0.01;
            _pos = _pos vectorAdd (vectorNormalized (_start vectorFromTo _end) vectorMultiply 3);
        };
    };
    if (_pos distance _end < 15) then {break};
    _start = _pos;
    _ig1 = _obj;
};

_disruptStrength
