#include "script_component.hpp"

GVAR(contacts) = createHashMap;
GVAR(lastRadioOwner) = createHashMap;
GVAR(cooldown) = createHashMap;

[QEGVAR(network,peerDiscovered), {
    params ["_radio", "_object"];
    private _radios = GVAR(contacts) getOrDefault [netId _object, [], true];
    _radios pushBack _radio;
    GVAR(lastRadioOwner) set [_radio, _object];
    [QGVAR(discovered), [_object, _radios]] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QEGVAR(network,peerInRange), {
    params ["_radio", "_object"];
    private _cooldown = GVAR(cooldown) getOrDefault [_radio, 0];
    if (_cooldown > CBA_missionTime) exitWith {};
    GVAR(cooldown) set [_radio, CBA_missionTime + 0.2 + random 0.5];
    private _radios = GVAR(contacts) getOrDefault [netId _object, [], true];
    private _data = [_object, _radios] call FUNC(dataSave);
    [QGVAR(inRange), [_object, _data, _radios]] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QEGVAR(network,peerLost), {
    params ["_radio"];
    private _object = GVAR(lastRadioOwner) getOrDefault [_radio, objNull];
    if (isNull _object) exitWith {};
    private _radios = GVAR(contacts) getOrDefault [netId _object, [], true];
    _radios = _radios - [_radio];
    [QGVAR(lost), [_object, _radio, _radios]] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[{
    if (alive acre_player) then {
        private _previousColor = acre_player getVariable [QGVAR(color), ""];
        private _currentColor = [acre_player, false] call FUNC(color);
        if (_previousColor != _currentColor) then {
            acre_player setVariable [QGVAR(color), _currentColor, true];
        };
    };

    // update color of AI in group if player is leader
    if (leader group acre_player == acre_player) then {
        {
            if (isPlayer _x) then { continue };
            private _previousColor = _x getVariable [QGVAR(color), ""];
            private _currentColor = [_x, false] call FUNC(color);
            if (_previousColor != _currentColor) then {
                _x setVariable [QGVAR(color), _currentColor, true];
            };
        } forEach units group player;
    };
}, 1] call CBA_fnc_addPerFrameHandler;
