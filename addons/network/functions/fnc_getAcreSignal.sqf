#include "script_component.hpp"

params ["_f", "_mW", "_receiverClass", "_transmitterClass"];

("aid" callExtension ["mesh:get", [_transmitterClass, _receiverClass, _f]]) params ["_ret", "_code"];
if (_code == 0) then {
    _ret = parseSimpleArray _ret;
    [_ret select 0, _ret select 1]
} else {
    WARNING_1("Failed to get signal strength: %1",_ret);
    [0, -992]
};
