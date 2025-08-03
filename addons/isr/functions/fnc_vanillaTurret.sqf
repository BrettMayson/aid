#include "..\script_component.hpp"

params ["_unit", "_command", "_args"];

switch (_command) do {
    case "setSpeedMode": {
        (uiNamespace getVariable QGVAR(vanilla_group) controlsGroupCtrl 1006) ctrlSetText format ["SPEED [%1]: ", _args#0];
    };
    case "setAltitudeMode": {
        (uiNamespace getVariable QGVAR(vanilla_group) controlsGroupCtrl 1007) ctrlSetText format ["ALT [%1]: ", _args#0];
    };
};
