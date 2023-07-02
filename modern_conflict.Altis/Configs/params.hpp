class Params {
	class cys_save_interval
	{
		title = "Server Auto Save (Does not do a Full Save, User Server Save & Exit)";
		texts[] = {"Disable Auto Save", "Every 1 Hour", "Every 2 Hours", "Every 3 Hours"};
		values[] = {-1, 3600, 7200, 10800};
		default = 10800;
	};
	class cys_Daytime
	{
		title = "Mission Start Time";
		texts[] = {"Use Saved Mission Time","Morning","Day","Evening","Night"};
		values[] = {-1,6,12,18,0};
		default = -1;
		//function = "BIS_fnc_paramDaytime";
	};
	class cys_timeMultiplier
	{
		title = "Time Acceleration";
		texts[] = {"24hr Day","12hr Day","6hr Day"};
		values[] = {1,2,4};
		default = 4;
		function = "BIS_fnc_paramTimeAcceleration";
	};

	
	class cys_SandStorm_max
	{
		title = "Maximum Number of Sand Storms per Day/Night Cycle (Time Acceleration Apply)";
		texts[] = {"None","1","2","3","4","5","6","7","8","9","10"};
		values[] = {0,1,2,3,4,5,6,7,8,9,10};
		default = 2;
		function = "BIS_fnc_paramTimeAcceleration";
	};

	class cys_playerCap_systems {
		title = "Player Cap Setting, if player server population goes above player cap that service is shut off";
		texts[] = {""};
		values[] = {1};
		default = 0;
	};
	class cys_brs_limit {
		title = "			Battlefield Respawn System";
		texts[] = {"Disabled","5 Players","10 Players", "15 Players", "20 Players", "No Player Cap"};
		values[] = {0,5,10,15,20,100};
		default = 15;
	};
	class cys_ai_recruitment {
		title = "			AI Recruitment";
		texts[] = {"Disabeld","5 Players","10 Players", "15 Players", "20 Players", "No Player Cap"};
		values[] = {0,5,10,15,20,100};
		default = 5;
	};

	class cys_enigma_systems {
		title = "Civilian Traffic System";
		texts[] = {"Disable", "Enable"};
		values[] = {0, 1};
		default = 1;
	};
	class cys_ambiant_civilian_driving {
		title = "			Ambiant Drivers Limit";
		texts[] = {"Disabeld","2","3","5","10","15","20"};
		values[] = {0,2,3,5,10,15,20};
		default = 10;
	};
	class cys_ambiant_enemy_driving {
		title = "Ambiant Enemy Drivers Limit";
		texts[] = {"Disabeld","1","2","3","5"};
		values[] = {0,1,2,3,5};
		default = 3;
	};
	class cys_traffic_headless 
	{
		title = "			Ambiant Drivers Headless Client (only use if HC1 is connected)";
		texts[] = {"Disabeld","Enabled";};
		values[] = {0,1};
		default = 1;
	};	
};