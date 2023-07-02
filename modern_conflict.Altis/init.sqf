enableSaving [false,false];



// Sets the mission start time from the in game parameters
private _setDaytime = ["cys_Daytime", -1] call BIS_fnc_getParamValue;
if (_setDaytime > -1) then {
    _setDaytime call  BIS_fnc_paramDaytime;
};

// If SandStorms are set then execute sandstorm systems
if(_cys_SandStorm_max > 0) then 
{
    [0, _cys_SandStorm_max, 0] execvm "ROS_Sandstorm\scripts\ROS_Sandstorm_Scheduler.sqf";
};

// Start Task Removal System for custom missions
call compile preprocessFileLineNumbers "Tasking\removeTasks.sqf";


//Disable Vcom on vehicles
//[{{Driver _x setvariable ["NOAI",true];} foreach (vehicles select {_x isKindOf 'air'});}, 1, []] call CBA_fnc_addPerFrameHandler;

// Compiles the function for showing server FPS on in game map
if (isServer) then {
    [] call compileFinal preprocessFileLineNumbers "Scripts\server\init_server.sqf";
};

// Make AI Regroup with player upon reconnecting to server and teleport back to there location
waituntil {(player getvariable ["alive_sys_player_playerloaded",false])};
sleep 2;
{
	if !(isPlayer _x) then {
		if !(_x getVariable ["Persistent_Teleport", false]) then {
			_x setPos (getPos player);
			_x setVariable ["Persistent_Teleport", true, true];
			sleep .5;
		};
	};
} forEach units group player;