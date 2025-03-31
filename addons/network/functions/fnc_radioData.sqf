#include "..\script_component.hpp"

params ["_radio"];

#define TTL 0.75

private _cached = GVAR(radioData) getOrDefaultCall [_radio, {
    [
        [_radio, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent,
        CBA_missionTime + TTL
    ]
}, true];

if (_cached select 1 < CBA_missionTime) then {
    GVAR(radioData) set [_radio, [
        [_radio, "getCurrentChannelData"] call acre_sys_data_fnc_dataEvent,
        CBA_missionTime + TTL
    ]];
    _cached = GVAR(radioData) get _radio;
};

_cached select 0

#undef TTL
