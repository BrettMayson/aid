#include "..\script_component.hpp"

params ["_id", "_state", "_delta", ["_forceApply", false]];

// Extract and verify timestamp
private _deltaTimestamp = _delta getOrDefault ["timestamp", -1];
private _currentTimestamp = _state getOrDefault ["timestamp", -1];

// Skip if remote delta is older than current local state (unless forced)
if (!_forceApply && _deltaTimestamp != -1 && _currentTimestamp != -1 && _deltaTimestamp < _currentTimestamp) exitWith {};

// Handle marker deletion
if (_delta getOrDefault ["deleted", false]) then {
    if (_id in allMapMarkers) then {
        deleteMarkerLocal _id;
    };
    _state set ["deleted", true];
    _state set ["timestamp", _deltaTimestamp];
    GVAR(markers) deleteAt _id;
} else {
    // Apply property changes
    {
        switch (_x) do {
            case "pos": { _id setMarkerPosLocal _y; };
            case "dir": { _id setMarkerDirLocal _y; };
            case "type": { _id setMarkerTypeLocal _y; };
            case "color": { _id setMarkerColorLocal _y; };
            case "text": { _id setMarkerTextLocal _y; };
            case "size": { _id setMarkerSizeLocal _y; };
            case "shape": { _id setMarkerShapeLocal _y; };
            case "brush": { _id setMarkerBrushLocal _y; };
            case "alpha": { _id setMarkerAlphaLocal _y; };
            case "poly": { 
                if (count _y >= 4) then {
                    _id setMarkerPolylineLocal _y;
                };
            };
        };
        _state set [_x, _y];
    } forEach _delta;
    // Update timestamp if present
    if (_deltaTimestamp != -1) then {
        _state set ["timestamp", _deltaTimestamp];
    };
    // Update editor metadata if provided in delta
    if (_delta getOrDefault ["editedBy", nil] isNotEqualTo nil) then {
        _state set ["editedBy", _delta get "editedBy"];
    };
    if (_delta getOrDefault ["editedAt", nil] isNotEqualTo nil) then {
        _state set ["editedAt", _delta get "editedAt"];
    };
};
