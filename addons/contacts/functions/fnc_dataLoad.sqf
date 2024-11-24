#include "..\script_component.hpp"

params [["_object", objNull, [objNull, ""]]];

if (typeName _object == "OBJECT") then {
    _object = netId _object;
};

GVAR(contactData) getOrDefaultCall [_object, { createHashMap }]
