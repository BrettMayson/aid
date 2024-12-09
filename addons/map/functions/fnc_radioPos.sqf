#include "..\script_component.hpp"

params ["_radio"];

private _object = [_radio] call acre_sys_radio_fnc_getRadioObject;
private _data = [_object] call EFUNC(contacts,dataLoad);

_data getOrDefault ["posASL", getPosASL _object]
