#include "script_component.hpp"

params ["_radio"];

GVAR(owners) getOrDefaultCall [_radio, { createHashmap }]
