/*

ROS Plane repair v2.0 - by RickOShay

Supports all planes in Arma 3 / DLCs / RHS / SOG
Plane must have hitpoints - most CUP planes are therefore not supported.

LEGAL STUFF
Credit must be given in your mission and on the Steam Workshop if this system and scripts or part therof is used in any mission or
derivative works.

USAGE:
Only one Plane repair bay in a mission is supported at present.
Copy the ROS_PlaneRepair folder and CFgSounds entries in description.ext. See sample files in demo.

ADD A HELIPAD:
In the editor drop down a square helipad ("Land_HelipadSquare_F") where the plane will be repaired.
Make sure its direction points in the direction the plane will be parked when being repaired. (the helipad will be hidden when the mission starts).

HELIPAD INIT FIELD:
Place the following line in the helipad's init field:
[this] execvm "ROS_PlaneRepair\scripts\ROS_PlaneRepair.sqf";

Keep the position 15m directly in front of the helipad clear.
Keep the position 20m to the RHS of the helipad clear.

The repairer, mechanic and fuel assets (refueler and truck) will be spawned in to the above areas.

Example
			 Keep clear
		spawned in 👨 marshall
			   ↑ ~17m

               					   Keep area clear
               □ helipad center  → 17m (auto spawned 👨 repairer, 👨 mechanic, ⛟ fuel truck, 👨 refueler, and fuel pipes)

               ↑
               🛧 inbound plane

Copy the ROS_PlaneRepair folder to your mission root.
Add the sound classes from the provided description.ext to Cfg_Sound in your description.ext.

Hide helipad */
_hideHelipad = true;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// DO NOT MAKE CHANGES BELOW THIS LINE //////////////////////////////////////////////// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if !(isServer) exitWith {};

params ["_helipad"];

//hint format ["PAD: %1", _helipad]; sleep 3; // ******* remove

_fptruck = objNull;
_wplight = objNull;
_goodDay = false;
_cta = false;
_nWeldingRod = objnull;
_nWeldingCart = objNull;
ROSPlaneRepaired = false;
ROSPlaneRefueled = false;
_repaircase1 = objNull;
_plane = objNull;
_planeDamage = 0;
_planeFuel = 0;
_vehType = "";
_firstposWeld = [0,0,0];
_weldPosp = [0,0,0];
_hpadPos = getPosATL _helipad;
_hPadDir = getdir _helipad;
_ymPositions = [];
_targetMarker = objNull;
ROS_taxiAdded = false;

_helipad allowDamage false;

/*
// Create Marshall
_marshall = createAgent ["B_engineer_F", [0,0,0], [], 0, "NONE"];
// Load Marshall loadout
[_marshall] execvm "ROS_PlaneRepair\scripts\ROS_PwaveinLoadout.sqf";

// Position Marshall 15m ahead of the helipad and set Marshall direction
_marshall setPosATL (_helipad modeltoworld [0,17,0]);
_marshall setDir (_hPadDir -180);
[_marshall, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];

// Start wavein
[_marshall, _helipad] execvm "ROS_PlaneRepair\scripts\ROS_waveinPlane.sqf";
*/
// Create Welder
_grp1 = createGroup west;
_pWelder = _grp1 createUnit ["B_soldier_repair_F", [0,0,0], [], 0, "FORM"];
// Load Welder loadout
[_pWelder] execvm "ROS_PlaneRepair\scripts\ROS_pWelderLoadout.sqf";

// Position the welder 25m to the RHS of the helipad just above the fuel truck
_weldPos = _helipad modeltoworld [17,6,0];
_pWelder setBehaviour "careless";
_pWelder allowDamage false;
_pWelder setPosATL _weldPos;
_dir = (_pWelder getdir _helipad) +5;
_pWelder setdir _dir;
_pWelder doWatch position _helipad;
_initPosW = getPosATL _pWelder;
_pWelder setVariable ["repPos", _initPosW, true];
_pWelder setVariable ["repDir", _dir, true];

// Create Mechanic
_grp2 = createGroup west;
_pMechanic = _grp2 createUnit ["B_soldier_repair_F", [0,0,0], [], 0, "FORM"];
// Load Mechanic loadout
[_pMechanic] execvm "ROS_PlaneRepair\scripts\ROS_pMechanicLoadout.sqf";

_pMechanic setPosATL (_pWelder modeltoworld [-4,3,0]);
_pMechanic setDir _dir;
_pMechanic doWatch position _helipad;
_initPosM = getPosATL _pMechanic;
_pMechanic setVariable ["mechPos", _initPosM, true];
_pMechanic setVariable ["mechDir", _dir, true];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Hide helipad and create parking yellow target at helipad
if (_hideHelipad) then {
	hideObjectGlobal _helipad;
	_targetMarker = createVehicle ["VR_Area_01_circle_4_grey_F", _hpadPos];
	_targetMarker setdir _hPadDir;
	_targetMarker setObjectTextureGlobal [0, "#(rgb,8,8,3)color(1,0.5,0,1)"];
	_targetMarker enableSimulationGlobal false;
	_targetMarker attachTo [_helipad,[0,0,0]];
};

// Create center yellow arrow markerss
_ymRelPositions = [[0,-28.5,-0.058],[0,-25.5,-0.058],[0,-22.5,-0.058],[0,-19.5,-0.058],[0,-16.5,-0.058],[0,-13.5,-0.058],[0,-10.5,-0.058], [0,-8.5,-0.058],[0,-5.5,-0.058]];
{_pos = _helipad modeltoworld _x; _ymPositions pushBack _pos} foreach _ymRelPositions;
{
	_obj = createVehicle ["Sign_Arrow_Direction_Yellow_F", _x, [], 0, "can_collide"];
	_obj setdir (_obj getdir _helipad);
} foreach _ymPositions;

// Hide yellow arrows and ytarget
_yarrows =  _helipad nearobjects ["Sign_Arrow_Direction_Yellow_F",30];
{_x hideObjectGlobal true} foreach _yarrows;
_targetMarker hideObjectGlobal true;

