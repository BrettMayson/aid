#include "script_component.hpp"

if !(isMultiplayer) exitWith {};

// Used by fnc_tickRadioSignal
GVAR(outerIndex) = 0;
GVAR(innerIndex) = 0;

// Used by fnc_radioData
GVAR(radioData) = createHashMap;

GVAR(allRadios) = [];

"aid" callExtension ["mesh:clear", []];
"aid" callExtension ["object:clear", []];

[{
    call FUNC(tickRadioSignal);
}] call CBA_fnc_addPerFrameHandler;

[QGVAR(syncCount), {
    params ["_count"];
    if (count GVAR(allRadios) == _count) exitWith {};
    if (aid_debug) then {
        systemChat format ["syncCount: %1 vs %2", _count, count GVAR(allRadios)];
    };
    [QGVAR(getRadios), player] call CBA_fnc_serverEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(syncRadios), {
    GVAR(allRadios) = _this;
    if (aid_debug) then {
        systemChat format ["syncRadios: %1", count GVAR(allRadios)];
    };
}] call CBA_fnc_addEventHandler;

[QGVAR(addRadio), {
    params ["_radio", "_owner"];
    GVAR(allRadios) pushBackUnique _radio;
    "aid" callExtension ["object:set", [_radio, _owner]];
    if (aid_debug) then {
        systemChat format ["addRadio: %1", _radio];
    };
}] call CBA_fnc_addEventHandler;

[QGVAR(removeRadio), {
    params ["_radio"];
    GVAR(allRadios) = GVAR(allRadios) - [_radio];
    "aid" callExtension ["mesh:remove", [_radio]];
    "aid" callExtension ["object:remove", [_radio]];
    if (aid_debug) then {
        systemChat format ["removeRadio: %1", _radio];
    };
}] call CBA_fnc_addEventHandler;

[QGVAR(ownerChange), {
    params ["_radio", "_owner"];
    "aid" callExtension ["object:set", [_radio, _owner]];
    if (aid_debug) then {
        systemChat format ["ownerChange: %1 @ |%2|", _radio, _owner];
    };
}] call CBA_fnc_addEventHandler;

[{
    if (acre_player != player) exitWith {};
    private _radios = [];
    {
        private _data = [_x] call FUNC(radioData);
        private _freq = _data getVariable "frequencyTX";
        _radios pushBack [_x, _freq];
    } forEach ([] call acre_api_fnc_getCurrentRadioList);
    ("aid" callExtension ["player:set", [_radios]]) params ["_ret", "_code"];
    if (_code != 0) then {
        WARNING_2("Failed to set player radios (%2): %1",_ret,_code);
    };
}, 3] call CBA_fnc_addPerFrameHandler;

cba_settings_allSettings = cba_settings_allSettings - [
    "acre_sys_signal_signalModel",
    "acre_sys_core_ignoreAntennaDirection",
    "acre_sys_core_automaticAntennaDirection",
    "acre_sys_core_terrainLoss",
    "acre_sys_core_interference"
];

addMissionEventHandler ["ExtensionCallback", {
    params ["_name", "_function", "_data"];
    if (_name != "aid_network") exitWith {};
    if (_function == "request_owner") exitWith {
        private _radio = parseSimpleArray _data;
        private _owner = [_radio] call acre_sys_radio_fnc_getRadioObject;
        ("aid" callExtension ["object:set", [_radio, _owner]]) params ["_ret", "_code"];
        if (_code != 0) then {
            WARNING_2("Failed to set radio owner (%2): %1",_ret,_code);
        };
    };
}];
