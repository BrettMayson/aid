#include "..\script_component.hpp"

if (getConnectedUAV ace_player isNotEqualTo objNull) then {
    // need to fix with https://community.bistudio.com/wiki/UAVControl
    [getConnectedUAV ace_player, true]
} else {
    [vehicle ace_player, false]
} params ["_vehicle", "_isUAV"];

GVAR(vehicle) = _vehicle;
GVAR(isUAV) = _isUAV;

if (_vehicle isEqualTo ace_player) exitWith {};

// Speed
[_vehicle, "setSpeedMode", [GVAR(speedCurrentMode)]] call GVAR(vehicleFunction);
(uiNamespace getVariable QGVAR(speedControl)) ctrlSetText (([_vehicle, GVAR(speedCurrentMode)] call FUNC(getSpeed)) toFixed 0);

// Altitude
[_vehicle, "setAltitudeMode", [GVAR(altCurrentMode)]] call GVAR(vehicleFunction);
(uiNamespace getVariable QGVAR(altControl)) ctrlSetText (([_vehicle, GVAR(altCurrentMode)] call FUNC(getAltitude)) toFixed 0);

// Signal
if (_isUAV) then {
    (uiNamespace getVariable QGVAR(signalControl)) ctrlSetText format ["%1%%", (100 * EGVAR(uav,currentSignal)) toFixed 0];
    (uiNamespace getVariable QGVAR(connModeControl)) ctrlSetText EGVAR(uav,mode);
    if (EGVAR(uav,mode) == "LOS") then {
        (uiNamespace getVariable QGVAR(connFreqControl)) ctrlSetText ([_vehicle getVariable [QEGVAR(uav,freq), 1300]] call EFUNC(map,displayFrequency));
        (uiNamespace getVariable QGVAR(connPowerControl)) ctrlSetText ([_vehicle getVariable [QEGVAR(uav,power), 800]] call EFUNC(map,displayPower));
    } else {
        (uiNamespace getVariable QGVAR(connFreqControl)) ctrlSetText "";
        (uiNamespace getVariable QGVAR(connPowerControl)) ctrlSetText "";
    };
};

[_vehicle] call FUNC(pfh_markers);
[_vehicle] call FUNC(pfh_targets);
