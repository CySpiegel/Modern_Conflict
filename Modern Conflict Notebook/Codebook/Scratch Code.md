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

```json
_debug = true;  
  
MinimumAIamount = 3;  
_MainBasepos = getMarkerPos "markerMainBase";  
_mainpos = getMarkerPos "markerbase";  
_APCPos = [_mainpos,150, 200, 3, 0, 20, 0] call BIS_fnc_findSafePos;  
  
  
  
if (_debug) then {  
//testing the vars...  
hint format ["APCPos: %1", _APCPos];  
sleep 2;  
};  
  
//find a road  
_APCroad = (_APCPos nearRoads 500) select 0;  
  
if (_debug) then {  
hint format ["Pos: %1", _APCroad];  
sleep 2;  
//set a marker so we know where it is  
_markerstr= createMarker ["Marker1", _APCroad];  
_markerstr setMarkerShape "ICON";  
_markerstr setMarkerSize [1,1];  
_markerstr setMarkertype "hd_destroy";  
_markerstr setMarkerText "HERE";  
_markerstr setMarkerColor "ColorRed";  
};
```


Select a road in a town city or capital ( Use for Humanitarian Aid drop off locations)
```json
_locationList = [CENTER, ["NameVillage","NameCity","NameCityCapital"], 25000] call CYS_fnc_getLocations;  
_randLocation = _locationList call BIS_fnc_selectRandom;  
_size = [_randLocation] call CYS_fnc_getLocationSize; 
_pos = position _randLocation;   
 
 
 
_m = createMarker [format ["mrk%1",random 100000],_pos];   
_m setMarkerShape "ELLIPSE";   
_m setMarkerSize [_size,_size];   
_m setMarkerBrush "Solid";   
_m setMarkerAlpha 0;   
_m setMarkerColor "ColorRed";   
 
 
 
_APCroad = (_pos nearRoads _size);  
_randRoadLocation = _APCroad call BIS_fnc_selectRandom; 


_m = createMarker [format ["mrk%1",random 100000],_randRoadLocation];    

_m setMarkerShape "ICON";   
_m setMarkerSize [1,1];   
_m setMarkertype "hd_destroy";   
_m setMarkerText "";   
_m setMarkerColor "ColorRed";  
```
