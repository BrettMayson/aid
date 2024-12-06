#include "script_component.hpp"

if (count GVAR(outerRadios) == 0) then {
    GVAR(outerRadios) = (+GVAR(allRadios));
    GVAR(innerRadios) = (+GVAR(allRadios));
};
if (count GVAR(innerRadios) == 0) then {
    GVAR(innerRadios) = (+GVAR(allRadios));
    GVAR(outerRadios) deleteAt 0;
};

private _txRadio = GVAR(outerRadios) select 0;
private _rxRadio = GVAR(innerRadios) deleteAt 0;

if (_txRadio isEqualTo _rxRadio) exitWith {
    GVAR(innerRadios) deleteAt 0;
};
if (isNil {acre_sys_data_radioData getVariable _txRadio}) exitWith {
    GVAR(outerRadios) deleteAt 0;
};
if (isNil {acre_sys_data_radioData getVariable _rxRadio}) exitWith {
    GVAR(innerRadios) deleteAt 0;
};

private _txData = [_txRadio, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
private _txFreq = _txData getVariable "frequencyTX";
private _txFreqRx = _txData getVariable "frequencyRX";
private _txPower = _txData getVariable "power";

private _rxData = [_rxRadio, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent;
private _rxFreq = _rxData getVariable "frequencyRX";

private _rxSignal = 0;

if (_rxFreq isEqualTo _txFreq) then {
    ([_txFreqRx, _txPower, _rxRadio, _txRadio] call EFUNC(signal,getAcreSignal)) params ["_signal", "_db"];
    ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, str _txFreqRx, _signal, _db]]) params ["_ret", "_code"];
    if (_code != 0) then {
        WARNING_1("Failed to set signal strength: %1",_ret);
    };
} else {
    ("aid" callExtension ["mesh:set", [_txRadio, _rxRadio, str _txFreqRx, 0, -992]]) params ["_ret", "_code"];
};
