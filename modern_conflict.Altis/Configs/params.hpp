class Params {
	class cys_save_interval
	{
		title = "Server Auto Save";
		texts[] = {"Disable Auto Save", "Every 1 Hour", "Every 2 Hours", "Every 3 Hours"};
		values[] = {-1, 3600, 7200, 10800};
		default = 3600;
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
		texts[] = {"Normal 1:1","2x","4x"};
		values[] = {1,2,4};
		default = 1;
		function = "BIS_fnc_paramTimeAcceleration";
	};
	class cys_budget_group {
		title = "Budget System Settings";
		texts[] = {""};
		values[] = {1};
		default = 0;
	};
	class cys_budget_start {
		title = "			Initial Budget";
		texts[] = {"Used Saved Budget", "100","500","1000","5000","10000","50000"};
		values[] = {1,100,500,1000,5000,10000,50000};
		default = 1;
	};
	class cys_vechile_cost {
		title = "			Vehicle Cost";
		texts[] = {"100","200","300","400","500","1000"};
		values[] = {100,200,300,400,500,1000};
		default = 100;
	};
	class cys_vechile_refund_allowed {
		title = "			Allowed Vehicle Refund Worth";
		texts[] = {"100","200","300","400","500","1000"};
		values[] = {100,200,300,400,500,1000};
		default = 100;
	};
	class cys_vechile_refund_scrap {
		title = "			Scrap Vehicle Worth (Vehicles not in approved refund list)";
		texts[] = {"100","200","300","400","500","1000"};
		values[] = {100,200,300,400,500,1000};
		default = 100;
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
	// class cys_guilt_chance {
	// 	title = "Guilt & Remembrance Mission Probability";
	// 	texts[] = {"Disabeld","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"};
	// 	values[] = {0,10,20,30,40,50,60,70,80,90,100};
	// 	default = 30;
	// };
		class cys_ambiant_civilian_driving {
		title = "Ambiant Drivers Limit";
		texts[] = {"Disabeld","5","10","15","20"};
		values[] = {0,5,10,15,20};
		default = 10;
	};

	class cys_ambiant_enemy_driving {
		title = "Ambiant Enemy Drivers Limit";
		texts[] = {"Disabeld","3","5","10","15","20"};
		values[] = {0,3,5,10,15,20};
		default = 3;
	};

	
	class cys_traffic_headless {
		title = "Ambiant Drivers Headless Client (only use if HC1 is connected)";
		texts[] = {"Disabeld","Enabled";};
		values[] = {0,1};
		default = 0;
	};
	
};