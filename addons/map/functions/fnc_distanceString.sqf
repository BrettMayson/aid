params ["_distance"];

if (_distance < 1000) then {
    format ["%1 m", round _distance]
} else {
    format ["%1 km", round (_distance / 100) / 10]
}
