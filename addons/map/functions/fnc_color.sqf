#include "script_component.hpp"

params ["_object"];

if !([_object, "team"] call EFUNC(network,hasCapability)) exitWith { "" };

switch (assignedTeam _object) do {
    case "MAIN": { "ColorWhite" };
    case "RED": { "ColorRed" };
    case "GREEN": { "ColorGreen" };
    case "BLUE": { "ColorBlue" };
    case "YELLOW": { "ColorYellow" };
    default { "" };
}
