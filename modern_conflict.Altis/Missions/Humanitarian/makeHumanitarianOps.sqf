_missionType = [_this, 0, ""] call BIS_fnc_param;
	
_myHint ="Requesting Humanitarian Aid Operations";
GlobalHint = _myHint;
publicVariable "GlobalHint";
// Hint will only show for the person requesting the mission
hintsilent parseText _myHint;

sleep 0.3;




_pos = position _location; 
_m = createMarker [format ["mrk%1",random 100000],_pos]; 
_m setMarkerShape "ELLIPSE"; 
_m setMarkerSize [500,500]; 
_m setMarkerBrush "Solid"; 
_m setMarkerAlpha 0.5; 
_m setMarkerColor "ColorRed"; 



_pos = position _location;  
_m = createMarker [format ["mrk%1",random 100000],_pos];  
_m setMarkerShape "ELLIPSE";  
_m setMarkerSize [500,500];  
_m setMarkerBrush "Solid";  
_m setMarkerAlpha 0.5;  
_m setMarkerColor "ColorRed"; 

_target = [_pos, 1, 500, 3, 0, 20, 0] call BIS_fnc_findSafePos;
_m = createMarker [format ["mrk%1",random 100000],_target];  
_m setMarkerShape "ELLIPSE";  
_m setMarkerSize [20,20];  
_m setMarkerBrush "Solid";  
_m setMarkerAlpha 0.5;  
_m setMarkerColor "ColorBlue"; 

 
_pos = position _location;  
_loc = nearestLocation [_pos, ""];
hint str (type _loc)

fn_spawnHumanitarianSupplyMission = {
	// Get Mission location
	// Array of markers of AO Sites place in the mission editor
	_locationList = [CENTER, ["NameVillage","NameCity","NameCityCapital"], 25000] call CYS_fnc_getLocations;
	_location = _locationList call BIS_fnc_selectRandom;

	
}