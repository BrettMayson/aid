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
