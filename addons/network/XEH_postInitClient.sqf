#include "script_component.hpp"

if !(isMultiplayer) exitWith {};

// Check if a different radio is in range each frame
[{
    call FUNC(tickRadioSignal);
    call FUNC(tickDiscovery);
}] call CBA_fnc_addPerFrameHandler;

[{
    call FUNC(tickPeers);
}, 0.25] call CBA_fnc_addPerFrameHandler;

[QGVAR(syncCount), {
    params ["_count"];
    if (count GVAR(allRadios) == _count) exitWith {};

    [QGVAR(getRadios), player] call CBA_fnc_serverEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(syncRadios), {
    GVAR(allRadios) = _this;
}] call CBA_fnc_addEventHandler;

[QGVAR(addRadio), {
    params ["_radio"];
    GVAR(allRadios) pushBackUnique _radio;
}] call CBA_fnc_addEventHandler;

[QGVAR(removeRadio), {
    params ["_radio"];
    GVAR(allRadios) = GVAR(allRadios) - [_radio];
}] call CBA_fnc_addEventHandler;
