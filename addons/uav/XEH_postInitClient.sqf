#include "script_component.hpp"

GVAR(uav) = objNull;

GVAR(ppResolution) = ppEffectCreate ["Resolution", 2012];

["ACE_controlledUAV", {
    params ["_uav"];
    if (!GVAR(enabled)) exitWith {
        GVAR(uav) = objNull;
    };
    if (isNull _uav) exitWith {
        GVAR(uav) = objNull;
    };
    if ((!isNull _uav) && isNull GVAR(uav)) then {
        private _config = configOf _uav;
        if !(_uav getVariable [QGVAR(init), false]) then {
            _uav setVariable [QGVAR(init), true, true];
            _uav setVariable [QGVAR(autoAdjust), true, true];
            _uav setVariable [QGVAR(freq), getNumber (_config >> QGVAR(defaultFreq)), true];
            _uav setVariable [QGVAR(power), getNumber (_config >> QGVAR(defaultPower)), true];
            _uav setVariable [QGVAR(powerOptions), getArray (_config >> QGVAR(power)), true];
            _uav setVariable [QGVAR(freqOptions), getArray (_config >> QGVAR(freq)), true];
        };
        GVAR(uav) = _uav;
        private _mode = getText (_config >> QGVAR(mode));
        if (_mode isEqualTo "SAT") then {
            GVAR(mode) = "SAT";
            GVAR(satCacheExpiry) = 0;
        } else {
            GVAR(mode) = "LOS";
        };
        [{ call FUNC(signalPFH)}, 0.25] call CBA_fnc_addPerFrameHandler;
    };
}] call CBA_fnc_addEventHandler;
