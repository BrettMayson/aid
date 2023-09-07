#include "script_component.hpp"

params ["_mapCtrl"];

_mapCtrl ctrlAddEventHandler ["MouseMoving", {
    params ["_control", "_posX", "_posY"];
    GVAR(cursorPosition) = [_posX, _posY];
    GVAR(cursorPositionWorld) = _control ctrlMapScreenToWorld [_posX, _posY];
    GVAR(cursorMoved) = diag_tickTime;
    GVAR(cursorChecked) = false;
}];

_mapCtrl ctrlAddEventHandler ["Draw", {
    params ["_control"];
    if (GVAR(cursorChecked) || {diag_tickTime - GVAR(cursorMoved) < 0.3}) exitWith {};
    GVAR(cursorChecked) = true;
    private _close = [];
    {
        private _radio = _x;
        {
            _x params ["_inner"];
            private _dist = (_control ctrlMapWorldToScreen (getMarkerPos _inner)) distance2d GVAR(cursorPosition);
            if (_dist <= 0.01) then {
                _close pushBackUnique _radio;
            };
        } forEach _y;
    } forEach GVAR(sources);
    if (count _close == 0) exitWith {};
    systemChat format ["Peer: %1", _close];
}];
