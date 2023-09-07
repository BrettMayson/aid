#include "script_component.hpp"

// Check if a different radio is in range each frame
[{
    call FUNC(tickRadioSignal);
    call FUNC(tickDiscovery);
}] call CBA_fnc_addPerFrameHandler;

[{
    call FUNC(tickPeers);
}, 0.5] call CBA_fnc_addPerFrameHandler;
