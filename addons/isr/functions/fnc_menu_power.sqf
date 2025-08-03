#include "..\script_component.hpp"

params ["_command", "_arg"];

_fnc_options = {
    private _currentFreq = GVAR(vehicle) getVariable [QEGVAR(uav,freq), 1300];
    private _currentPower = GVAR(vehicle) getVariable [QEGVAR(uav,power), 800];
    private _frequencyOptions = GVAR(vehicle) getVariable [QEGVAR(uav,freqOptions), []];
    private _powerOptions = GVAR(vehicle) getVariable [QEGVAR(uav,powerOptions), []];
    private _freqCurrent = _frequencyOptions find _currentFreq;
    private _powerCurrent = _powerOptions find _currentPower;
    private _freqNext = if (_frequencyOptions isNotEqualTo []) then {
        _frequencyOptions select ((_freqCurrent + 1) % count _frequencyOptions)
    } else {
        "N/A"
    };
    private _freqPrev = if (_frequencyOptions isNotEqualTo []) then {
        _frequencyOptions select ((_freqCurrent - 1 + count _frequencyOptions) % count _frequencyOptions)
    } else {
        "N/A"
    };
    private _powerNext = if (_powerOptions isNotEqualTo []) then {
        _powerOptions select ((_powerCurrent + 1) % count _powerOptions)
    } else {
        "N/A"
    };
    private _powerPrev = if (_powerOptions isNotEqualTo []) then {
        _powerOptions select ((_powerCurrent - 1 + count _powerOptions) % count _powerOptions)
    } else {
        "N/A"
    };
    [_freqNext, _freqPrev, _powerNext, _powerPrev]
};

_fnc_draw = {
    private _options = call _fnc_options;
    [
        "POWER SETTINGS",
        format ["NEXT FREQ: %1", (_options select 0) call EFUNC(map,displayFrequency)],
        format ["PREV FREQ: %1", (_options select 1) call EFUNC(map,displayFrequency)],
        format ["NEXT POWER: %1", (_options select 2) call EFUNC(map,displayPower)],
        format ["PREV POWER: %1", (_options select 3) call EFUNC(map,displayPower)],
        format ["AUTO ADJUST: %1", GVAR(vehicle) getVariable [QEGVAR(uav,autoAdjust), false]]
    ] call FUNC(menu_draw);
};

switch (_command) do {
    case "open": {
        GVAR(menuStack) pushBack ["power", { _this call FUNC(menu_power) }, []];
        GVAR(powerRefresh) = [{
            ["return", ""] call ((GVAR(menuStack) select -1) select 1)
        }] call CBA_fnc_addPerFrameHandler;
        call _fnc_draw;
    };
    case "return": {
        call _fnc_draw;
    };
    case "close": {
        [GVAR(powerRefresh)] call CBA_fnc_removePerFrameHandler;
        GVAR(powerRefresh) = nil;
    };
    case "key": {
        switch (_arg) do {
            case 1: { // Freq Next
                private _options = call _fnc_options;
                private _nextFreq = _options select 0;
                if (_nextFreq isEqualTo "N/A") exitWith {};
                GVAR(vehicle) setVariable [QEGVAR(uav,freq), _nextFreq, true];
                call _fnc_draw;
            };
            case 2: { // Freq Previous
                private _options = call _fnc_options;
                private _prevFreq = _options select 1;
                if (_prevFreq isEqualTo "N/A") exitWith {};
                GVAR(vehicle) setVariable [QEGVAR(uav,freq), _prevFreq, true];
                call _fnc_draw;
            };
            case 3: { // Power Next
                private _options = call _fnc_options;
                private _nextPower = _options select 2;
                if (_nextPower isEqualTo "N/A") exitWith {};
                GVAR(vehicle) setVariable [QEGVAR(uav,power), _nextPower, true];
                call _fnc_draw;
            };
            case 4: { // Power Previous
                private _options = call _fnc_options;
                private _prevPower = _options select 3;
                if (_prevPower isEqualTo "N/A") exitWith {};
                GVAR(vehicle) setVariable [QEGVAR(uav,power), _prevPower, true];
                call _fnc_draw;
            };
            case 5: {
                private _current = GVAR(vehicle) getVariable [QEGVAR(uav,autoAdjust), false];
                GVAR(vehicle) setVariable [QEGVAR(uav,autoAdjust), !_current, true];
                call _fnc_draw;
            };
        };
    };
};
