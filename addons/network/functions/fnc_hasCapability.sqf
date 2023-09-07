#include "script_component.hpp"

params ["_object", "_capability"];

if (_object == objNull) exitWith {};

private _gpsItems = ["ItemGPS", "ACE_DAGR", "ACE_microDAGR"];

switch (_capability) do {
    case "gps": {
        if (_object isKindOf "Man") then {
            if ((_object getSlotItemName 612) != "") then {
                true
            } else {
                private _items = items _object;
                _gpsItems findIf {_x in _items} != -1
            }
        } else {
            private _items = [];
            private _containers = [_checking];
            _containers append ((everyContainer _checking) apply {_x select 1});
            {
                _items = (getItemCargo _x) select 0;
            } forEach _containers;
            _gpsitems findIf {_x in _items} != -1
        }
    };
    case "team": {
        _object isKindOf "Man"
    };
}
