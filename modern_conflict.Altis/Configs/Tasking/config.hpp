	class Default
	{
		title = ""; // Tile displayed as text on black background. Filled by arguments.
		iconPicture = ""; // Small icon displayed in left part. Colored by "color", filled by arguments.
		iconText = ""; // Short text displayed over the icon. Colored by "color", filled by arguments.
		description = ""; // Brief description displayed as structured text. Colored by "color", filled by arguments.
		color[] = {1,1,1,1}; // Icon and text color
		duration = 5; // How many seconds will the notification be displayed
		priority = 0; // Priority; higher number = more important; tasks in queue are selected by priority
		difficulty[] = {}; // Required difficulty settings. All listed difficulties has to be enabled
	};
	class TaskAssigned
	{
		title = "TASK ASSIGNED";
		iconPicture = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
		description = "%2";
		color[] = {1,1,1,1};
		priority = 4;
	};
	class TaskSucceeded
	{
		title = "TASK SUCCEEDED";
		iconPicture = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
		description = "%2";
		color[] = {0.6,0.8,0.4,1};
		priority = 3;
	};
	class TaskFailed
	{
		title = "TASK FAILED";
		iconPicture = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
		description = "%2";
		color[] = {1,0.1,0,1};
		priority = 2;
	};
	class TaskCanceled
	{
		title = "TASK CANCELED";
		iconPicture = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
		description = "%2";
		color[] = {0.75,0.75,0.75,1};
		priority = 1;
	};
	class TaskCreated
	{
		title = "TASK CREATED";
		iconPicture = "\A3\ui_f\data\map\mapcontrol\taskIcon_ca.paa";
		description = "%2";
		color[] = {1,1,1,1};
		priority = 5;
	};