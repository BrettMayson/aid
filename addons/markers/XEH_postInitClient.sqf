#include "script_component.hpp"

if !(isMultiplayer) exitWith {};

GVAR(tracking) = [];
GVAR(markers) = createHashMap;  // marker id → {state, timestamp}
GVAR(remoteMarkers) = createHashMap;  // marker id → {timestamp, source_netId} for deduplication

["created", {
    params ["_newMarker"];
    // Only track user-defined markers
    if !("_USER_DEFINED #" in _newMarker) exitWith {
        if (QUOTE(ADDON) in _newMarker) then {
            GVAR(tracking) pushBackUnique _newMarker;
        };
    };

    private _machine = ((_newMarker select [15,10]) splitString "/") select 0;
    // Don't track markers created by other machines
    if (_machine != getPlayerID player) exitWith {
        deleteMarkerLocal _newMarker;
    };
    
    // Generate tracking ID
    private _id = call FUNC(nextId);
    GVAR(tracking) pushBackUnique _id;
    
    // Capture current marker properties before deleting
    private _state = [_newMarker, createHashMap] call FUNC(delta);
    private _now = dayTime;
    _state set ["timestamp", _now];
    _state set ["createdBy", name ace_player];
    _state set ["createdAt", _now];
    
    // Set source_netId so fnc_dataSave can find this marker and include it in contact updates
    private _myMachineId = parseNumber (((netId player) splitString ":") select 0);
    _state set ["source_netId", _myMachineId];
    
    GVAR(markers) set [_id, _state];
    
    // Delete original marker and replace with tracked one
    deleteMarkerLocal _newMarker;
    [_id, _state, _state] call FUNC(apply);
    
    // Broadcast marker creation to server
    [QGVAR(updated), [_id, _state, _now, clientOwner]] call CBA_fnc_serverEvent;
}] call CBA_fnc_addMarkerEventHandler;

// PFH to detect and broadcast local marker changes
[{
    {
        private _id = _x;
        private _markerState = GVAR(markers) get _id;
        
        // Skip deleted markers
        if (_markerState getOrDefault ["deleted", false]) then {
            continue;
        };
        
        // Check if marker still exists locally
        if !(_id in allMapMarkers) then {
            // Marker was deleted - broadcast deletion delta
            private _delta = createHashMap;
            _delta set ["deleted", true];
            private _now = dayTime;
            _delta set ["timestamp", _now];
            [QGVAR(updated), [_id, _delta, _now, clientOwner]] call CBA_fnc_serverEvent;
            
            // Mark as deleted locally
            _markerState set ["deleted", true];
            GVAR(markers) set [_id, _markerState];
            continue;
        };
        
        // Compute current state and compare
        private _currentDelta = [_id, _markerState] call FUNC(delta);
        
        // If anything changed, broadcast
        if (count _currentDelta > 0) then {
            private _now = dayTime;
            _currentDelta set ["timestamp", _now];
            // Add editor metadata
            _currentDelta set ["editedBy", name ace_player];
            _currentDelta set ["editedAt", _now];
            [QGVAR(updated), [_id, _currentDelta, _now, clientOwner]] call CBA_fnc_serverEvent;
            
            // Update local timestamp and editor info
            _markerState set ["timestamp", _now];
            _markerState set ["editedBy", name ace_player];
            _markerState set ["editedAt", _now];
            GVAR(markers) set [_id, _markerState];
        };
    } forEach GVAR(tracking);
}, 1, []] call CBA_fnc_addPerFrameHandler;

// Initialize marker hover on map display
GVAR(hoveredMarker) = "";
GVAR(markerHoverInfo) = "";
GVAR(cursorMoved) = diag_tickTime;
GVAR(cursorChecked) = false;
