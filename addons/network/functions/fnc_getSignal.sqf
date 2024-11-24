#include "script_component.hpp"

params ["_f", "_mW", "_receiverClass", "_transmitterClass"];

private _rxAntennas = [_receiverClass] call acre_sys_components_fnc_findAntenna;
private _txAntennas = [_transmitterClass] call acre_sys_components_fnc_findAntenna;

{
    private _txAntenna = _x;
    {
        private _rxAntenna = _x;
        private _id = format ["aid_%1_%2_%3_%4", _transmitterClass, (_txAntenna select 0), _receiverClass, (_rxAntenna select 0)];
        [
            "process_signal",
            [
                2, // LOS Multipath
                _id,
                (_txAntenna select 2),
                (_txAntenna select 3),
                (_txAntenna select 0),
                (_rxAntenna select 2),
                (_rxAntenna select 3),
                (_rxAntenna select 0),
                _f,
                _mW,
                acre_sys_signal_terrainScaling,
                diag_tickTime,
                0, // Debugging
                acre_sys_signal_omnidirectionalRadios
            ],
            2,
            FUNC(handleSignalReturn),
            [_transmitterClass, _receiverClass]
        ] call acre_sys_core_fnc_callExt;
    } forEach _rxAntennas;
} forEach _txAntennas;

private _maxSignal = missionNamespace getVariable ["aid_" + _transmitterClass + "_best_signal", -992];
private _Px = missionNamespace getVariable ["aid_" + _transmitterClass + "_best_px", 0];

[_Px, _maxSignal]
