#include "script_component.hpp"

if (count GVAR(radios) == 0) exitWith {
    GVAR(radios) = (+GVAR(allRadios)) - ([] call acre_api_fnc_getCurrentRadioList);
    GVAR(peerRadios) = GVAR(playerRadios);
    GVAR(playerRadios) = createHashmap;
};

private _myRadios = [] call acre_api_fnc_getCurrentRadioList;

private _txRadio = GVAR(radios) deleteAt 0;
private _txData = [_txRadio, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
private _txFreq = _txData getVariable "frequencyTX";
private _txFreqRx = _txData getVariable "frequencyRX";
private _txPower = _txData getVariable "power";

{
    private _rxData = [_x, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
    private _rxFreq = _rxData getVariable "frequencyRX";
    private _rxFreqTx = _rxData getVariable "frequencyTX";
    private _rxPower = _rxData getVariable "power";

    private _txSignal = 0;
    private _rxSignal = 0;

    if (_rxFreq isEqualTo _txFreq) then {
        _rxSignal = ([_txFreqRx, _txPower, _x, _txRadio] call acre_sys_signal_fnc_getSignal) select 0;
        if (_rxSignal > 0) then {
            _txSignal = ([_txFreq, _txPower, _txRadio, _x] call acre_sys_signal_fnc_getSignal) select 0;
        };
    };
    private _hash = GVAR(playerRadios) getOrDefaultCall [tolower _x, { createHashmap }, true];
    _hash set [_txRadio, [_txSignal, _rxSignal]];
    GVAR(playerRadios) set [tolower _x, _hash];
} forEach _myRadios;
