/**********************************************************************************************
Add the following code to a laptop/sign whatever you want the players to ace interact with in order to get the mission

_action = ["SuppliesSpawn","Request Aid Mission","",{_nul=execVM"Missions\Humanitarian\supplyMission.sqf"},{true}] call ace_interact_menu_fnc_createAction;  
[this, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["MissionCancel","Cancel Aid Mission","",{_nul=execVM"Missions\Humanitarian\cancelSupplyMission.sqf"},{true}] call ace_interact_menu_fnc_createAction;  
[this, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

**************************************************************************************************/
_water = "Land_WaterBottle_01_stack_F" createvehicle getMarkerPos "waterSpawn";
sleep 0.1;
_rice= "Land_FoodSacks_01_cargo_brown_idap_F" createvehicle getMarkerPos "riceSpawn";
sleep 0.1;
_grain= "Land_PaperBox_01_small_stacked_F" createvehicle getMarkerPos "medSpawn";	
