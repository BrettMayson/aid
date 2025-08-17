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
            private _defaultFreq = getNumber (_config >> QGVAR(defaultFreq));
            if (_defaultFreq isNotEqualTo 0) then {
                _uav setVariable [QGVAR(freq), _defaultFreq, true];
            };
            private _defaultPower = getNumber (_config >> QGVAR(defaultPower));
            if (_defaultPower isNotEqualTo 0) then {
            _uav setVariable [QGVAR(power), _defaultPower, true];
            };
            private _defaultFreqOptions = getArray (_config >> QGVAR(freq));
            if (_defaultFreqOptions isNotEqualTo []) then {
                _uav setVariable [QGVAR(freqOptions), _defaultFreqOptions, true];
            };
            private _defaultPowerOptions = getArray (_config >> QGVAR(power));
            if (_defaultPowerOptions isNotEqualTo []) then {
                _uav setVariable [QGVAR(powerOptions), _defaultPowerOptions, true];
            };
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
