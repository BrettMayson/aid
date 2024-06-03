#include "..\script_component.hpp"

params ["_object"];

private _lastTrail = _object getVariable [QGVAR(lastTrail), 0];

if (CBA_missionTime - _lastTrail < 1) exitWith {
    _object getVariable [QGVAR(trail), []]
};

private _history = _object getVariable [QGVAR(trail), []];

if (count _history > 20) then {
    _history = _history select [0, 20];
};

_history insert [0, [getPosASL _object]];

_object setVariable [QGVAR(trail), _history];
_object setVariable [QGVAR(lastTrail), CBA_missionTime];

_history
