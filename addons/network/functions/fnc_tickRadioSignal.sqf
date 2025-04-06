#include "..\script_component.hpp"

private _start = diag_tickTime;
private _end = _start + 0.002;

private _count = 0;

private _startOuterIndex = GVAR(outerIndex);
private _startInnerIndex = GVAR(innerIndex);

if (count GVAR(allRadios) == 0) exitWith {};

private _first = true;

while {diag_tickTime < _end} do {
    if (count GVAR(allRadios) <= GVAR(innerIndex) || count GVAR(allRadios) <= GVAR(outerIndex)) then {
        GVAR(innerIndex) = 0;
        GVAR(outerIndex) = GVAR(outerIndex) + 1;
        if (count GVAR(allRadios) <= GVAR(outerIndex)) then {
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

    if (GVAR(innerIndex) >= count GVAR(allRadios) || GVAR(outerIndex) >= count GVAR(allRadios)) then {
        GVAR(innerIndex) = 0;
        GVAR(outerIndex) = 0;
        continue;
    };
    private _txRadio = GVAR(allRadios) select GVAR(outerIndex);
    private _rxRadio = GVAR(allRadios) select GVAR(innerIndex);
    GVAR(innerIndex) = GVAR(innerIndex) + 1;

    if (_txRadio isEqualTo _rxRadio) then {
        continue;
    };

    private _txBase = _txRadio select [6,3];
    private _rxBase = _rxRadio select [6,3];
    if (_txBase == "f88" || { _txBase == "rc3" }) then {
        if (_rxBase != _txBase) then {
            if (aid_trace) then {
                systemChat format ["%1 (%2) != %3 (%4)", _txRadio, _txBase, _rxRadio, _rxBase];
            };
            continue;
        };
    } else {
        if (_rxBase == "f88" || { _rxBase == "rc3" }) then {
            if (aid_trace) then {
                systemChat format ["%1 (%2) != %3 (%4)", _txRadio, _txBase, _rxRadio, _rxBase];
            };
            continue;
        };
    };

    if (isNil {acre_sys_data_radioData getVariable _txRadio}) then {
        GVAR(outerIndex) = GVAR(outerIndex) + 1;
        ("aid" callExtension ["mesh:remove", [_txRadio]]);
        if (aid_trace) then {
            systemChat format ["mesh:remove (not in radioData) %1", _txRadio];
        };
        continue;
    };
    if (isNil {acre_sys_data_radioData getVariable _rxRadio}) then {
        ("aid" callExtension ["mesh:remove", [_rxRadio]]);
        if (aid_trace) then {
            systemChat format ["mesh:remove (not in radioData) %1", _rxRadio];
        };
        continue;
    };

    private _txData = [_txRadio] call FUNC(radioData);
    if (isNil "_txData") then {
        ("aid" callExtension ["mesh:remove", [_txRadio]]);
        if (aid_trace) then {
            systemChat format ["mesh:remove (no data) %1", _txRadio];
        };
        continue;
    };
    private _txFreq = _txData getVariable "frequencyTX";
    if (isNil "_txFreq") then {
        ("aid" callExtension ["mesh:remove", [_txRadio]]);
        if (aid_trace) then {
            systemChat format ["mesh:remove (no tx freq) %1", _txRadio];
        };
        continue;
    };

    private _rxData = [_rxRadio] call FUNC(radioData);
    if (isNil "_rxData") then {
        ("aid" callExtension ["mesh:remove", [_rxRadio]]);
        if (aid_trace) then {
            systemChat format ["mesh:remove (no data) %1", _rxRadio];
        };
        continue;
    };
    private _rxFreq = _rxData getVariable "frequencyRX";
    if (isNil "_rxFreq") then {
        continue;
    };
    
    if (_rxFreq != _txFreq) then {
        ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, _txFreq, 0, -992]]) params ["_ret", "_code"];
        if (_code != 0) then {
            WARNING_1("Failed to set signal strength: %1",_ret);
        };
        if (aid_trace) then {
            systemChat format ["mesh:set (freq mismatch) %1", _txRadio];
        };
        continue;
    };

    private _txPower = _txData getVariable "power";

    ([_txFreq, _txPower, _rxRadio, _txRadio] call EFUNC(signal,getAcreSignal)) params ["_signal", "_db"];
    ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, _txFreq, _signal, _db]]) params ["_ret", "_code"];
    if (_code != 0) then {
        WARNING_1("Failed to set signal strength: %1",_ret);
    };
    if (aid_trace) then {
        systemChat format ["mesh:set %1", _txRadio];
    };
};

GVAR(lastProcessed) = _count;
