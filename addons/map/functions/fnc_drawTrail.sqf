#include "..\script_component.hpp"

params ["_object", "_trail"];

{
    deleteMarkerLocal _x;
} forEach GVAR(trailMarkers);

{
    private _marker = format ["trailMarker_%1", _forEachIndex];
    createMarkerLocal [_marker, _x];
    _marker setMarkerTypeLocal "mil_dot";
    _marker setMarkerSizeLocal [0.3, 0.3];
    _marker setMarkerColorLocal "ColorWhite";
    _marker setMarkerShadowLocal false;
    _marker setMarkerAlphaLocal (0.5 + (0.5 * (20 - _forEachIndex) / 20));
    GVAR(trailMarkers) pushBack _marker;
} forEach _trail;
