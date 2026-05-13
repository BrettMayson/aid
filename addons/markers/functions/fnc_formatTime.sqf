#include "..\script_component.hpp"

/**
 * Format dayTime value to readable time string
 *
 * Args: _dayTime
 * Returns: formatted time string (HH:MM)
 */

params ["_dayTime"];

private _hours = floor _dayTime;
private _minutes = floor ((_dayTime - _hours) * 60);

format ["%1:%2", 
    if (_hours < 10) then { "0" + str _hours } else { str _hours },
    if (_minutes < 10) then { "0" + str _minutes } else { str _minutes }
]
