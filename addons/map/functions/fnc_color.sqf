#include "script_component.hpp"

params ["_object", ["_useDefined", true]];

private _defined = _object getVariable [QGVAR(color), ""];
if (_useDefined && _defined != "") exitWith { _defined };

switch (assignedTeam _object) do {
    case "RED": { "ColorRed" };
    case "GREEN": { "ColorGreen" };
    case "BLUE": { "ColorBlue" };
    case "YELLOW": { "ColorYellow" };
    default { "ColorWhite" };
}
