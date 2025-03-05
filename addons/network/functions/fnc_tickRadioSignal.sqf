#include "script_component.hpp"

private _start = diag_tickTime;
private _end = _start + 0.002;

private _count = 0;

private _startOuterIndex = GVAR(outerIndex);
private _startInnerIndex = GVAR(innerIndex);

if (count GVAR(allRadios) == 0) exitWith {};

private _first = true;

while {diag_tickTime < _end} do {
    if (count GVAR(allRadios) == GVAR(innerIndex)) then {
        GVAR(innerIndex) = 0;
        GVAR(outerIndex) = GVAR(outerIndex) + 1;
        if (count GVAR(allRadios) == GVAR(outerIndex)) then {
            GVAR(outerIndex) = 0;
        };
    };

    if (_first) then {
        _first = false;
    } else {
        if (_startOuterIndex == GVAR(outerIndex) && _startInnerIndex == GVAR(innerIndex)) then {
            break;
        };
    };

    _count = _count + 1;

    private _txRadio = GVAR(allRadios) select GVAR(outerIndex);
    private _rxRadio = GVAR(allRadios) select GVAR(innerIndex);
    GVAR(innerIndex) = GVAR(innerIndex) + 1;

    if (_txRadio isEqualTo _rxRadio) then {
        continue;
    };

    private _txBase = _txRadio select [6,3];
    if (_txBase == "f88" || { _txBase == "rc3" }) then {
        private _rxBase = _rxRadio select [6,3];
        if (_rxBase != _txBase) then {
            continue;
        };
    };

    if (isNil {acre_sys_data_radioData getVariable _txRadio}) then {
        GVAR(outerIndex) = GVAR(outerIndex) + 1;
        continue;
    };
    if (isNil {acre_sys_data_radioData getVariable _rxRadio}) then {
        continue;
    };

    private _txData = [_txRadio] call FUNC(radioData);
    private _txFreq = _txData getVariable "frequencyTX";

    private _rxData = [_rxRadio] call FUNC(radioData);
    private _rxFreq = _rxData getVariable "frequencyRX";
    
    if (_rxFreq != _txFreq) then {
        ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, _txFreqRx, 0, -992]]) params ["_ret", "_code"];
        if (_code != 0) then {
            WARNING_1("Failed to set signal strength: %1",_ret);
        };
        continue;
    };

    private _txFreqRx = _txData getVariable "frequencyRX";
    private _txPower = _txData getVariable "power";

    private _rxSignal = 0;

    ([_txFreqRx, _txPower, _rxRadio, _txRadio] call EFUNC(signal,getAcreSignal)) params ["_signal", "_db"];
    ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, _txFreqRx, _signal, _db]]) params ["_ret", "_code"];
    if (_code != 0) then {
        WARNING_1("Failed to set signal strength: %1",_ret);
    };
};

GVAR(lastProcessed) = _count;
