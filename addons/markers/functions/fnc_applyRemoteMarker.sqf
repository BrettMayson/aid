#include "..\script_component.hpp"

/**
 * Apply a remote marker delta with conflict resolution
 * Creates the marker if it doesn't exist, then applies the delta
 *
 * Args: _id, _delta
 *       _id: marker id
 *       _delta: hashmap of changes with timestamp
 * Returns: true if applied, false if skipped due to timestamp conflict
 */

params ["_id", "_delta"];

// Get or create marker state
private _state = GVAR(markers) getOrDefault [_id, createHashMap];

// If deletion delta, check if marker exists
if (_delta getOrDefault ["deleted", false]) then {
    if !(_id in allMapMarkers) exitWith { false };
};

// Check timestamp conflict
private _deltaTimestamp = _delta getOrDefault ["timestamp", -1];
private _currentTimestamp = _state getOrDefault ["timestamp", -1];

if (_deltaTimestamp != -1 && _currentTimestamp != -1 && _deltaTimestamp < _currentTimestamp) exitWith { false };

// Create marker if it doesn't exist
if !(_id in allMapMarkers) then {
    // Only create non-deletion markers
    if !(_delta getOrDefault ["deleted", false]) then {
        private _pos = _delta getOrDefault ["pos", [0, 0, 0]];
        // Create with default properties, will be updated by delta
        createMarkerLocal [_id, _pos, 0];
    };
};

// Store original state if this is new marker
if (isNil { _state getOrDefault ["timestamp", nil] }) then {
    GVAR(markers) set [_id, _state];
};

// Apply the delta
[_id, _state, _delta] call FUNC(apply);

// Record when this marker was synced
_state set ["lastSyncAt", dayTime];
GVAR(markers) set [_id, _state];

true
