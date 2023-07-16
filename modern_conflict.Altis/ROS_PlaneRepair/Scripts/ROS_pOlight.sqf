// Part of ROS_PlaneRepair v2.0
// [] execvm "ROS_PlaneRepair\scripts\ROS_pOlight.sqf";

params ["_redPadlamp"];

_rotpOlight = "Reflector_Cone_01_narrow_orange_F" createVehicleLocal [0,0,0];
_rotpOlight setPosATL (_redPadlamp modelToWorld [0,0,0.12]);

sleep 1;

while {true} do {

	if (ROS_rotatingBeacon) then {
		if (isObjectHidden _rotpOlight) then {_rotpOlight hideObjectGlobal false};
	} else {
		if !(isObjectHidden _rotpOlight) then {_rotpOlight hideObjectGlobal true};
	};

	_rotpOlight setdir (getdir _rotpOlight +2);
	sleep 0.01;
};
