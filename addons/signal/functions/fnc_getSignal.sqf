#include "..\script_component.hpp"

params ["_f", "_mW", "_rxPos", "_txPos", ["_class", ""]];

private _realRadio = if (_class == "") then { "ACRE_PRC152" } else {
    configName (inheritsFrom (configFile >> "CfgWeapons" >> _class))
};
_realRadio = toLower _realRadio;

if (_realRadioRx isEqualTo "acre_bf888s") then {
    // Drop to 2.5W from 5W, just for fun
    _mW = _mW * 0.5;
};

private _distance = _txPos distance _rxPos;

private _Lfs = -27.55 + 20 * log(_f) + 20 * log(_distance);
private _Ptx = 10 * (log ((_mW)/1000)) + 30;

private _ituLoss = 36;

private _Ltx = 3;
private _Lrx = 3;

private _Lm = _ituLoss + ((random 1) - 0.5);

private _Lb = _Ptx - _Ltx - _Lfs - _Lm - _Lrx;

private _sinadRating = getNumber (configFile >> "CfgAcreComponents" >> _realRadio >> "sinadRating");
private _Sl = (abs _sinadRating) / 2;
private _Slp = 0.075;

private _bottom = _sinadRating - (_Sl * _Slp);
private _Snd = abs ((_bottom - (_Lb max _bottom)) / _Sl);
private _Px = 100 min (0 max (_Snd * 100));
_Px = _Px / 100;

private _collision = ([_txPos, _rxPos] call FUNC(getCollision)) min 1;

_Px = _Px * (1 - _collision);

[_Px, _Lb]
