// Part of ROS_Helirepair v1.5
// [] execvm "ROS_HeliRepair\scripts\ROS_hOlight.sqf";

params ["_heliPadlamp"];

if (isnil "ROS_rothBeaconOn") then {
	ROS_rothBeaconOn = false;
	publicVariable "ROS_rothBeaconOn";
};

_rothOlight = "Reflector_Cone_01_narrow_orange_F" createVehicleLocal [0,0,0];
_rothOlight setPosATL (_heliPadlamp modelToWorld [0,0,0.12]);

sleep 1;

while {true} do {

	if (ROS_rothBeaconOn) then {
		if (isObjectHidden _rothOlight) then {_rothOlight hideObject false};
	} else {
		if !(isObjectHidden _rothOlight) then {_rothOlight hideObject true};
	};

	_rothOlight setdir (getdir _rothOlight +2);
	sleep 0.01;
};
