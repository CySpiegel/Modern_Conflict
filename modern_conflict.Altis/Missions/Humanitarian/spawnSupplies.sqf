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

