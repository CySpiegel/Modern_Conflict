 /*
	Author: Cytreen Spiegel

	Description:
		Get a list of location from an object reference point based on arma defined locations

	Parameter(s):
		0: object:
			["NameVillage","NameCity","NameCityCapital"]
		1: array:
			["NameVillage","NameCity","NameCityCapital"]
		1: array:
		["NameVillage","NameCity","NameCityCapital"]

	Returns:
		array of locations with there positions

	Examples:
		_locations = [CENTER, ["NameVillage","NameCity","NameCityCapital"], 25000] call CYS_fnc_getLandLocations;
*/
params ["_objectPivot", "_locationType","_radius"];

_locationLIst = nearestLocations [getPosATL CENTER, _locationType, _radius]; 
_RandomTownPosition = position (_locationLIst select (floor (random (count _locationLIst)))); 
_locationLIst;