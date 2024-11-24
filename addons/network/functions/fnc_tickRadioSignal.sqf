#include "script_component.hpp"

if (count GVAR(radios) == 0) exitWith {
    GVAR(radios) = (+GVAR(allRadios)) - ([] call acre_api_fnc_getCurrentRadioList);
    GVAR(peerRadios) = GVAR(playerRadios);
    GVAR(playerRadios) = createHashMap;
};

if (isNil QGVAR(currentRadioCache)) then {
    GVAR(currentRadioCache) = [];
    GVAR(currentRadioCacheExpiry) = -2;
};
if (CBA_missionTime > GVAR(currentRadioCacheExpiry)) then {
    GVAR(currentRadioCache) = [] call acre_api_fnc_getCurrentRadioList;
    GVAR(currentRadioCacheExpiry) = CBA_missionTime + 1;
};
private _myRadios = +GVAR(currentRadioCache);

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
    private _hash = GVAR(playerRadios) getOrDefaultCall [toLower _x, { createHashMap }, true];
    _hash set [_txRadio, [_txSignal, _rxSignal]];
    GVAR(playerRadios) set [toLower _x, _hash];
} forEach _myRadios;
