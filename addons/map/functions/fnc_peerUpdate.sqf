#include "..\script_component.hpp"

params ["_control", "_peerCtrl", "_object", "_inner"];

GVAR(cursorOverInfoMarker) = _inner;
private _peerData = [_object] call EFUNC(contacts,dataLoad);

(_peerCtrl controlsGroupCtrl IDC_PEER_NAME)
    ctrlSetText (_peerData getOrDefault ["name", "Unknown"]);

private _text = "";

private _lastSeen = _peerData getOrDefault ["lastSeen", -1];
if (_lastSeen != -1) then {
    private _since = dayTime - _lastSeen;
    if (_since < 0) then {
        _since = _since + 24;
    };
    if (_since < 0.0016) then {
        _text = _text + "Active";
    } else {
        _text = _text + format ["Lost: %1 minutes ago", round (_since * 60)];
    };
};

if ("color" in _peerData) then {
    private _color = _peerData get "color";
    _text = _text + format ["<br/>Team: <t color='%1'>%2</t>", [_color] call FUNC(colorHex), _color select [5]];
};

if ("speed" in _peerData) then {
    _text = _text + format ["<br/>Speed: %1 km/h", round ((_peerData get "speed") * 3.6)];
};

if ("bearing" in _peerData) then {
    _text = _text + format ["<br/>Bearing: %1°", round (_peerData get "bearing")];
};

if ("altitude" in _peerData) then {
    _text = _text + format ["<br/>Altitude: %1 m", round ((_peerData get "altitude") + GVAR(altitudeOffset))];
};

if ("radios" in _peerData) then {
    GVAR(lines) = [];
    _text = _text + "<br/>";
    {
        private _radio_id = _x;
        private _name = _y get "name";
        private _channel = _y get "channelDescription";
        private _image = format ["<img size='0.7' image='%1'/>", [(_y get "chain") select 0] call FUNC(strengthIcon)];
        private _color = [
            [1,0,0],
            [0,1,0],
            [0,0,1],
            [1,1,0],
            [1,0,1],
            [0,1,1],
            [1,1,1]
        ] select (_forEachIndex min 7);
        _text = _text + format [
            "<br/>via <t color='%1'>%2</t> %3<br/>  %4",
            _color call BIS_fnc_colorRGBtoHTML,
            _name,
            _image,
            _channel
        ];
        if (count (_y get "chain") < 2) then {
            continue;
        };
        private _chain = (_y get "chain") select 2;
        if (count _chain < 2) then {
            continue;
        };
        private _origin = (_chain select 0) select 0;
        {
            if (_forEachIndex == 0) then {
                continue;
            };
            _x params ["_radio", "_signal"];
            _color set [3, linearConversion [0, 1, _signal, 0.5, 1]];
            GVAR(lines) pushBack [
                [_origin] call acre_sys_radio_fnc_getRadioPos,
                [_radio] call acre_sys_radio_fnc_getRadioPos,
                _color
            ];
            if (_forEachIndex != (count _chain - 1)) then {
                _text = _text + format [
                    "<br/>  + %1",
                    name ([_radio] call acre_sys_radio_fnc_getRadioObject)
                ];
            };
            _origin = _radio;
        } forEach _chain;
    } forEach (_peerData get "radios");
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

if ("trail" in _peerData) then {
    [_object, _peerData get "trail"] call FUNC(drawTrail);
};
