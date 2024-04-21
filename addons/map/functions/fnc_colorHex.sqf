#include "..\script_component.hpp"

params ["_team"];

switch (_team) do {
    case "ColorRed";
    case "RED": {missionNamespace getVariable ["ace_nametags_nametagColorRed", [221, 0, 0]]};
    case "ColorGreen";
    case "GREEN": {missionNamespace getVariable ["ace_nametags_nametagColorGreen", [0, 221, 0]]};
    case "ColorBlue";
    case "BLUE": {missionNamespace getVariable ["ace_nametags_nametagColorBlue", [0, 0, 221]]};
    case "ColorYellow";
    case "YELLOW": {missionNamespace getVariable ["ace_nametags_nametagColorYellow", [221, 221, 0]]};
    default {missionNamespace getVariable ["ace_nametags_nametagColorMain", [255, 255, 255]]};
} call BIS_fnc_colorRGBtoHTML
