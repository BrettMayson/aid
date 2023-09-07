#include "script_component.hpp"

if (count GVAR(searchObjects) == 0) then {
    GVAR(peerObjects) = +GVAR(scanningObjects);
    GVAR(scanningObjects) = createHashMap;
    GVAR(searchObjects) append allPlayers;
    GVAR(searchObjects) append allUnits;
    GVAR(searchObjects) append allDead;
    GVAR(searchObjects) append vehicles;
    GVAR(searchObjects) append (allMissionObjects "WeaponHolder");
    GVAR(searchObjects) arrayIntersect GVAR(searchObjects);
};

private _checking = GVAR(searchObjects) deleteAt 0;

if (_checking isEqualTo objNull) exitWith {};
if (_checking isEqualTo player) exitWith {};

private _radios = [];
if (_checking isKindOf "Man") then {
    _radios = [_checking] call acre_sys_core_fnc_getGear;
} else {
    private _containers = [_checking];
    _containers append ((everyContainer _checking) apply {_x select 1});
    {
        _radios = ((getItemCargo _x) select 0) select {toLower (_x select [0, 4]) == "acre"};
        {
            _radios pushBack _x;
            private _mountedRadio = [_x] call acre_sys_rack_fnc_getMountedRadio;
            if (_mountedRadio != "") then {
                _radios pushBack _mountedRadio;
            };
        } forEach (_x getVariable ["acre_sys_rack_vehicleRacks", []]);
    } forEach _containers;
};

private _id = _checking call BIS_fnc_netId;

{
    if ([_x] call FUNC(getStrength) > 0) exitWith {
        GVAR(scanningObjects) set [_id, _x];
    };
} forEach _radios;