// Red light center helipad
_planePadlamp = "PortableHelipadLight_01_red_F" createVehicle [0,0,0];
_planePadlamp setPosATL (_helipad modeltoworld [0,0,-0.17]);
_planePadlamp enableSimulationGlobal false;
_planePadlamp setdir (getdir _helipad);

// Oil spill on helipad
_oil1 = "Oil_Spill_F" createVehicle [0,0,0];
_oil1 setpos (_helipad modeltoworld [0,-1.5,0]);

// Place red light on vest
_r1 = "Chemlight_red" createVehicle [0,0,0];
_r1 attachTo [_pWelder, [0,0.1,0], "Spine3"];

// Add Rotating Orange light on all clients
[[_planePadlamp],"ROS_PlaneRepair\scripts\ROS_pOlight.sqf"] remoteExec ["execVM", 0];

// Set rotating beacon state OFF
ROS_rotatingBeacon = false;

sleep 1;

_hitpartType = ["#c svetlo","#cabin_light","#cabin_light1","#cabin_light2","#cabin_light3","#cam_gunner","#cargo_light_1","#cargo_light_2","#cargo_light_3","#cargo_light_4","#gear_1_light_1_hit","#gear_1_light_2_hit","#gear_2_light_1_hit","#gear_3_light_1_hit","#gear_3_light_2_hit","#gear_f_lights","#glass11","#hitlight1","#hitlight2","#hitlight3","#l svetlo","#l2 svetlo","#light_1","#light_1_hit","#light_1_hitpoint","#light_2","#light_2_hit","#light_2_hitpoint","#light_3_hit","#light_4_hit","#light_f","#light_fg125","#light_g","#light_hd_1","#light_hd_2","#light_hitpoint","#light_l","#light_l_flare","#light_l_hitpoint","#light_l2","#light_l2_flare","#light_r","#light_r_flare","#light_r_hitpoint","#light_r2","#light_r2_flare","#p svetlo","#p2 svetlo","#reverse_light_hit","#rl_nav_illum","#rl_op_red_illum","#rl_op_teal_illum","#rl_remspot_illum","#searchlight","#svetlo","#t svetlo","#wing_left_light","#wing_right_light","armor_composite_65","glass_pod_01_hitpoint","hit_ammo","hit_optic_crows_day","hit_optic_driver","hit_optic_sosnau","hitatgmsight","hitbody","hitduke1","hitengine","hitfuel","hitfuel_l","hitfueltank_left","hitglass1","hithrotor","hithull","hithull_structural","hitlfwheel","hitvrotor","hitwindshield_1","armor_composite_40","armor_composite_50","armor_composite_60","armor_composite_70","armor_composite_75","armor_composite_80","armor_composite_85","armor_composite_95","glass_1_hitpoint","glass_10_hitpoint","glass_11_hitpoint","glass_12_hitpoint","glass_13_hitpoint","glass_14_hitpoint","glass_15_hitpoint","glass_16_hitpoint","glass_17_hitpoint","glass_18_hitpoint","glass_19_hitpoint","glass_2_hitpoint","glass_20_hitpoint","glass_3_hitpoint","glass_4_hitpoint","glass_5_hitpoint","glass_6_hitpoint","glass_7_hitpoint","glass_8_hitpoint","glass_9_hitpoint","glass_pod_02_hitpoint","glass_pod_03_hitpoint","glass_pod_04_hitpoint","glass_pod_05_hitpoint","glass_pod_06_hitpoint","hit_ammo","hit_gps_headmirror","hit_gps_optical","hit_gps_tis","hit_light_l","hit_light_r","hit_lightl","hit_lightr","hit_longbow","hit_optic_1g46","hit_optic_1k13","hit_optic_1k13","hit_optic_9s475","hit_optic_citv","hit_optic_comcwss","hit_optic_comm2","hit_optic_comperiscope","hit_optic_comperiscope1","hit_optic_comperiscope2","hit_optic_comperiscope3","hit_optic_comperiscope4","hit_optic_comperiscope5","hit_optic_comperiscope6","hit_optic_comperiscope7","hit_optic_comsight","hit_optic_crows_day","hit_optic_crows_day","hit_optic_crows_lrf","hit_optic_crows_ti","hit_optic_driver","hit_optic_driver_rear","hit_optic_driver1","hit_optic_driver2","hit_optic_driver3","hit_optic_dvea","hit_optic_essa","hit_optic_gps","hit_optic_gps_ti","hit_optic_loaderperiscope","hit_optic_mainsight","hit_optic_nsvt","hit_optic_periscope","hit_optic_periscope1","hit_optic_periscope2","hit_optic_periscope3","hit_optic_periscope4","hit_optic_pnvs","hit_optic_sosnau","hit_optic_tads","hit_optic_tkn3","hit_optic_tkn3","hit_optic_tkn4s","hit_optic_tpd1k","hit_optic_tpn4","hit_optics_cdr_civ","hit_optics_cdr_peri","hit_optics_dvr_dve","hit_optics_dvr_peri","hit_optics_dvr_rearcam","hit_optics_gnr","hitaasight","hitammo","hitammohull","hitavionics","hitbattery_l","hitbattery_r","hitbody","hitcomgun","hitcomsight","hitcomturret","hitcontrolrear","hitdoor_1_1","hitdoor_1_2","hitdoor_2_1","hitdoor_2_2","hitduke1","hitduke2","hitengine","hitengine_1","hitengine_2","hitengine_3","hitengine_4","hitengine_c","hitengine_l1","hitengine_l2","hitengine_r1","hitengine_r2","hitengine1","hitengine2","hitengine3","hitengine4","hitfuel","hitfuel_l","hitfuel_lead_left","hitfuel_lead_right","hitfuel_left","hitfuel_left_wing","hitfuel_r","hitfuel_right","hitfuel_right_wing","hitfuel2","hitfuell","hitfuelr","hitfueltank","hitfueltank_left","hitfueltank_right","hitgear","hitglass1","hitglass10","hitglass11","hitglass12","hitglass13","hitglass14","hitglass15","hitglass16","hitglass17","hitglass18","hitglass19","hitglass1a","hitglass1b","hitglass2","hitglass20","hitglass21","hitglass3","hitglass4","hitglass5","hitglass6","hitglass7","hitglass8","hitglass9","hitgun","hitgun1","hitgun2","hitgun3","hitgun4","hitguncom","hitguncomm2","hitgunlauncher","hitgunloader","hitgunnsvt","hithood","hithrotor","hithstabilizerl1","hithull","hithull_structural","hithydraulics","hitlaileron","hitlaileron_link","hitlauncher","hitlbwheel","hitlcelevator","hitlcrudder","hitlf2wheel","hitlfwheel","hitlglass","hitlight","hitlightback","hitlightfront","hitlightl","hitlightr","hitlmwheel","hitlrf2wheel","hitltrack","hitmainsight","hitmissiles","hitperiscope1","hitperiscope10","hitperiscope11","hitperiscope12","hitperiscope13","hitperiscope14","hitperiscope2","hitperiscope3","hitperiscope4","hitperiscope5","hitperiscope6","hitperiscope7","hitperiscope8","hitperiscope9","hitperiscopecom1","hitperiscopecom2","hitperiscopegun1","hitperiscopegun2","hitperiscopegun3","hitperiscopegun4","hitpylon1","hitpylon10","hitpylon11","hitpylon2","hitpylon3","hitpylon4","hitpylon5","hitpylon6","hitpylon7","hitpylon8","hitpylon9","hitraileron","hitraileron_link","hitrbwheel","hitrelevator","hitreservewheel","hitrf2wheel","hitrfwheel","hitrglass","hitrightrudder","hitrmwheel","hitrotor","hitrotor1","hitrotor2","hitrotor3","hitrotor4","hitrotor5","hitrotor6","hitrotorvirtual","hitrrudder","hitrtrack","hitsearchlight","hitspare","hitstarter1","hitstarter2","hitstarter3","hittail","hittransmission","hitturret","hitturret1","hitturret2","hitturret3","hitturret4","hitturretcom","hitturretcomm2","hitturretlauncher","hitturretloader","hitturretnsvt","hitvrotor","hitvstabilizer1","hitwinch","hitwindshield_2","ind_hydr_l","ind_hydr_r","indicatoreng1","indicatoreng2","indicatoroil1","indicatoroil2","usespare","warningaileron","warningelevator"];

