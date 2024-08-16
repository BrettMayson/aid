#include "script_component.hpp"

GVAR(uav) = objNull;

GVAR(uavFilmGrain) = ppEffectCreate ["FilmGrain", 2012];

["ACE_controlledUAV", {
    params ["_uav"];
    if (isNull _uav) exitWith {
        GVAR(uav) = objNull;
    };
    if ((!isNull _uav) && isNull GVAR(uav)) then {
        GVAR(uav) = _uav;
        [{ call FUNC(uavPFH)}, 0.25] call CBA_fnc_addPerFrameHandler;
    };
}] call CBA_fnc_addEventHandler;

[[[], [4,7]], GVAR(maxRange), [], "Max Range", [false, true], [{}, {
    params ["", "_itemCfg"];
    getNumber (_itemCfg >> QGVAR(maxRange));
}, {
    getNumber (_itemCfg >> QGVAR(maxRange)) != 0
}]] call ace_arsenal_fnc_addStat;
