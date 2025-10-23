#include "script_component.hpp"

GVAR(contactsLoopHandler) = createHashMap;
GVAR(contactsNextCheck) = createHashMap;

addMissionEventHandler ["ExtensionCallback", {
    params ["_name", "_function", "_data"];
    if (_name != "aid_contacts") exitWith {};
    switch (_function) do {
        case "added": {
            if (aid_debug) then {
                systemChat format ["Contact Added: %1", _data];
            };
            private _loopHandler = [{
                (_this#0) params ["_id"];
                private _object = objectFromNetId _id;
                if (GVAR(contactsNextCheck) getOrDefault [_id, 0] > CBA_missionTime) exitWith {};
                private _nextCheck = linearConversion [50, 2000, _object distance2D player, 0, 5];
                GVAR(contactsNextCheck) set [_id, CBA_missionTime + _nextCheck];
                private _data = [_object] call FUNC(dataSave);
                [QGVAR(update), [_id, _data]] call CBA_fnc_localEvent;
            }, 0.2, _data] call CBA_fnc_addPerFrameHandler;
            GVAR(contactsLoopHandler) set [_data, _loopHandler];
        };
        case "removed": {
            if (aid_debug) then {
                systemChat format ["Contact Removed: %1", _data];
            };
            private _loopHandler = GVAR(contactsLoopHandler) get _data;
            if (isNil "_loopHandler") exitWith {};
            [_loopHandler] call CBA_fnc_removePerFrameHandler;
            GVAR(contactsLoopHandler) set [_data, nil];
            [QGVAR(lost), _data] call CBA_fnc_localEvent;
        };
    };
}];

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

["ace_placedInBodyBag", {
    params ["_unit", "_bodyBag"];
    _bodyBag setVariable [QGVAR(name), name _unit, true];
    _bodyBag setVariable [QGVAR(color), [_unit, false] call FUNC(color), true];
}] call CBA_fnc_addEventHandler;
