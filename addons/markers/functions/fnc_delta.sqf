#include "..\script_component.hpp"

params ["_id", "_current", ["_deleted", false]];

private _delta = createHashMap;

// If marker is being deleted, create a deletion delta
if (_deleted) then {
    _delta set ["deleted", true];
    _delta set ["timestamp", dayTime];
} else {
    // Compute property changes
    {
        private _existing = _current getOrDefault [_x select 0, -1];
        if (_existing isNotEqualTo (_x select 1)) then {
            if (_x select 0 == "poly" && { count (_x select 1) < 4 }) then {
                // Skip poly updates with less than 2 points, as they are invalid
                continue;
            };
            _delta set [_x select 0, _x select 1];
        };
    } forEach [
        ["pos", markerPos _id],
        ["dir", markerDir _id],
        ["type", markerType _id],
        ["color", markerColor _id],
        ["text", markerText _id],
        ["size", markerSize _id],
        ["shape", markerShape _id],
        ["brush", markerBrush _id],
        ["alpha", markerAlpha _id],
        ["poly", markerPolyline _id]
    ];
    // Add timestamp to non-deletion deltas
    if (count _delta > 0) then {
        _delta set ["timestamp", dayTime];
    };
};

_delta
