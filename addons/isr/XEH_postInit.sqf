#include "script_component.hpp"

GVAR(cameraChangedEH) = ["cameraView", {
    params ["", "_new", "_old"];
    if (_old isEqualTo "GUNNER") then {
        if !(isNil QGVAR(pfh)) then {
            [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
            GVAR(pfh) = nil;
        };
    };
    if (_new isEqualTo "GUNNER" && call FUNC(isISR)) then {
        private _vehicle = if (getConnectedUAV ace_player isNotEqualTo objNull) then {
            getConnectedUAV ace_player
        } else {
            vehicle ace_player
        };
        private _function = getText (configOf _vehicle >> QGVAR(function));
        if (_function isNotEqualTo "") then {
            GVAR(vehicleFunction) = compile format ["_this call %1", _function];
            [_vehicle, "setup", []] call GVAR(vehicleFunction);
            GVAR(menuStack) = [];
            GVAR(menuTargetOpen) = false;
            _vehicle setVariable [QGVAR(markerChannels), DEFAULT_MARKER_CHANNELS, true];
        };
        GVAR(pfh) = [FUNC(pfh_main)] call CBA_fnc_addPerFrameHandler;
    };
}, true] call CBA_fnc_addPlayerEventHandler;
