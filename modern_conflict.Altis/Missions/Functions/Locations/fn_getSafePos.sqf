 /*
	Author: Cytreen Spiegel
	Description:

	Parameter(s):

	Returns:

	Examples:

*/


params["_locationType", "_areaLocation", "_areaRadius"];

private _target = 0;

switch (_locationType) do {
	case "nearCityButAwayFromBuildings": { _target = [_areaLocation, 1, _areaRadius, 3, 0, 20, 0] call BIS_fnc_findSafePos; };
	case "profile2": { _target = [_areaLocation, 1, _areaRadius, 3, 0, 20, 0] call BIS_fnc_findSafePos; };
};

_target;
