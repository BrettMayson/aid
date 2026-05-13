#include "script_component.hpp"

if (!isMultiplayer) exitWith {};

GVAR(nextId) = 0;
publicVariable QGVAR(nextId);

[QGVAR(nextIdInc), {
    GVAR(nextId) = GVAR(nextId) + 1;
    publicVariable QGVAR(nextId);
}] call CBA_fnc_addEventHandler;

GVAR(data) = createHashMap;

// Handle marker updates from clients
[QGVAR(updated), {
    params ["_id", "_delta", "_timestamp", "_owner"];
    
    // Get or create marker data
    private _markerData = GVAR(data) getOrDefault [_id, createHashMap];
    private _currentTimestamp = _markerData getOrDefault ["timestamp", -1];
    
    // Only apply if this update is newer than what we have
    if (_timestamp > _currentTimestamp) then {
        _markerData set ["delta", _delta];
        _markerData set ["timestamp", _timestamp];
        _markerData set ["owner", _owner];
        
        // Store metadata from delta if present (for edits)
        if (_delta getOrDefault ["editedBy", nil] isNotEqualTo nil) then {
            _markerData set ["editedBy", _delta get "editedBy"];
        };
        if (_delta getOrDefault ["editedAt", nil] isNotEqualTo nil) then {
            _markerData set ["editedAt", _delta get "editedAt"];
        };
        // Preserve creator metadata on new markers
        if (_delta getOrDefault ["createdBy", nil] isNotEqualTo nil) then {
            _markerData set ["createdBy", _delta get "createdBy"];
        };
        if (_delta getOrDefault ["createdAt", nil] isNotEqualTo nil) then {
            _markerData set ["createdAt", _delta get "createdAt"];
        };
        
        GVAR(data) set [_id, _markerData];
    };
}] call CBA_fnc_addEventHandler;