_hitpartText = ["Light","Cabin Light","Cabin Light","Cabin Light","Cabin Light","Cam Gunner","Cargo Light","Cargo Light","Cargo Light","Cargo Light","Gear Light","Gear Light","Gear Light","Gear Light","Gear Light","Gear Light","Glass","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Searchlight","Light","Light","Light","Light","Armor","Glass","Ammo","Optics","Optics","Optics","Sight","Body","Duke","Engine Part","Fuel","Fuel","Fuel","Glass","Rotor","Hull","Hull","Wheel","Rotor","Windshield","Armor","Armor","Armor","Armor","Armor","Armor","Armor","Armor","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Ammo","Mirror","GPS","GPS","Light","Light","Light","Light","Longbow","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Sight","Ammo","Ammo","Avionics","Battery","Battery","Body","Gun","Sight","Turret","Control","Door","Door","Door","Door","Duke","Duke","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel Tank","Fuel Tank","Fuel Tank","Gear","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Hood","Rotor","Stabilizer","Hull","Hull","Hydraulics","Aileron","Aileron","Launcher","Wheel","Elevator","Rudder","Wheel","Wheel","Glass","Light","Light","Light","Light","Light","Wheel","Wheel","Track","Sight","Missiles","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Aileron","Aileron","Wheel","Elevator","Wheel","Wheel","Wheel","Glass","Rudder","Wheel","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rudder","Track","Searchlight","Spare","Starter","Starter","Starter","Tail","Transmission","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Rotor","Stabilizer","Winch","Windshield","Hydraulics","Hydraulics","Indicator Engine","Indicator Engine","Indicator Oil","Indicator Oil","Spare","Aileron","Elevator"];

_dir = getDir _pWelder;
_fptruckpos = _helipad modeltoworld [21.8721,-1.82813,0];
_fptruck = createvehicle ["C_Van_01_fuel_F", _fptruckpos, [], 0, "CAN_COLLIDE"];
_fptruck setpos _fptruckpos;
_fptruck setdir (_fptruck getdir _helipad)-180;
_fptruck setposatl (getpos _fptruck);
_fptruck enableSimulationGlobal false;

// White spotlight rear of Ftruck
_wplight = "Reflector_Cone_01_narrow_white_F" createVehicle [0,0,0];
_wplight setpos (_fptruck modelToWorld [-0.1,-3.48,0.855]);
_wplight setdir (_wplight getdir _helipad);
_wplight hideObjectGlobal true;

sleep 1;
_refueler = "B_engineer_F" createvehicle [0,0,0];
_refueler setpos (_fptruck modeltoworld [2.5,-2.5,-1.7]);
_refueler setdir (_refueler getdir _helipad);
[_refueler, "Acts_CivilIdle_1"] remoteExec ["switchMove", _refueler];

// Place white light in front or refueler
_lightp = "#lightpoint" createVehicleLocal [0,0,0];
_lightp setLightBrightness 0.1;
_lightp setLightColor[1, 1, 1];
_lightp lightAttachObject [_refueler, [0,0.7,0.7]];

removeAllWeapons _refueler;
removeAllItems _refueler;
removeAllAssignedItems _refueler;
removeVest _refueler;
removeBackpack _refueler;
removeHeadgear _refueler;
_refueler addVest "V_DeckCrew_violet_F";
_refueler addHeadgear "H_MilCap_gry";
_refueler disableAI "move";
_refueler setBehaviour "careless";


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// FUNCTIONS ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Hide or Show yellow arrows and target
ROS_HideYmarkers_fnc = {
	params ["_helipad", "_state"];
	//_yarrows =  _helipad nearobjects ["Sign_Arrow_Direction_Yellow_F",30];
	_yarrows = nearestObjects [(getPosATL _helipad), ["Sign_Arrow_Direction_Yellow_F"], 30, true];
	reverse _yarrows;
	{_x hideObjectGlobal _state; sleep 0.5;} foreach _yarrows;
	_targetMarker hideObjectGlobal _state;
};

