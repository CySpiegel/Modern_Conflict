enableSaving [false,false];

/*
	Getting mission parameters for varius systems
*/
private _setDaytime = ["cys_Daytime", -1] call BIS_fnc_getParamValue;
if (_setDaytime > -1) then {
    _setDaytime call  BIS_fnc_paramDaytime;
};

private _cys_SandStorm_max = ["cys_Daytime", -1] call BIS_fnc_getParamValue;
if(_cys_SandStorm_max > 0) then 
{
    [0, _cys_SandStorm_max, 0] execvm "ROS_Sandstorm\scripts\ROS_Sandstorm_Scheduler.sqf";
};

// Get parameter for Civilian traffic enable/disable
private _enableTraffic = ["cys_enigma_systems", 0] call BIS_fnc_getParamValue;
if(_enableTraffic > 0) then{
    call compile preprocessFileLineNumbers "Engima\Traffic\Init.sqf";
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

if(isServer) then {
    // set the civilian types that will act as next-of-kin
    GR_CIV_TYPES = ["CFP_C_ME_Civ_1_01","CFP_C_ME_Civ_2_01"];

    // set the maximum distance from murder that next-of-kin will be spawned
    GR_MAX_KIN_DIST = 10000;

    // Chance that a player murdering a civilian will get an "apology" mission
    GR_MISSION_CHANCE = 20;

    // Delay in seconds after death until player is notified of body delivery mission
    GR_TASK_MIN_DELAY=10;
    GR_TASK_MID_DELAY=10;
    GR_TASK_MAX_DELAY=10;

    // Set custom faction names to determine blame when performing an autopsy
    GR_FACTIONNAME_EAST = "ISIS";
    GR_FACTIONNAME_WEST = "NATO";
    //GR_FACTIONNAME_IND = "CFP_I_IS";
    GR_FACTIONNAME_IND = "ISIS";

    // You can also add/remove custom event handlers to be called upon
    // certain events.

    // // On civilian murder by player:
    // [yourCustomEvent_OnCivDeath] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed, _nextofkin]
    // // (NOTE: _nextofkin will be nil if a body delivery mission wasn't generated.)
    // [yourCustomEvent_OnCivDeath] call GR_fnc_removeCivDeathEventHandler;

    // // On body delivery:
    // [yourCustomEvent_OnDeliverBody] call GR_fnc_addDeliverBodyEventHandler; // args [_killer, _nextofkin, _body]
    // [yourCustomEvent_OnDeliverBody] call GR_fnc_removeDeliverBodyEventHandler;

    // // On successful concealment of a death:
    // [yourCustomEvent_OnConcealDeath] call GR_fnc_addConcealDeathEventHandler; // args [_killer, _nextofkin, _grave]
    // [yourCustomEvent_OnConcealDeath] call GR_fnc_removeConcealDeathEventHandler;

    // // On reveal of a concealed death via autopsy:
    // [yourCustomEvent_OnRevealDeath] call GR_fnc_addRevealDeathEventHandler; // args [_medic, _body, _killerSide]
    // [yourCustomEvent_OnRevealDeath] call GR_fnc_removeRevealDeathEventHandler;

    // NOTE: if your event handler uses _nextofkin or _body, make sure to turn off garbage collection with:
    // _nextofkin setVariable ["GR_WILLDELETE",false];
    //_body setVariable ["GR_WILLDELETE",false];
		
	[{
		params["_killer", "_killed", "_nextofkin"];
		// protect the body
		_killed setVariable ["ALiVE_SYS_GC_IGNORE",true];
		// protects the AI next-of-kin
		_nextofkin setVariable ["ALiVE_SYS_GC_IGNORE",true];
	}] call GR_fnc_addCivDeathEventHandler;

	[{
		params["_killer", "_nextofkin", "_grave"];
		// protect the grave
		_grave setVariable ["ALiVE_SYS_GC_IGNORE",true];
		// protect the AI next-of-kin
		_nextofkin setVariable ["ALiVE_SYS_GC_IGNORE",true];
	}] call GR_fnc_addConcealDeathEventHandler;
};

["ALiVE | Enduring Freedom - Executing init.sqf..."] call ALiVE_fnc_Dump;