#include "..\script_component.hpp"

params [["_strength", 1], ["_color", "w"]];

private _root = QPATHTOF(icons);

private _strength = round (_strength * 3) + 1;

format ["%1\%2sig-%3_ca.paa", _root, _color, _strength]
