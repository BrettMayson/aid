#include "script_component.hpp"

params ["_radio"];

private _radio = toLower _radio;

private _ret = 0;

{
    {
        if (_x isEqualTo _radio) then {
            _ret = _ret max (_y select 0);
        };
    } forEach _y;
} forEach GVAR(peerRadios);

_ret
