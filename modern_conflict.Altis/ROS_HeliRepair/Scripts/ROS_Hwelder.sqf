/* Welder by RickOShay v1.5
This script is called by ROS_HeliRepair.sqf
Part of ROS_Helirepair
[] execvm "ROS_HeliRepair\ROS_Hwelder.sqf";

LEGAL STUFF
Credit must be given in your mission and on the Steam Workshop if this script is used in any mission or
derivative works.

Average repair times (dependent on number of damaged hitpoints):
Min: ~60 secs (5 hitpoints) Max: ~2.50 mins (all hitpoints (~40 hp) - ie setdamage) excluding refuel and walk time overhead ~40secs

Execed on All machines except ded server
*/

params ["_pilot", "_hRepairer", "_veh", "_hweldingRod", "_hweldingCart"];

_light = objNull;

_hRepairer setBehaviour "CARELESS";

sleep (1 + random 4);

ROS_weldingSparks_Fnc = {
	params ["_hweldingRod", "_sparkpos"];
	_sparkPos = position _hweldingRod;
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
	_hweldingRod, // object
	0, // angle
	false, // surface
	0.25, // bounceOnSurface
	[[0,0,0,1]] // emissiveColor
	];

	_wSparks attachTo [_hweldingRod,[0.65,0,0]];
	_wSparks setDropInterval 0.001;
}; // end ROS_weldingSparks_Fnc

_y = 0;
_dist = 0.65;

_light = "#lightpoint" createVehicleLocal (getpos _hweldingRod);
_light setlightBrightness 0;
_light setlightColor [1.0, 1.0, 0.5];
_light attachto [_hweldingRod, [_dist, _y, 0]];

while {!ROSHeliRepaired} do {
	sleep 0.5;
	_smoke = "#particlesource" createVehicleLocal getpos _hweldingRod;
	_smoke attachto [_hweldingRod, [_dist, _y, 0]];
	_smoke setParticleClass "AvionicsSmoke";
	_smokepos = getpos _smoke;
	_sparkpos = [(_smokepos select 0), _smokepos select 1, (_smokepos select 2)+0.03];

	_light setlightBrightness 1;

	[_hweldingRod, _sparkpos] spawn ROS_weldingSparks_Fnc;

	_sparks1 = "#particlesource" createVehicleLocal _sparkpos;
	_sparks1 setParticleClass "AvionicsSparks";
	sleep 0.2;
	_sparks1 attachTo [_hweldingRod,[0.65,0,0]];

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

	_sfx = selectRandom ["welding1H", "welding2H"];
	[_hweldingCart, _pilot] say3d [_sfx, 100];

	if (ROSHeliRepaired) exitWith {
		deleteVehicle _light;
		deleteVehicle _hweldingCart;
		{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_hRepairer nearObjects 7);
	};

	sleep 10; // length of sfx

	_light setlightBrightness 0;
	{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_hRepairer nearObjects 7);

	// Intermittent break
	sleep (1 + random 2);
}; // end while

deleteVehicle _light;
deleteVehicle _hweldingCart;
{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_hRepairer nearObjects 7);

