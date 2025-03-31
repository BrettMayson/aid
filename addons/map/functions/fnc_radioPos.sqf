#include "..\script_component.hpp"

params ["_radio"];

private _object = [_radio] call acre_sys_radio_fnc_getRadioObject;

if (_object == ace_player) exitWith {
    getPosASL ace_player
};

private _data = [netId _object] call EFUNC(contacts,dataLoad);

_data getOrDefault ["posASL", [0,0,0]]
