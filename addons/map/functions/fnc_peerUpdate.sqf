#include "..\script_component.hpp"

params ["_control", "_peerCtrl", "_radio", "_inner"];

GVAR(cursorOverInfoMarker) = _inner;
private _peerData = [_radio] call FUNC(loadData);

(_peerCtrl controlsGroupCtrl IDC_PEER_NAME)
    ctrlSetText (_peerData getOrDefault ["name", "Unknown"]);


private _text = "";

private _lastSeen = _peerData getOrDefault ["lastSeen", -1];
if (_lastSeen != -1) then {
    private _since = daytime - _lastSeen;
    if (_since < 0) then {
        _since = _since + 24;
    };
    if (_since < 0.0016) then {
        _text = _text + "Active";
    } else {
        _text = _text + format ["Lost: %1 minutes ago", round (_since * 60)];
    };
};

_text = _text + "<br/>via " + ([_radio] call acre_api_fnc_getDisplayName);

_text = _text + format ["<br/>Channel: %1", [_radio, "getChannelDescription"] call acre_sys_data_fnc_dataEvent];

if ("color" in _peerData) then {
    private _color = _peerData get "color";
    _text = _text + format ["<br/>Team: <t color='%1'>%2</t>", [_color] call FUNC(colorHex), _color select [5]];
};

if ("speed" in _peerData) then {
    _text = _text + format ["<br/>Speed: %1 km/h", round ((_peerData get "speed") * 3.6)];
};

private _infoCtrl = (_peerCtrl controlsGroupCtrl IDC_PEER_INFO);
_infoCtrl ctrlSetStructuredText parseText _text;
// don't move the window while the cursor is over it
private _pos = if (GVAR(cursorOverInfo)) then {
    ctrlPosition _peerCtrl
} else {
    (_control ctrlMapWorldToScreen (getMarkerPos GVAR(cursorOverInfoMarker)))
        params ["_x", "_y"];
    [
        _x + 0.01,
        _y + 0.01
    ]
};
_peerCtrl ctrlSetPosition [
    _pos#0, _pos#1, PEER_WIDTH, (ctrlTextHeight _infoCtrl) + 0.04
];
private _pos = ctrlPosition _infoCtrl;
_infoCtrl ctrlSetPosition [_pos#0, _pos#1, PEER_WIDTH, (ctrlTextHeight _infoCtrl)];
_infoCtrl ctrlCommit 0;

_peerCtrl ctrlCommit 0;
_peerCtrl ctrlShow true;
