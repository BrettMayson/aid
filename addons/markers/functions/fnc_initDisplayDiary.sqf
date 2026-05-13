#include "..\script_component.hpp"

params ["_display", "_mapCtrl"];

// Initialize cursor tracking variables
GVAR(cursorMoved) = diag_tickTime;
GVAR(cursorChecked) = false;

// Track cursor movement to throttle proximity checks
_mapCtrl ctrlAddEventHandler ["MouseMoving", {
    GVAR(cursorMoved) = diag_tickTime;
    GVAR(cursorChecked) = false;
}];

// Draw event handler for marker hover detection
_mapCtrl ctrlAddEventHandler ["Draw", {
    params ["_control"];
    
    // Only process if we have markers to track
    if (count GVAR(tracking) == 0) exitWith {};
    
    // Skip expensive checks if cursor hasn't moved and we already checked
    if (GVAR(cursorChecked) || {diag_tickTime - GVAR(cursorMoved) < 0.1}) exitWith {
        // Still update position if already hovering
        if (!isNil GVAR(hoveredMarker)) then {
            private _mousePos = getMousePosition;
            private _display = findDisplay 12;
            if (!isNil "_display") then {
                private _hoverCtrl = _display displayCtrl IDC_MARKER_HOVER;
                if (!isNil "_hoverCtrl" && (ctrlShown _hoverCtrl)) then {
                    _hoverCtrl ctrlSetPosition [_mousePos#0 + 0.01, _mousePos#1 + 0.01, 0.35, 0.2];
                    _hoverCtrl ctrlCommit 0;
                };
            };
        };
    };
    
    GVAR(cursorChecked) = true;
    
    private _mousePos = getMousePosition;
    private _hoveredNow = "";
    private _closest = 9999;
    
    // Check all tracked markers for cursor proximity using screen-space distance
    {
        private _id = _x;
        private _markerPos = getMarkerPos _id;
        private _screenPos = _control ctrlMapWorldToScreen _markerPos;
        private _distance = _screenPos distance2D _mousePos;
        
        // Check if cursor is close enough (screen space: ~0.01 = 30m at normal zoom)
        if (_distance <= 0.01 && _distance < _closest) then {
            _closest = _distance;
            _hoveredNow = _id;
        };
    } forEach GVAR(tracking);
    
    // If hovering over a different marker, update display
    if (_hoveredNow != GVAR(hoveredMarker)) then {
        GVAR(hoveredMarker) = _hoveredNow;
        
        private _display = findDisplay 12;
        if (!isNil "_display") then {
            private _hoverCtrl = _display displayCtrl IDC_MARKER_HOVER;
            if (!isNil "_hoverCtrl") then {
                if (_hoveredNow != "") then {
                    GVAR(markerHoverInfo) = [_hoveredNow] call FUNC(formatHover);
                    private _infoCtrl = _hoverCtrl controlsGroupCtrl IDC_MARKER_HOVER_INFO;
                    _infoCtrl ctrlSetStructuredText parseText GVAR(markerHoverInfo);
                    _hoverCtrl ctrlSetPosition [_mousePos#0 + 0.01, _mousePos#1 + 0.01, 0.35, 0.2];
                    _hoverCtrl ctrlShow true;
                    _hoverCtrl ctrlCommit 0;
                } else {
                    GVAR(markerHoverInfo) = "";
                    _hoverCtrl ctrlShow false;
                    _hoverCtrl ctrlCommit 0;
                };
            };
        };
    } else {
        // Update tooltip position to follow cursor
        if (GVAR(hoveredMarker) != "") then {
            private _display = findDisplay 12;
            if (!isNil "_display") then {
                private _hoverCtrl = _display displayCtrl IDC_MARKER_HOVER;
                if (!isNil "_hoverCtrl" && (ctrlShown _hoverCtrl)) then {
                    _hoverCtrl ctrlSetPosition [_mousePos#0 + 0.01, _mousePos#1 + 0.01, 0.35, 0.2];
                    _hoverCtrl ctrlCommit 0;
                };
            };
        };
    };
}];
