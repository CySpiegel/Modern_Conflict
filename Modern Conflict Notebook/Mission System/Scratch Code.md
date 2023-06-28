Place Markers on the map based on random locations and locations within that location
```c++
for "_i" from 1 to 30 do { 
	_locationList = [CENTER, ["NameVillage","NameCity","NameCityCapital", "NameLocal"], 25000] call CYS_fnc_getLocations; 
	
	_randLocation = _locationList call BIS_fnc_selectRandom; 
	
	_size = [_randLocation] call CYS_fnc_getLocationSize;
	
	_pos = position _randLocation;  
	_m = createMarker [format ["mrk%1",random 100000],_pos];  
	_m setMarkerShape "ELLIPSE";  
	_m setMarkerSize [_size,_size];  
	_m setMarkerBrush "Solid";  
	_m setMarkerAlpha 0.5;  
	_m setMarkerColor "ColorRed";  
	 
	_target = [_pos, 1, _size, 3, 0, 20, 0] call BIS_fnc_findSafePos; 
	_m = createMarker [format ["mrk%1",random 100000],_target];   
	_m setMarkerShape "ELLIPSE";   
	_m setMarkerSize [20,20];   
	_m setMarkerBrush "Solid";   
	_m setMarkerAlpha 0.5;   
	_m setMarkerColor "ColorBlue"; 

};
```
