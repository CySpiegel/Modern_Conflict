_missionType = [_this, 0, ""] call BIS_fnc_param;
	
_myHint ="Requesting Humanitarian Aid Operations";
GlobalHint = _myHint;
publicVariable "GlobalHint";
// Hint will only show for the person requesting the mission
hintsilent parseText _myHint;

sleep 0.3;


fn_spawnHumanitarianSupplyMission = {
	// Get Mission location
	// Array of markers of AO Sites place in the mission editor
	_locationList = [CENTER, ["NameVillage","NameCity","NameCityCapital"], 25000] call CYS_fnc_getLocations;
	_location = _locationList call BIS_fnc_selectRandom;

	
}