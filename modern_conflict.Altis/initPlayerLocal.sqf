// --- Enable full spectator in respawn screen
{
	missionNamespace setVariable [_x, true];
} forEach [
	"BIS_respSpecAI",					// Allow spectating of AI
	"BIS_respSpecAllowFreeCamera",		// Allow moving the camera independent from units (players)
	"BIS_respSpecAllow3PPCamera",		// Allow 3rd person camera
	"BIS_respSpecShowFocus",			// Show info about the selected unit (dissapears behind the respawn UI)
	"BIS_respSpecShowCameraButtons",	// Show buttons for switching between free camera, 1st and 3rd person view (partially overlayed by respawn UI)
	"BIS_respSpecShowControlsHelper",	// Show the controls tutorial box
	"BIS_respSpecShowHeader",			// Top bar of the spectator UI including mission time
	"BIS_respSpecLists"					// Show list of available units and locations on the left hand side
];


// Respawn with loadout at time of death
player addEventHandler ["Killed", { player setVariable ["TAG_DeathLoadout", getUnitLoadout player]; }];
player addEventHandler ["Respawn", 
{ 
	private _loadout = player getVariable "TAG_DeathLoadout"; 
	if (!isNil "_loadout") then { 
		player setUnitLoadout _loadout; 
	}; 
}];