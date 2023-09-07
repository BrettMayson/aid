#include "script_component.hpp"

private _check = keys GVAR(peerObjects);
_check append (keys GVAR(peers));
_check arrayIntersect _check;

{
    private _args = [objectFromNetId _x, GVAR(peerObjects) get _x];
    if !(_x in GVAR(peers)) then {
        GVAR(peers) set [_x, GVAR(peerObjects) get _x];
        [QGVAR(peerDiscovered), _args] call CBA_fnc_localEvent;
        [QGVAR(peerInRange), _args] call CBA_fnc_localEvent;
    } else {
        [QGVAR(peerInRange), _args] call CBA_fnc_localEvent;
    };
    if !(_x in GVAR(peerObjects)) then {
        GVAR(peers) deleteAt _x;
        [QGVAR(peerLost), [_args select 0]] call CBA_fnc_localEvent;
        [QGVAR(peerOutOfRange), [_args select 0]] call CBA_fnc_localEvent;
    } else {
        [QGVAR(peerOutOfRange), [_args select 0]] call CBA_fnc_localEvent;
    };
} forEach _check;
