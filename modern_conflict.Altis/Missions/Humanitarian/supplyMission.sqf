publicVariable "supplyMarker";

_exists = ["supplyDrop"] call BIS_fnc_taskExists; 

//if there's already an aid mission running, warn the player and exit
if (str _exists == "true") exitWith
{
["HQ", "You already have 1 active Aid mission"] spawn BIS_fnc_showSubtitle;
};

sleep 1;
//pick a random location. if you want more or less locations just add/subtract markers from this array (and the map)
supplyMarker = ["supplyMarker_1",
				"supplyMarker_2"
				]call BIS_fnc_selectRandom;

//delete any supplies already on the spot to avoid dumb shit
_delete = nearestObjects [getMarkerPos "waterSpawn", ["Land_WaterBottle_01_stack_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;
_delete = nearestObjects [getMarkerPos "riceSpawn", ["Land_FoodSacks_01_cargo_brown_idap_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;
_delete = nearestObjects [getMarkerPos "medSpawn", ["Land_PaperBox_01_small_stacked_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;

//create the task
[WEST,["supplyDrop"],["Take a truck and deliver pallets of Rice and Water along with the Medical supplies to the location marked on the map.<br></br><br></br>","Deliver supplies","supplyMarker"],getMarkerPos (supplyMarker),1,1,true] call BIS_fnc_taskCreate;
["supplyDrop", "ASSIGNED",true] call BIS_fnc_taskSetState;
["supplyDrop","container"] call BIS_fnc_taskSetType;

//Spawn Supplies
_water = "Land_WaterBottle_01_stack_F" createvehicle getMarkerPos "waterSpawn";
sleep 0.1;
_rice= "Land_FoodSacks_01_cargo_brown_idap_F" createvehicle getMarkerPos "riceSpawn";
sleep 0.1;
_grain= "Land_PaperBox_01_small_stacked_F" createvehicle getMarkerPos "medSpawn";	


//Check if supplies have been delivered
waitUntil {
    _obj = getMarkerPos supplyMarker nearobjects ["Land_WaterBottle_01_stack_F",30]; 
    _obj2 = getMarkerPos supplyMarker nearobjects ["Land_FoodSacks_01_cargo_brown_idap_F",30]; 
    _obj3 = getMarkerPos supplyMarker nearobjects ["Land_PaperBox_01_small_stacked_F",30]; 
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
supplyMarker = "";