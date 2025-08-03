#include "..\script_component.hpp"

params ["_args", "_handle"];

private _uav = GVAR(uav);

if (isNull _uav) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    GVAR(ppResolution) ppEffectEnable false;
};

if !(GVAR(pixelate)) then {
    GVAR(ppResolution) ppEffectEnable false;
};

// TODO define communication type, radio vs satcom

private _distance = ace_player distance _uav;

if (_distance < 8) exitWith {
    GVAR(ppResolution) ppEffectEnable false;
};

private _playerPos = getPosASL ace_player;
// Add a meter of height to the player, since the terrain is usually held at chest height
_playerPos set [2, (_playerPos select 2) + 1.4];

private _signal = ([GVAR(freq), GVAR(power), getPosASL _uav, _playerPos] call EFUNC(signal,getSignal)) select 0;
_signal = linearConversion [0,0.7,_signal,0,1,true];
private _effect = _signal ^ 0.4;
private _disrupt = 1 - _effect;

GVAR(ppResolution) ppEffectAdjust [1080 / (1 + (_disrupt * 4) + (1 - exp (-0.3 * (1 - _disrupt))))];
GVAR(ppResolution) ppEffectCommit 0.15;
GVAR(ppResolution) ppEffectEnable true;
equipmentDisabled _uav params ["", "_ti"];
private _desired = _signal < 0.5;
if (_desired != _ti) then {
    _uav disableTIEquipment _desired;
};
if (GVAR(showSignal)) then {
    systemChat format ["Signal: %1%%", round (_signal * 100)];
};
if (_signal == 0) then {
    systemChat "Signal lost";
    ace_player remoteControl objNull;
};
