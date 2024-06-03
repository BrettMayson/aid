#include "..\script_component.hpp"

params ["_display", "_mapCtrl"];

private _peerCtrl = _display displayCtrl IDC_PEER;
GVAR(cursorOverInfo) = false;
GVAR(cursorOverInfoMarker) = "";
GVAR(peerShown) = [];

(_peerCtrl controlsGroupCtrl IDC_PEER_INFO) ctrlAddEventHandler ["MouseEnter", {
    GVAR(cursorOverInfo) = true;
}];

(_peerCtrl controlsGroupCtrl IDC_PEER_INFO) ctrlAddEventHandler ["MouseExit", {
    GVAR(cursorOverInfo) = false;
}];

_mapCtrl ctrlAddEventHandler ["MouseMoving", {
    GVAR(cursorMoved) = diag_tickTime;
    GVAR(cursorChecked) = false;
}];

_mapCtrl ctrlAddEventHandler ["Draw", {
    params ["_control"];
    if (GVAR(cursorOverInfo)) exitWith {
        private _peerCtrl = (findDisplay 12) displayCtrl IDC_PEER;
        [_control, _peerCtrl, GVAR(peerShown)#0, GVAR(peerShown)#1] call FUNC(peerUpdate);
    };
    if (GVAR(cursorChecked) || {diag_tickTime - GVAR(cursorMoved) < 0.1}) exitWith {
        if (GVAR(peerShown) isEqualTo []) exitWith {};
        private _peerCtrl = (findDisplay 12) displayCtrl IDC_PEER;
        [_control, _peerCtrl, GVAR(peerShown)#0, GVAR(peerShown)#1] call FUNC(peerUpdate);
    };
    GVAR(cursorChecked) = true;
    private _close = [];
    {
        private _object = _x;
        {
            _x params ["_inner", "_outer"];
            private _dist = (_control ctrlMapWorldToScreen (getMarkerPos _inner)) distance2d getMousePosition;
            if (_dist <= 0.01) then {
                _close pushBackUnique [_object, _inner, _outer];
            };
        } forEach _y;
    } forEach GVAR(sources);
    private _peerCtrl = (findDisplay 12) displayCtrl IDC_PEER;
    if (count _close == 0) exitWith {
        GVAR(peerShown) = [];
        GVAR(cursorOverInfoMarker) = "";
        GVAR(cursorOverInfo) = false;
        _peerCtrl ctrlShow false;
        {
            deleteMarkerLocal _x;
        } forEach GVAR(trailMarkers);
    };
    (_close select 0) params ["_object", "_inner", "_outer"];
    GVAR(peerShown) = [_object, _inner, _outer];
    [_control, _peerCtrl, _object, _inner] call FUNC(peerUpdate);
}];
