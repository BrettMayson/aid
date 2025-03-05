#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "\a3\ui_f\hpp\defineDIKCodes.inc"

aid_debug = false;

GVAR(peerDeleted) = false;

[QUOTE(ADDON), "DeleteMarker", ["Delete Lost Contact", "Deletes a lost contact from the map"], {}, {
    if (GVAR(peerShown) isEqualTo []) exitWith {};
    GVAR(peerShown) params ["_radio", "_inner", "_outer"];
    deleteMarkerLocal _inner;
    deleteMarkerLocal _outer;
    GVAR(sources) deleteAt _radio;
    GVAR(peerShown) = [];
    GVAR(cursorOverInfoMarker) = "";
    GVAR(cursorOverInfo) = false;
    GVAR(peerDeleted) = true;
    private _peerCtrl = (findDisplay 12) displayCtrl IDC_PEER;
    _peerCtrl ctrlShow false;
}, [DIK_DELETE, [false, false, false]]] call CBA_fnc_addKeybind;

[
    QGVAR(followCursor),
    "CHECKBOX",
    "Infobox follows cursor",
    "AID - Map",
    false,
    0
] call CBA_fnc_addSetting;


GVAR(trailMarkers) = [];
GVAR(lines) = [];

ADDON = true;
