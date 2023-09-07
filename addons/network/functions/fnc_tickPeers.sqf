#include "script_component.hpp"

private _keys = keys GVAR(peerObjects);
private _check = +_keys;
_check append GVAR(peers);
_check arrayIntersect _check;

{
    private _args = [_x, objectFromNetId (GVAR(peerObjects) get _x)];
    if !(_x in GVAR(peers)) then {
        GVAR(peers) pushBackUnique _x;
        [QGVAR(peerDiscovered), _args] call CBA_fnc_localEvent;
        [QGVAR(peerInRange), _args] call CBA_fnc_localEvent;
    } else {
        [QGVAR(peerInRange), _args] call CBA_fnc_localEvent;
    };
    if !(_x in _keys) then {
        GVAR(peers) deleteAt (GVAR(peers) find _x);
        [QGVAR(peerLost), [_args select 0]] call CBA_fnc_localEvent;
        [QGVAR(peerOutOfRange), [_args select 0]] call CBA_fnc_localEvent;
    } else {
        [QGVAR(peerOutOfRange), [_args select 0]] call CBA_fnc_localEvent;
    };
} forEach _check;