// Create fuel pipes
ROS_PlaneFuelPipes_Fnc = {
	params ["_plane"];
	PhoseV = createVehicle ["LayFlatHose_01_StraightShort_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose0 = createVehicle ["LayFlatHose_01_CurveShort_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose1 = createvehicle ["LayFlatHose_01_CurveLong_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose2 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose3 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose4 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Phose5 = createVehicle ["LayFlatHose_01_CurveShort_F", [0,0,0], [], 0, "CAN_COLLIDE"];

	Phose2 attachto [Phose1,[-0.55,-5,0]];
	Phose3 attachto [Phose2,[0.86,-5,0]];
	Phose4 attachto [Phose3,[0.86,-5,0]];
	Phose1 setdir (getdir _fptruck +180);
	Phose5 attachto [Phose4,[0.43,-3.1,0.47]];
	Phose5 setdir (getdir Phose4-140);
	Phose5 setvectorup [1,0,0];
	Phose0 attachto [Phose1,[1.4,2.9,0.47]];
	Phose0 setvectorUp [-0.5,0.5,0];
	Phose0 setvectorDir [0.149259,0.988798,0];
	if (!(typeof _plane find "I_C_Plane_Civil_01" >-1) or (typeof _plane find "C_Plane_Civil_01_F" >-1)) then {
		PhoseV attachto [Phose0,[1,0.63,0]];
		PhoseV setvectordirandup [[1,0,0],[1,1,0]];
	};
};

// Rotate plane
ROS_RotatePlane_Fnc = {
	params ["_plane", "_helipad"];

	["Rotating ..."] remoteexec ["hint", driver _plane];
	[_plane, false] remoteExec ["engineOn", _plane];
	_plane setPosATL (getPosATL _plane);
	[_plane, false] remoteExec ["allowDamage", _plane];
	_sdir = getdir _plane;
	_edir = (getdir _plane +180);
	for "_i" from _sdir to _edir step 0.5 do {
		_plane setdir _i;
		sleep 0.01;
	};
	sleep 1;
	[_plane, true] remoteExec ["allowDamage", _plane];
	[""] remoteexec ["hint", driver _plane];
	// Engine on
	[_plane, true] remoteExec ["engineOn", _plane];
	waitUntil {_plane distance2D _helipad >20};
};


////// ROS PLANE REPAIR FUNCTION //////
ROS_Repair_plane_fnc = {
	params ["_pWelder", "_plane", "_pilot", "_hitpartType", "_hitpartText", "_helipad", "_fptruck", "_wplight"];

	_rdist = 0;
	_hitpartDesc = "";
	_allHPvalues = [];
	_pweldingrod = objnull;
	_pweldingCart = objNull;
	_repaircase1 = objNull;

	// Switch on rotating orange pad light
	ROS_rotatingBeacon = true;

	// Clear aligning hint
	[""] remoteExec ["hint", _pilot];

	// Create Repaircases
	_repaircase1 = "Land_PlasticCase_01_small_F" createVehicle (getPosATL _pWelder);
	_repaircase1 enableSimulationGlobal false;
	_repaircase1 setposatl (_pWelder modelToWorld [0.5,-0.2,-0.5]);
	_repaircase1 setdir (getdir _pWelder +10);

	// Create Repaircases
	_repaircase2 = "Land_PlasticCase_01_small_F" createVehicle (getPosATL _pMechanic);
	_repaircase2 enableSimulationGlobal false;
	_repaircase2 setposatl (_pMechanic modelToWorld [0.5,-0.2,-0.5]);
	_repaircase2 setdir (getdir _pMechanic +10);

	// Lock Vehicle
	if (isPlayer _pilot && !(vehicle _pilot == _pilot)) then {[_plane, true] remoteExec ["lock", _plane]};

	_pWelder setBehaviour "careless";
	_pWelder setspeedMode "limited";
	_pWelder allowFleeing 0;
	_pWelder allowDamage false;
	_pWelder doWatch position _helipad;

	// [hitpointsNamesArray, selectionsNamesArray, damageValuesArray]
	_allHPnames = ((getAllHitPointsDamage _plane) select 0);
	_allHPvalues = ((getAllHitPointsDamage _plane) select 2);
	_numDamHP = {_x >0} count _allHPvalues;

	sleep 1;

	[""] remoteExec ["hint", _pilot];

	// Attach repair case to repairers
	_repaircase1 setdir (getdir _pWelder -5);
	_repaircase1 attachto [_pWelder,[0.01,-0.06,-0.21],"RightHandMiddle1"];

	_repaircase2 setdir (getdir _pMechanic -5);
	_repaircase2 attachto [_pMechanic,[0.01,-0.06,-0.21],"RightHandMiddle1"];

	// Get approx size of bb
	_bbr = 0 boundingBoxReal _plane;
	_ba1 = _bbr select 0;
	_ba2 = _bbr select 1;
	_bsd = _bbr select 2; // sphere diameter
	_maxW = abs ((_ba2 select 0) - (_ba1 select 0));
	_maxL = abs ((_ba2 select 1) - (_ba1 select 1));

	if (_maxL > _maxW) then {_maxW = _maxL};

	_weldPosp = [0,0,0];
	_mechPosp = [0,0,0];
	_xoffSet = 0;

	// Create moveto positions
	//_firstposWeld = _plane getPos [_maxW-3, (getdir _plane)+70];
	//_firstposMech = _plane getPos [_maxW-3, (getdir _plane)+80];
	_firstposWeld = getPosATL _pWelder;
	_firstposMech = getPosATL _pMechanic;

	// A3 / RHS / FIR / SOG (CUP planes without HP are not supported)
	if ("B_Plane_CAS_01" in typeof _plane) then {_xoffSet =2.2;};
	if ("B_Plane_Fighter_01" in typeof _plane) then {_xoffSet =2.1;};
	if ("A10" in typeof _plane) then {_xoffSet =2.2;};
	if ("F22" in typeof _plane or "F23A" in typeof _plane or "F35" in typeof _plane or "F14" in typeof _plane or "F15" in typeof _plane or "F16" in typeof _plane or "F18" in typeof _plane or "FA18" in typeof _plane or "SU34" in typeof _plane or "FIR_AV8B" in typeof _plane or "JAS39" in typeof _plane) then {
		_xoffSet =1.85;
		//_firstposWeld = _plane getPos [10, (getdir _plane)+70];
		//_firstposMech = _plane getPos [10, (getdir _plane)+100];
	};
	if ("Su25" in typeof _plane) then {
		_xoffSet =2; xoffset = _xoffSet; //remove
		//_firstposWeld = _plane getPos [10, (getdir _plane)+70];
		//_firstposMech = _plane getPos [10, (getdir _plane)+100];
	};
	if ("F2A" in typeof _plane) then {
		_xoffSet =2;
		//_firstposWeld = _plane getPos [8, (getdir _plane)+70];
		//_firstposMech = _plane getPos [8, (getdir _plane)+100];
	};
	if ("AN2" in typeof _plane) then {
		_xoffSet = 2.5;
		//_firstposWeld = _plane getPos [9, (getdir _plane)+70];
		//_firstposMech = _plane getPos [9, (getdir _plane)+100];
	};
	if ("vn_b_air_f4b" in typeof _plane) then {_xoffSet =2.4;};
	if ("vn_b_air_f4c" in typeof _plane) then {_xoffSet =2;};
	if ("O_Plane_CAS_02" in typeof _plane) then {_xoffSet =2;};
	if ("O_Plane_Fighter" in typeof _plane) then {_xoffSet =2.1;};
	if ("O_T_VTOL_02" in typeof _plane) then {_xoffSet =2.5;};
	if ("I_Plane_Fighter_03" in typeof _plane) then {_xoffSet =2;};
	if ("I_Plane_Fighter_04" in typeof _plane) then {_xoffSet =2;};
	if ("I_C_Plane_Civil_01" in typeof _plane) then {_xoffSet =2.2;};
	if ("C_Plane_Civil" in typeof _plane or "I_Plane_ION" in typeOf _plane or "C_Plane_Orbit" in typeOf _plane) then {_xoffSet = 2.2;};
	if ("C130J" in typeof _plane) then {
		_xoffSet =3.5;
		//_firstposWeld = _plane getPos [18, (getdir _plane)+70];
		//_firstposMech = _plane getPos [18, (getdir _plane)+100];
	};
	if ("B_T_VTOL_01" in typeof _plane) then {
		_xoffSet = 4;
		//_firstposWeld = _plane getPos [18, (getdir _plane)+70];
		//_firstposMech = _plane getPos [18, (getdir _plane)+100];
	};
	if ("c17" in typeof _plane or "c-17" in typeof _plane) then {
		_xoffSet = 4;
		//_firstposWeld = _plane getPos [18, (getdir _plane)+70];
		//_firstposMech = _plane getPos [18, (getdir _plane)+100];
	};

	_planeLen = 0 boundingBoxReal _plane select 1 select 1;

	if (_xoffSet >=0) then {
		_pos = _plane modelToWorld [_xoffSet,(_planeLen)*0.5,0];
		_weldPosp = [_pos select 0, _pos select 1, 0];
	} else {
		_pos = _plane modelToWorld [(_maxW/3.6),(_planeLen)*0.6,0];
		_weldPosp = [_pos select 0, _pos select 1, 0];
	};

	// REPAIRERS MOVES TO REPAIR POSITIONS
	_pWelder enableai "move";
	//_pWelder domove _firstposWeld;
	//sleep 1;

	//waitUntil {sleep 1; _pWelder distance2D _firstposWeld <3.5};

	_pWelder setdir (getdir _plane)-90;
	_pWelder disableAI "anim";
	_pWelder setDir (_pWelder getDir _weldPosp);

	// Welder forced walk to weldpos
	_maxD = (_firstposWeld distance2D _weldPosp);
	while {alive _plane && _pWelder distance2d _weldPosp >0.2 && (_pWelder distance2D _firstposWeld < _maxD)} do {
		_pWelder playMoveNow "amovpercmwlksnonwnondf";
		sleep 0.001;
	};

	_pWelder setdir (_pWelder getdir _plane)+40;

	// Force pos in case of alignment issue
	_pWelder switchMove "";
	_pWelder setposatl _weldPosp;

	// Place Toolbox
	_pWelder playactionnow "takeflag";
	sleep 0.5;
	_repaircase1 setposatl (_pWelder modelToWorld [0.58,0.1,0]);
	_repaircase1 setdir (getdir _pWelder +10);
	detach _repaircase1;
	_repaircase1 enableSimulationGlobal false;

	// Mechanic walks to the plane and repairs
	[_pMechanic, _plane, _weldPosp, _repaircase2] spawn {
		params ["_pMechanic", "_plane", "_weldPosp", "_repaircase2"];

		_initPosM = _pMechanic getVariable "mechPos";

		// Mechanic walks to plane
		_pMechanic allowdamage false;
		_mechPosp = _weldPosp getpos [3, (getdir _plane) +180];
		_weldPosp set [1, (_weldPosp select 1)-0.5];
		_pMechanic setDir (_pMechanic getDir _mechPosp);
		_pMechanic disableAI "anim";
		_pMechanic disableAI "move";
		_maxM = (_initPosM distance2d _mechPosp);
		_pMechanic setDir (_pMechanic getDir _mechPosp);
		while {alive _plane && _pMechanic distance2D _mechPosp >0.1 && (_pMechanic distance2D _initPosM < _maxM)} do {
			_pMechanic playMoveNow "amovpercmwlksnonwnondf";
			sleep 0.001;
		};
		_pMechanic setdir (getdir _plane)-70;

		// Force pos in case of alignment issue
		_pMechanic switchMove "";
		_pMechanic setposatl _mechPosp;

		// Place Toolbox
		_pMechanic playactionnow "takeflag";
		sleep 0.5;
		_repaircase2 setposatl (_pMechanic modelToWorld [0.58,0.1,0]);
		_repaircase2 setdir (getdir _pMechanic +10);
		detach _repaircase2;
		_repaircase2 enableSimulationGlobal false;

		_pMechanic switchMove "inbasemoves_assemblingvehicleerc";
	};

	sleep 1;

	//// Start REPAIR AND OR REFUEL ////

	if (selectMax _allHPvalues >=0.1 or damage _plane >0.05) then {

		// Create welding cart
		_pweldingCart = createVehicle ["Land_WeldingTrolley_01_F", (position _pWelder), [], 0, "CAN_COLLIDE"];
		_pweldingCart setposatl (_pWelder modelToWorld [-1,-0.2,0]);

		_pweapon = primaryWeapon _pWelder;
		_sweapon = secondaryWeapon _pWelder;
		{_pWelder removeWeapon _x} foreach [_pweapon,_sweapon];

		// Place Toolbox
		_pWelder playactionnow "takeflag";
		sleep 0.5;
		detach _repaircase1;
		_pWelder playMoveNow "amovpercmstpsnonwnondnon";
		_repaircase1 setposatl (_pWelder modelToWorld [0.58,0.1,0]);
		_repaircase1 setdir (getdir _pWelder +10);
		_repaircase1 enableSimulationGlobal false;

		sleep 1;

		// Create welding tool
		_pweldingRod = createVehicle ["Land_TorqueWrench_01_F", (position _pWelder), [], 0, "NONE"];
		_pweldingRod attachto [_pWelder,[-0.05,0.15,-0.02],"RightHandMiddle1"];
		_pweldingRod setVectorDirAndUp [[0,-0.1,1],[1,0,0]];
		_pWelder disableai "anim";
		_pWelder switchmove "Acts_Examining_Device_Player";

		// Repair - welding effects exec on all machines except ded server
		[[_pilot, _pWelder, _plane, _pweldingRod, _pweldingCart, _repaircase1],"ROS_PlaneRepair\scripts\ROS_Pwelder.sqf"] remoteExec ["execVM", [0,-2] select isDedicated, true];

		sleep 8;

		// Delay for repairing HP type
		_aveSecPerHP = 1.5;
		_secEngine = 4;
		_secFuel = 2;
		_secRotor = 3;
		_secHull = 5;
		_secGlass = 2;
		_delay = _aveSecPerHP;

		// Repair HPs
		for "_i" from 0 to (_numDamHP-1) do {
			_hp = _allHPnames select _i;
			if ("engine" in _hp) then {_delay = _secEngine};
			if ("fuel" in _hp) then {_delay = _secFuel};
			if ("rotor" in _hp) then {_delay = _secRotor};
			if ("hull" in _hp) then {_delay = _secHull};
			if ("glass" in _hp) then {_delay = _secGlass};
			if (!("engine" in _hp) && !("fuel" in _hp) && !("rotor" in _hp) && !("hull" in _hp) && !("glass" in _hp)) then {_delay = _aveSecPerHP};

			_hpdamage = _allHPvalues select _i;
			{if (_hpdamage>0 && _hp find _x>-1) then {_hitpartDesc = toUpper (_hitpartText select _foreachindex)}} foreach _hitpartType;

			if (_hpdamage >0) then {
				if (isplayer _pilot) then {[format ["Repairing: %1", _hitpartDesc]] remoteExec ["hint", _pilot]};
			};
			[_plane, _hp, 0, true] call BIS_fnc_setHitPointDamage;
			if (_i == _numDamHP-1) exitWith {
				_plane setdamage 0;
				sleep 0.3;
				// Kill sound obj
				deletevehicle _pweldingCart;
				_snd = nearestObject [_pWelder, "#soundonvehicle"];
				deleteVehicle _snd;
				{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_plane nearObjects 7);
			};
			sleep _delay;
		};

		["Repair completed"] remoteExec ["hint", _pilot];

		sleep 1.5;

		// Remove weldingrod
		_pweldingrod = (attachedObjects _pWelder) select 1;
		if(!isnull _pweldingrod) then {deleteVehicle _pweldingrod};

		_pWelder playMoveNow "amovpercmstpsnonwnondnon";
		sleep 1;

		ROSPlaneRepaired = true;

	}; // end Repair

	////// START REFUEL //////

	_fInc = 0;
	_fveh = fuel _plane;

	[_pMechanic, "Acts_JetsCrewaidLCrouch_in"] remoteExec ["switchMove", 0];
	sleep 1;
	[_pWelder, "Acts_JetsCrewaidLCrouch_in"] remoteExec ["switchMove", 0];

	if (fuel _plane <=0.9) then {
		sleep 0.5;
		Phose1 setpos (_fptruck modelToWorld [2.9,-16.2,-1.84]);

		sleep 1;

		if (isplayer _pilot) then {["The vehicle is being refueled Sir"] remoteExec ["hint", _pilot]};
		[Phose1, ["refuel_startP", 100, 1, true]] remoteExec ["say3D", 0];
		sleep 2;
		for "_i" from _fveh to 1 step 0.1 do {
			[Phose1, ["refuel_loopP", 100, 1, true]] remoteExec ["say3D", 0];
			sleep 5;
			if (isplayer _pilot) then {[format ["Refueling: %1 %2", ((fuel _plane)*100) toFixed 1, '%']] remoteExec ["hint", _pilot]};
			if (_i<1) then {[_plane, ((fuel _plane)+0.1)] remoteExec ["setfuel", _plane]};
		};
		[Phose1, ["refuel_endP", 100, 1, true]] remoteExec ["say3D", 0];
		if (isplayer _pilot) then {["Refueled: 100.0"] remoteExec ["hint", _pilot]};
		[_plane, 1] remoteExec ["setfuel", _plane];
	} else {
		// Top up
		[_plane, 1] remoteExec ["setfuel", _plane];
	}; // end fuel < 0.9

	sleep 1;

	ROSPlaneRefueled = true;

	sleep 1;

	////// CLEAN UP //////

	{deleteVehicle _x; sleep 0.1;} forEach [PhoseV,Phose0,Phose1,Phose2,Phose3,Phose4,Phose5];
	waitUntil {isnull Phose5};
	deleteVehicle _repaircase1;
	deletevehicle _repaircase2;
	[_pWelder, "Acts_JetsCrewaidLCrouch_out"] remoteExec ["switchMove", 0];
	sleep 1;
	[_pMechanic, "Acts_JetsCrewaidLCrouch_out"] remoteExec ["switchMove", 0];
	[_pWelder, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];
	[_pMechanic, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];
	sleep 1;
	_nWeldingRod = nearestObject [_pWelder, "Land_TorqueWrench_01_F"];
	_nWeldingCart = nearestObject [_pWelder, "Land_WeldingTrolley_01_F"];
	if (!isNull _nWeldingRod) then {deleteVehicle _nWeldingRod};
	sleep 1;
	if (!isNull _nWeldingCart) then {deleteVehicle _nWeldingCart};
	sleep 1;

	_planeType = getText(configFile>>"CfgVehicles">>(typeOf _plane)>>"DisplayName");
	if (isplayer _pilot) then {
		// Turn to face player
		_pWelder disableAI "move";
		_tb = _pWelder getdir _pilot;
		_cb = getdir _pWelder;
		_ad = round (_tb - _cb + 540) mod 360 -180;
 		_inc = 0;
		if (_ad <0) then {_inc -1} else {_inc =1};
	   	for "i" from 0 to _ad step _inc do {
	   		_pWelder setdir (_cb + i);
	    	sleep 0.001;
	    };

		[_pWelder, true] remoteExec ["setRandomLip", 0];
	    [_pWelder, ["RepairedSirP", 20, 1, true]] remoteExec ["say3D", 0];

		[_plane, format ["%1 has been repaired and refueled Sir", _planeType]] remoteExec ["sidechat", _pilot];
		[format ["%1 has been\nrepaired and refueled Sir", _planeType]] remoteExec ["hint", _pilot];
		sleep 0.7;
		[_pWelder, false] remoteExec ["setRandomLip", 0];
		_pWelder enableAI "move";
		["Wait until repair personnel\nhave cleared the repair area."] remoteExec ["hint", _pilot];
	};

	// Unlock Vehicle
	if (isPlayer _pilot) then {[_plane, false] remoteExec ["lock", _plane]};

	_pWelder enableai "anim";
	_pWelder enableai "move";

	_initPosW = _pWelder getVariable "repPos";
	_initDirW = _pWelder getVariable "repDir";

	// Welder walks back
	_wp0 = (group _pWelder) addWaypoint [_initPosW, 0];
	_wp0 setWaypointType "MOVE";
	_pWelder setspeedMode "limited";

	// Mechanic walks back
	[_pMechanic] spawn {
		params ["_pMechanic"];
		_pMechanic enableai "anim";
		_pMechanic enableai "move";
		_initPosM = _pMechanic getVariable "mechPos";
		_initDirM = _pMechanic getVariable "mechDir";
		_wpm = (group _pMechanic) addWaypoint [_initPosM, 0];
		_wpm setWaypointType "MOVE";
		_pMechanic setspeedMode "limited";
		waitUntil {_pMechanic distance2D _initPosM <3};
		sleep 1;
		// Mechanic reset
		_pMechanic setdir _initDirM;
		_pMechanic disableAI "MOVE";
	};

	// Welder reset
	waitUntil {_pWelder distance2D _initPosW <3};
	[""] remoteExec ["hint", _pilot];
	_pWelder setdir _initDirW;
	_pWelder disableAI "MOVE";

	waitUntil {!isnull objectParent _pilot};

	// Allow player to be seated (some getin anims have long getin time ~6 sec)
	sleep 6;

	// Switch off Fuel truck spotlight and rot orange light after player gets in plane
	_wplight hideObjectGlobal true;

	// Switch off orange repair light
	ROS_rotatingBeacon = false;

	// Have a good day
	if !(_goodDay) then {
		["Good day!"] remoteExec ["hint", _pilot];
		[_pilot, ["hangarcomms", 50, 1, true]] remoteExec ["say3D", _pilot];
		_goodDay = true;
	};

	// Rotate or use pushback
	[_plane, _helipad] call ROS_RotatePlane_Fnc;

	ROSPlaneRepaired = false;
	ROSPlaneRefueled = false;

}; // End ROS_Repair_plane_fnc


//// END FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MAIN LOOP //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Find nearest damaged Plane
while {true} do {

	scopeName "Main";

	_pilot = objNull;
	_plane = objNull;
	ROSPlaneRepaired = false;
	ROSPlaneRefueled = false;

	// Look for planes nearby and repair them
	_nPlanes = (nearestObjects [_pWelder,["plane"],100]) select {!isNull driver _x};
	if (count _nPlanes >0) then {
		_plane = _nPlanes select 0;
	} else {
		_plane == objNull;
	};

	// Pilot
	if (!isNull _plane) then { _pilot = driver _plane;};

	// Is pad clear - if not remove debris
	_neardead = allDead select {_x distance2D _helipad <20};
	_nearobjs = (nearestObjects [_helipad, [], 10.5]) select {_x iskindof "air" or _x iskindof "vehicle"};
	_nearMen = (nearestObjects [_helipad, [], 10.5]) select {_x iskindof "CAManBase" && !alive _x};
	_obstructors = _neardead + _nearobjs + _nearMen;

	if (count _neardead>0) then {
		["Please hold while we clear the debris"] remoteExec ["hint", _pilot];
		sleep 4;
		{deletevehicle _x; sleep 1;} foreach _obstructors;
	};

	if (!isNull _plane && isTouchingGround _plane) then {

		// Direct plane to center pad position
		if !(ROS_taxiAdded) then {
			[[_plane, _helipad], "ROS_PlaneRepair\scripts\ROS_PlaneTaxi.sqf"] remoteexec ["execVM", _plane];
			ROS_taxiAdded = true;
		};

		_hangarClasses = ["Land_vn_airport_02_hangar_left_f","Land_vn_airport_02_hangar_right_f", "Land_Airport_01_hangar_F","Land_Ss_hangard","Land_Ss_hangar","Land_vn_airport_01_hangar_f","Land_vn_usaf_hangar_02","Land_vn_usaf_hangar_03"];

		_nHangars = (_helipad nearObjects 30) select {typeof _x in _hangarClasses};

		// EXIT if plane too large to fit in the hangar - stop hangar block
		if (!isNull _plane && isTouchingGround _plane && sizeOf (typeof _plane) >20) then {

			if (count _nHangars >0 && _plane distance2D _helipad <70) then {
				["STOP !","This plane is too large to enter the repair area!"] remoteExec ["hintC", _pilot];
				// Rotate
				[_plane, _helipad] call ROS_RotatePlane_Fnc;
				breakTo "main";
			};
		};

		// Plane doesn't support hitpoints > Exit
		// Special cases where getAllHitPointDamage returns [];
		if (getAllHitPointsDamage _plane isEqualTo []) then {
			_planeDamage = damage _plane;
		} else {
			_planeDamage = selectMax ((getAllHitPointsDamage _plane) select 2);
		};

		// Show yellow arrows and yellow target
		[_helipad, false] call ROS_HideYmarkers_fnc;

		// Switchon RHS infopanel camera - targetting camera is better
		setInfoPanel ["right", "TransportFeedDisplayComponent"];

		// Get plane fuel level
		_planeFuel = fuel _plane;

		/////////////////////////////////////////////////////

		// Plane doesnt need refueling or repair > Exit loop
		if (_planeFuel >=0.9 && (_planeDamage <0.1 or damage _plane <0.1)) then {

			if (_plane distance2D _helipad <= 4) then {

				// Close RH infopanel
				[_plane, [-1]] enableInfoPanelComponent ["right", "TransportFeedDisplayComponent", false];

				if (!isNull objectParent _pilot) then {
					["This vehicle does not need\nrepairing / refueling\nPlease vacate the area\nThank you!"] remoteExec ["hint", _pilot];
				} else {
					["Please board your vehicle\nand vacate the repair bay area"] remoteExec ["hint", _pilot];
				};
				_plane setdamage 0;
				[_plane, 1] remoteExec ["setfuel", _plane];
				sleep 3;
				if !(_goodDay) then {
				    ["Have a good day!"] remoteExec ["hint",_pilot];
					[_pilot, ["hangarcomms", 50, 1, true]] remoteExec ["say3D", _pilot];
					_goodDay = true;
				};
				waitUntil {!isnull objectParent _pilot};

				// Allow get anim to complete
				sleep 6;

				// Plane will now rotate
				["Plane rotation will now commence"] remoteExec ["hint", _pilot];

				sleep 2;

				// Switch off orange repair light
				ROS_rotatingBeacon = false;

				// Rotate
				[_plane, _helipad] call ROS_RotatePlane_Fnc;

				// Hide yellow arrows and target
				[_helipad, true] call ROS_HideYmarkers_fnc;
			};
		}; // plane not damaged / doesnt need fuel > exit

		/////////////////////////////////////////////////

		// Plane needs repair or refueling
		if (_planeFuel <0.9 or (_planeDamage >=0.1 or damage _plane >=0.1)) then {
			// Cleared to approach
			if !(_cta) then {
				if (isPlayer _pilot) then {
					[_plane, ["ClearedApproach",100,1,true]] remoteExec ["say3D", _pilot];
					sleep 0.5;
					_cta = true;
				};
			};

			//Switch on spotlight on rear of fuel truck
			if (isObjectHidden _wplight) then {_wplight hideObjectGlobal false;};

			// Prepare fuel pipes
			[_plane] call ROS_PlaneFuelPipes_Fnc;

			// Start repair and or refuel
			if (_plane distance2D _helipad <= 3 && (_planeFuel <0.9 or _planeDamage >=0.1)) then {

				// Close RH infopanel
				[_plane, [-1]] enableInfoPanelComponent ["right", "TransportFeedDisplayComponent", false];
				// Engine off
				[_plane, false] remoteExec ["engineOn", _plane];
				// Tell pilot engine is off and he's exiting the plane
				[_pilot, ["exitvehicle", 100, 1, true]] remoteExec ["say3D", _pilot];
				["Engine is: OFF Exit the vehicle"] remoteExec ["hint", _pilot];

				// Kick player
				_pilot action ["getOut", _plane];
				waitUntil {isnull objectParent _pilot};

				// Force move player out of plane
				if !(isnull objectParent _pilot) then {moveOut _pilot};

				// Hide yellow arrows
				[_helipad, true] call ROS_HideYmarkers_fnc;

				// Align the plane with repair bay
				["Aligning Plane with repair bay"] remoteExec ["hint", _pilot];
				[_plane, false] remoteExec ["enableSimulation",0];
				_plane setPosATL (getPosatl _helipad);
				sleep 1;
				_plane setdir (getdir _helipad);
				[_plane, true] remoteExec ["enableSimulation",0];

				// Call repair fnc
				[_pWelder, _plane, _pilot, _hitpartType, _hitpartText, _helipad, _fptruck, _wplight] call ROS_Repair_plane_fnc;

				// wait tunitl plane left the area
				waitUntil {((_plane distance2D _helipad >100 && !([position _plane, getDir _plane, 30, position _helipad] call BIS_fnc_inAngleSector)) or !alive _plane or !alive _pilot)};

				// Switch off orange repair light
				ROS_rotatingBeacon = false;
				_cta = false;
			};
		}; // Plane needs repair or refueling

	}; // !isnull _plane

	// Clear taxi added and clear to approach state
	ROS_taxiAdded = false;

	sleep 1;

}; // end while


