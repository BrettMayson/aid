#include "..\script_component.hpp"

/**
 * Marker hover tooltip display on map draw
 *
 * Args: _mapCtrl
 * Returns: none
 */

params ["_mapCtrl"];

systemChat format ["[Markers] fnc_markerHover called, tracking count: %1", count GVAR(tracking)];

private _mousePos = getMousePosition;
private _worldPos = _mapCtrl ctrlMapScreenToWorld _mousePos;

private _hoveredNow = "";
private _closest = 9999;

// Check all tracked markers for cursor proximity
{
    private _id = _x;
    private _markerPos = getMarkerPos _id;
    private _distance = _worldPos distance2D _markerPos;
    
    // Check if cursor is close enough (roughly 30 meters)
    if (_distance < 30 && _distance < _closest) then {
        _closest = _distance;
        _hoveredNow = _id;
    };
} forEach GVAR(tracking);

systemChat format ["[Markers] Hover detection: _hoveredNow=%1, GVAR(hoveredMarker)=%2", _hoveredNow, GVAR(hoveredMarker)];

// If hovering over a different marker, update display
if (_hoveredNow != GVAR(hoveredMarker)) then {
    systemChat format ["[Markers] Hover state changed to: %1", _hoveredNow];
    GVAR(hoveredMarker) = _hoveredNow;
    
    private _display = findDisplay 12;
    systemChat format ["[Markers] Display 12 found: %1", !isNil "_display"];
    if (!isNil "_display") then {
        private _hoverCtrl = _display displayCtrl IDC_MARKER_HOVER;
        systemChat format ["[Markers] Hover control found: %1 (IDC=%2)", !isNil "_hoverCtrl", IDC_MARKER_HOVER];
        if (!isNil "_hoverCtrl") then {
            if (_hoveredNow != "") then {
                systemChat format ["[Markers] Showing tooltip for marker: %1", _hoveredNow];
                GVAR(markerHoverInfo) = [_hoveredNow] call FUNC(formatHover);
                private _infoCtrl = _hoverCtrl controlsGroupCtrl IDC_MARKER_HOVER_INFO;
                _infoCtrl ctrlSetStructuredText parseText GVAR(markerHoverInfo);
                _hoverCtrl ctrlSetPosition [_mousePos#0 + 0.01, _mousePos#1 + 0.01, 0.35, 0.2];
                _hoverCtrl ctrlShow true;
                _hoverCtrl ctrlCommit 0;
            } else {
                systemChat "[Markers] Hiding tooltip";
                GVAR(markerHoverInfo) = "";
                _hoverCtrl ctrlShow false;
                _hoverCtrl ctrlCommit 0;
            };
        };
    };
} else {
    if (!isNil GVAR(hoveredMarker)) then {
        // Update tooltip position to follow cursor
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
