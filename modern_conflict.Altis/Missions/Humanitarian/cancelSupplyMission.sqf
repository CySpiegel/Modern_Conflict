_delete = nearestObjects [getMarkerPos "waterSpawn", ["Land_WaterBottle_01_stack_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;
_delete = nearestObjects [getMarkerPos "riceSpawn", ["Land_FoodSacks_01_cargo_brown_idap_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;
_delete = nearestObjects [getMarkerPos "medSpawn", ["Land_PaperBox_01_small_stacked_F"], 50];
{deleteVehicle _x;}foreach _delete;
sleep 0.1;

["supplyDrop", "CANCELED",true] call BIS_fnc_taskSetState;
["supplyDrop",true] call BIS_fnc_deleteTask;
supplyMarker = "none";
