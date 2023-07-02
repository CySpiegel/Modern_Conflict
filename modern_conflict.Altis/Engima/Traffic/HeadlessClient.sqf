/*
 * If you want the ambient infantry to be handled by a headless client other than the server, then
 * specify its name in the variable below. For execution on the server, set the value to an empty
 * string ("").
 */

private _useHeadless = ["cys_traffic_headless", 0] call BIS_fnc_getParamValue;
if (_useHeadless > 0) then {
	Engima_Traffic_HeadlessClientName = "HC1";
} else {
	Engima_Traffic_HeadlessClientName = "";
}

