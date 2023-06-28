_missionType = [_this, 0, ""] call BIS_fnc_param;
	
_myHint ="Requesting Humanitarian Aid Operations";
GlobalHint = _myHint;
publicVariable "GlobalHint";
// Hint will only show for the person requesting the mission
hintsilent parseText _myHint;

sleep 0.3;


fn_spawnHumanitarianSupplyMission = {
	publicVariable "supplyMarker";
	_exists = ["supplyDrop"] call BIS_fnc_taskExists; 
	private _completionRadius = 30;
	//if there's already an aid mission running, warn the player and exit
	if (str _exists == "true") exitWith {
		["HQ", "You already have 1 active Aid mission"] spawn BIS_fnc_showSubtitle;
	};


	_locationList = [CENTER, ["NameVillage","NameCity","NameCityCapital"], 25000] call CYS_fnc_getLocations; 

	_randLocation = _locationList call BIS_fnc_selectRandom; 

	_areaRadius = [_randLocation] call CYS_fnc_getLocationSize;

	_areaLocation = position _randLocation;    
	
	_target = [_areaLocation, 1, _areaRadius, 3, 0, 20, 0] call BIS_fnc_findSafePos; 
	supplyMarker = createMarker ["deliveryLocation",_target];   
	supplyMarker setMarkerShape "ELLIPSE";   
	supplyMarker setMarkerSize [_completionRadius,_completionRadius];   
	supplyMarker setMarkerBrush "Solid";   
	supplyMarker setMarkerAlpha 0.5;   
	supplyMarker setMarkerColor "ColorRed"; 

	//create the task
	[WEST,["supplyDrop"],["Take a truck and deliver pallets of Rice and Water along with the Medical supplies to the location marked on the map.<br></br><br></br>","Deliver supplies","supplyMarker"],getMarkerPos (supplyMarker),1,1,true] call BIS_fnc_taskCreate;
	["supplyDrop", "ASSIGNED",true] call BIS_fnc_taskSetState;
	["supplyDrop","container"] call BIS_fnc_taskSetType;

	//delete any supplies already on the spot to avoid dumb shit
	_delete = nearestObjects [getMarkerPos "waterSpawn", ["Land_WaterBottle_01_stack_F"], 50];
	{
		sleep 0.1;
		deleteVehicle _x;
	}foreach _delete;

	_delete = nearestObjects [getMarkerPos "riceSpawn", ["Land_FoodSacks_01_cargo_brown_idap_F"], 50];
	{
		sleep 0.1;
		deleteVehicle _x;
	}foreach _delete;

	_delete = nearestObjects [getMarkerPos "medSpawn", ["Land_PaperBox_01_small_stacked_F"], 50];
	{
		sleep 0.1;
		deleteVehicle _x;
	}foreach _delete;


	// Create Supplys for Delivery
	_water = "Land_WaterBottle_01_stack_F" createvehicle getMarkerPos "waterSpawn";
	sleep 0.1;
	_rice= "Land_FoodSacks_01_cargo_brown_idap_F" createvehicle getMarkerPos "riceSpawn";
	sleep 0.1;
	_grain= "Land_PaperBox_01_small_stacked_F" createvehicle getMarkerPos "medSpawn";
	sleep 0.1;


	//Check if supplies have been delivered
	waitUntil {
		_obj = getMarkerPos supplyMarker nearobjects ["Land_WaterBottle_01_stack_F",_completionRadius]; 
		_obj2 = getMarkerPos supplyMarker nearobjects ["Land_FoodSacks_01_cargo_brown_idap_F",_completionRadius]; 
		_obj3 = getMarkerPos supplyMarker nearobjects ["Land_PaperBox_01_small_stacked_F",_completionRadius]; 
		count _obj > 0 && count _obj2 > 0 && count _obj3 > 0;
	};

	sleep 5;

	//succeed the task
	["supplyDrop", "SUCCEEDED",true] call BIS_fnc_taskSetState;
	[master, 0.5] remoteExec ["addCuratorPoints", 0, false];
	[getMarkerPos supplyMarker, [side player], -20] call ALIVE_fnc_updateSectorHostility;
	// Will add funds to the acex fortification system
	[west, 1000, false] call acex_fortify_fnc_updateBudget;

	waitUntil { 
		//this should wait until players are 100m away before despawning the objects, but I'm 99% sure it's wrong
		{getMarkerPos (supplyMarker) distance _x > 100 } count (playableUnits + switchableUnits) > 0
	};

	sleep 0.1;
	_delete = nearestObjects [getMarkerPos supplyMarker, ["Land_WaterBottle_01_stack_F"], 50];
	{deleteVehicle _x;}foreach _delete;
	sleep 0.1;
	_delete = nearestObjects [getMarkerPos supplyMarker, ["Land_FoodSacks_01_cargo_brown_idap_F"], 50];
	{deleteVehicle _x;}foreach _delete;
	sleep 0.1;
	_delete = nearestObjects [getMarkerPos supplyMarker, ["Land_PaperBox_01_small_stacked_F"], 50];
	{deleteVehicle _x;}foreach _delete;
	sleep 0.1;

	//reset everything
	sleep 5;
	["supplyDrop",true] call BIS_fnc_deleteTask;
	deleteMarker "deliveryLocation";
	supplyMarker = "";
};

// [[],"Missions\Humanitarian\initmissionAir.sqf"] remoteExec ["BIS_fnc_execVM", 0]; 
_missionDetails = switch (_missionType) do {
	case "HumanitarianSupply": {call fn_spawnHumanitarianSupplyMission;};

};