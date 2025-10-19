#include "..\script_component.hpp"

params ["_args", "_handle"];

private _uav = GVAR(uav);

if (isNull _uav) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    GVAR(ppResolution) ppEffectEnable false;
};

private _freq = _uav getVariable [QGVAR(freq), 1300];
private _power = _uav getVariable [QGVAR(power), 800];

(if (GVAR(mode) == "SAT") then {
    private _clarity = [ace_player] call FUNC(getSatError);
    [
        1 min (linearConversion [0, 4, _clarity, 1, 0, true] + random 0.05),
        1080
    ]
} else {
    private _distance = ace_player distance _uav;

    if (_distance < 8) exitWith {
        GVAR(ppResolution) ppEffectEnable false;
        [1, [_freq] call FUNC(maxRes)]
    };

    private _playerPos = getPosASL ace_player;
    // Add a meter of height to the player, since the terrain is usually held at chest height
    _playerPos set [2, (_playerPos select 2) + 1.4];

    private _signal = ([_freq, _power, getPosASL _uav, _playerPos] call EFUNC(signal,getSignal)) select 0;
    [
        linearConversion [0,0.7,_signal,0,1,true],
        [_freq] call FUNC(maxRes)
    ]
}) params ["_signal", "_maxRes"];

GVAR(ppResolution) ppEffectAdjust [_maxRes];
GVAR(ppResolution) ppEffectCommit 0.15;
GVAR(ppResolution) ppEffectEnable true;
equipmentDisabled _uav params ["", "_ti"];
GVAR(currentSignal) = _signal;
private _desired = _signal < GVAR(disableTISignal);
if (_desired != _ti) then {
    _uav disableTIEquipment _desired;
};
if (_signal == 0) then {
    // Change the frequency to the lowest frequency
    private _freqOptions = _uav getVariable [QGVAR(freqOptions), []];
    private _currentFreq = _uav getVariable [QGVAR(freq), 1300];
    private _lowestFreq = _freqOptions select 0;
    if (_currentFreq != _lowestFreq) then {
        _uav setVariable [QGVAR(freq), _lowestFreq, true];
    } else {
        ace_player remoteControl objNull;
    };
};

if (GVAR(mode) == "LOS" && _uav getVariable [QGVAR(autoAdjust), false] && GVAR(nextSignalAdjust) < time) then {
    GVAR(nextSignalAdjust) = time + 3;
    [_uav, _signal] call FUNC(signalAdjust);
};
