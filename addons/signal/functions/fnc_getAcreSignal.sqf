#include "..\script_component.hpp"

// TODO use vector add to add the height

params ["_f", "_mW", "_receiverClass", "_transmitterClass"];
private _rxAnt = ([_receiverClass] call acre_sys_components_fnc_findAntenna) select 0;
private _rxPos = _rxAnt select 2;
if (_rxAnt select 0 == "ACRE_643CM_VHF_TNC") then {
    _rxPos set [2, (_rxPos select 2) + 4];
};
private _txAnt = ([_transmitterClass] call acre_sys_components_fnc_findAntenna) select 0;
private _txPos = _txAnt select 2;
if (_txAnt select 0 == "ACRE_643CM_VHF_TNC") then {
    _txPos set [2, (_txPos select 2) + 4];
};

[_f, _mW, _rxPos, _txPos, _receiverClass] call FUNC(getSignal);
