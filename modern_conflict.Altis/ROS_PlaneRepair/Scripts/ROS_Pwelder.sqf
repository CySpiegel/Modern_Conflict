/* Welder by RickOShay v2.0
This script is called by ROS_PlaneRepair.sqf
Part of ROS_PlaneRepair
[] execvm "ROS_Planepair\ROS_Pwelder.sqf";

LEGAL STUFF
Credit must be given in your mission and on the Steam Workshop if this script or part thereof including the particle effect is used in
any mission or derivative works. All ROS Plane repair scripts must be kept together.

Average repair times (dependent on number of damaged hitpoints):
Min: ~60 secs (5 hitpoints) Max: ~2.50 mins (all hitpoints (~40 hp) - ie setdamage) excluding refuel and walk time overhead ~40secs

Executed on All machines except ded server
*/

params ["_pilot", "_pWelder", "_veh", "_pweldingRod", "_pweldingCart", "_prepaircase"];

_light = objNull;

_pWelder setBehaviour "CARELESS";

if ("AN2" in typeOf _veh) then {
	_prepaircaseP setposatl (_prepaircaseP modelToWorld [0.5,0,-0.2]);
	_pWelder setPosATL (_pWelder modelToWorld [0.5,0,0]);
};

if ("C_Plane_Civil" in typeof _veh or "I_Plane_ION" in typeOf _veh or "C_Plane_Orbit" in typeOf _veh) then {
	[_pWelder, "AidlPknlMstpSrasWrflDnon_G0S"] remoteExec ["switchMove", 0];
};

sleep (1 + random 3);

ROS_weldingSparksP_Fnc = {
	params ["_pweldingRod", "_sparkpos"];
	_sparkPos = position _pweldingRod;
	_wSparks = "#particlesource" createVehicleLocal [0,0,0];
	_wSparks setParticleCircle [0, [0, 0, 0]];
	_wSparks setParticleRandom [
	2, //LifeTime
	[0,0,0], //Position
	[0,0,0], //MoveVelocity
	30, //rotationVel
	0.25, //Scale
	[1,0.8,0.5,1], //Color
	0.50, //randDirPeriod
	1, //randDirIntesity
	30 // Angle
	];

	_wSparks setParticleParams [
	["\A3\data_f\cl_water", 1, 0, 1], //animationName
	"",
	"Billboard", // particleType
	1, // Timer period
	4, // lifetime
	[0.65, 0, 0], // position
	[0.2+(random 0.30),(0.2+random 0.30),-0.5], //moveVelocity
	500, //rotationVelocity
	1050, // weight
	7.9, // Volume
	0.1, // rubbing
	[0.017,0.017], // size
	[[1,0.8,0.5, 1],[1,0.8,0.5,1]], // color
	[0.16], // animationSpeed
	0, // randomDirectionPeriod
	0, // randomDirectionIntensity
	"", // onTimerScript
	"", // beforeDestroyScript
	_pweldingRod, // object
	0, // angle
	false, // surface
	0.25, // bounceOnSurface
	[[0,0,0,1]] // emissiveColor
	];

	_wSparks attachTo [_pweldingRod,[0.65,0,0]];
	_wSparks setDropInterval 0.001;
}; // end ROS_weldingSparksP_Fnc

_y = 0;
_dist = 0.65;

_light = "#lightpoint" createVehicleLocal (getpos _pweldingRod);
_light setlightBrightness 0;
_light setlightColor [1.0, 1.0, 0.5];
_light attachto [_pweldingRod, [_dist, _y, 0]];;

while {!ROSPlaneRepaired} do {
	sleep 0.5;
	_smoke = "#particlesource" createVehicleLocal getPosATL _pweldingRod;
	_smoke attachto [_pweldingRod, [_dist, _y, 0]];
	_smoke setParticleClass "AvionicsSmoke";
	_smokepos = getpos _smoke;
	_sparkpos = [(_smokepos select 0), _smokepos select 1, (_smokepos select 2)+0.03];

	_light setlightBrightness 1;

	[_pweldingRod, _sparkpos] spawn ROS_weldingSparksP_Fnc;

	_sparks1 = "#particlesource" createVehicleLocal _sparkpos;
	_sparks1 setParticleClass "AvionicsSparks";
	sleep 0.2;
	_sparks1 attachTo [_pweldingRod,[0.65,0,0]];

	[_light, _sparks1] spawn {
		params ["_light", "_sparks1"];
		// flicker
		while {alive _sparks1} do {
			_light setlightBrightness (0.75 + random 0.25);
			_light setlightColor[1.0, 1.0, (0.7 + random 0.3)];
			sleep 0.12 + random 0.2;
			_light setlightBrightness 0;
		};
	};

	_sfx = selectRandom ["welding1P", "welding2P"];
	[_pweldingCart, _pilot] say3D [_sfx, 100];

	if (ROSPlaneRepaired) exitWith {
		deleteVehicle _light;
		deleteVehicle _pweldingCart;
		{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_pWelder nearObjects 7);
	};

	sleep 10; // length of sfx

	_light setlightBrightness 0;
	{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_pWelder nearObjects 7);

	// Intermittent break
	sleep (1 + random 2);
}; // end while

deleteVehicle _light;
deleteVehicle _pweldingCart;
{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_pWelder nearObjects 7);

