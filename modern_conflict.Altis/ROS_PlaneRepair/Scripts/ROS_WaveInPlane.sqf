/*
This script is part of ROS_PlaneRepair - by RickOshay

LEGAL STUFF
Credit must be given in your mission and on the Steam Workshop if this script is used in any mission or
derivative works.

See ROS_PlaneRepair.sqf script header for more details.
[_marshall, _helipad] execvm "ROS_PlaneRepair\scripts\ROS_waveinPlane.sqf";
*/

params ["_marshall", "_helipad"];

if !(local _marshall) exitWith {};

_maxHPvalue = 0;
_vehDamage = 0;
_vehFuel = 0;

_clLH = objNull;
_clRH = objNull;
_wiLightsAdded = false;
_waveOutP = false;

_marshall setdir (_marshall getDir _helipad);

_nearestPlane = objNull;
_nearestPlanes = [];

_marshall setUnitPos "up";
_marshall setBehaviour "careless";
_pwep = primaryWeapon _marshall;
_marshall removeWeapon _pwep;
_marshall setBehaviour "careless";
_marshall disableaI "move";
_marshall disableAI "anim";
[_marshall, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];
[_marshall, false] remoteExec ["allowDamage",0];

// Place red light on vest
_c1 = "Chemlight_red" createVehicle [0,0,0];
_c1 attachTo [_marshall, [0,0,1]];

// Place white light in front
_lightw = "#lightpoint" createVehicleLocal [0,0,0];
_lightw setLightBrightness 0.1;
_lightw setLightColor[1, 1, 1];
_lightw lightAttachObject [_marshall, [0,0.7,0.7]];

ROS_addlights_Fnc = {
	params ["_marshall"];
	if (!_wiLightsAdded) then {
		// Add red chemlights to hands
		_clLH = "Chemlight_red" createVehicle [0,0,0];
		_clRH = "Chemlight_red" createVehicle [0,0,0];
		_clLH attachTo [_marshall, [0,-0.01,0.08], "Lefthand"];
		_clRH attachTo [_marshall, [-0.03,-0.01,0.04], "Righthand"];
		_clLH setVectorDirAndUp [[0,0,-1],[0,1,0]];
		_clRH setVectorDirAndUp [[0,0,-1],[0,1,0]];
		_wiLightsAdded = true;
	};

	true
};

while {true} do {
	// Look for planes nearby and wave them in
	_nearestPlanes = (nearestObjects [_marshall,["plane"],100]) select {isplayer driver _x};
	if (count _nearestPlanes >0) then {
		_nearestPlane = _nearestPlanes select 0;
	} else {
		_nearestPlane == objNull;
	};

	if (!isnull _nearestPlane) then {

		if (isTouchingGround _nearestPlane && _nearestPlane distance _marshall <= 100) then {
			// Wave In
			if (_nearestPlane distance _helipad > 4) then {
				_waveOutP = false;
			} else {
				_waveOutP = true;
			};

			// Wave In
			if !(_waveOutP) then {
				if (_nearestPlane distance _helipad > 4 && [position _nearestPlane, getDir _nearestPlane, 30, position _helipad] call BIS_fnc_inAngleSector) then {
					[_marshall] call ROS_addlights_Fnc;
					_marshall setdir (_marshall getdir _nearestPlane);
					[_marshall, "Acts_JetsMarshallingStraight_loop"] remoteExec ["switchMove", 0];
					sleep 2;
				};
			} else {
				// Wave Out
				[_marshall, "Acts_NavigatingChopper_out"] remoteExec ["switchMove", 0];
				sleep 5;
				_marshall doWatch _nearestPlane;
				// Remove hand attached red chemlights
				_nearestClights = nearestObjects [_marshall,["Chemlight_red"],2];
				if (count _nearestClights >0) then {{deleteVehicle _x} foreach _nearestClights};
				ROS_WiLightsAdded = false;
				[_marshall, ""] remoteExec ["switchMove", 0];

				waitUntil {_nearestPlane distance _helipad > 10};
			};
		};
	};

	_marshall setdir (_marshall getdir _helipad);

	sleep 2;
}; // END while
