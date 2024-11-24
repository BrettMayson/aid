#include "script_component.hpp"

params ["_args", "_result"];
_args params ["_transmitterClass", "_receiverClass"];

if (_result isNotEqualTo []) then {
    _result params ["_id", "_signal"];

    private _bestSignalStr = format ["aid_%1_best_signal", _transmitterClass];
    private _bestAntStr = format ["aid_%1_best_ant", _transmitterClass];

    private _maxSignal = missionNamespace getVariable [_bestSignalStr , -992];
    private _currentAntenna = missionNamespace getVariable [_bestAntStr, ""];

    if ((_id == _currentAntenna) || {(_id != _currentAntenna) && {_signal > _maxSignal}}) then {
        missionNamespace setVariable [_bestSignalStr, _signal];
        missionNamespace setVariable [_bestAntStr, _id];

        private _bestPxStr = format ["aid_%1_best_px", _transmitterClass];
        if (_maxSignal >= -500) then {
            private _realRadioRx = [_receiverClass] call acre_sys_radio_fnc_getRadioBaseClassname;
            private _min = getNumber (configFile >> "CfgAcreComponents" >> _realRadioRx >> "sensitivityMin");
            private _max = getNumber (configFile >> "CfgAcreComponents" >> _realRadioRx >> "sensitivityMax");

            private _Px = (((_maxSignal - _min) / (_max - _min)) max 0.0) min 1.0;
            missionNamespace setVariable [_bestPxStr, _Px];
        } else {
            missionNamespace setVariable [_bestPxStr, 0];
        };
    };
};
