waitUntil {
	!isNil "ALiVE_SYS_DATA_SOURCE";
};

// Sets the mission autosave interval from lobby parameters
private _saveInterval = ["cys_save_interval", -1] call BIS_fnc_getParamValue;
if (ALiVE_SYS_DATA_SOURCE isEqualTo "pns") then {
	_saveInterval call ALiVE_fnc_AutoSave_PNS;
};

// Enable Group management from U key
["Initialize", [true]] call BIS_fnc_dynamicGroups; 

addMissionEventHandler ["HandleDisconnect",
{
	[(_this select 0)] spawn {
		sleep 5;
		deleteVehicle (_this select 0);
	};
}];