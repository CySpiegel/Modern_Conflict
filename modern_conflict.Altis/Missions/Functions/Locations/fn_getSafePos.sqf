 /*
	Author: Cytreen Spiegel
	Description:

	Parameter(s):

	Returns:

	Examples:

*/
params["_locationType", "_areaLocation", "_areaRadius"];

private _computedLocationTarget;

hint str _locationType;
switch (_locationType) do {
	case "generalArea": { _computedLocationTarget = [_areaLocation, 1, _areaRadius, 3, 0, 20, 0] call BIS_fnc_findSafePos; };
	//case "profile2": { _computedLocationTarget = [_areaLocation, 1, _areaRadius, 3, 0, 20, 0] call BIS_fnc_findSafePos; };
};

_computedLocationTarget;
