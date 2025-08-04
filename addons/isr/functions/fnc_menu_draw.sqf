params ["_lines", ["_options", []]];
_options params [["_showNumbers", true]];

for "_i" from 0 to 9 do {
    if (_i < count _lines) then {
        private _text = if (_i == 0 || !_showNumbers) then {
            _lines#_i
        } else {
            format ["%1 %2", _i, _lines#_i]
        };
        uiNamespace getVariable format ["aid_isr_menuLine%1", _i] ctrlSetText _text;
    } else {
        uiNamespace getVariable format ["aid_isr_menuLine%1", _i] ctrlSetText "";
    };
};
