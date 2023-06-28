 /*
	Author: Cytreen Spiegel

	Description:
		Get a list of location from an object reference point based on arma defined locations

	Parameter(s):
		0: object:
			location

	Returns:
		array of locations with there positions

	Examples:
		_size = [location] call CYS_fnc_getLandLocations;
*/

params ["_locationData"];

_pos = position _locationData;  
_loc = nearestLocation [_pos, ""];
_locationType = type _loc;

private _locationRadius = 0;

switch (_locationType) do {
	case "NameVillage": { _locationRadius = 150;};
	case "NameCity": { _locationRadius = 300;};
	case "NameCityCapital": { _locationRadius = 1000;};
	case "NameLocal": { _locationRadius = 200; }
};

_locationRadius;
