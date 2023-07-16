/*

ROS Heli repair v2.0 - by RickOShay

FUNCTION
Damaged helicopters that land at the repair bay will be auto repaired and refueled by AI units.
It supports all helis in Arma 3 / DLCs / RHS / SOG / Hatchet H-60 pack

LEGAL STUFF
Credit must be given in your mission and on the Steam Workshop if this script is used in any mission or
derivative works. There are three dependent scripts: ROS_HeliRepair.sqf, ROS_Welder.sqf, ROSWavein.sqf.
They must be kept together.

NOTE
Helicopters must have hitpoints - in order to be repaired.

USAGE:
In the editor drop down a Wave-in unit - who will wave in helos he must face the direction helos will fly in from.
Now drop down a square helipad 20m in front of the wave-in unit - where the helo will land and be repaired
Make sure the helipad is orientated or pointed directly at the wave-in unit
Now place a Repair AI unit ~20m to the RHS of the helipad facing the helipad and about 3m ahead of the center to allow for the auto spawnedd fuel truck positioning
The repair unit and wave-in units must not be grouped to other units

	    👨 Wave-in unit facing the helipad


		 ↑ 20m

      _______		→ 25m    👨 Repair unit facing the helipad
     |       |      ↑ 3m gap - clear of objects
     |   ↑   |
     |helipad|  	→ 25m    ⛟ (auto spawned fuel truck, refueler & fuel pipe) leave this area clear of objects
	 |_______|


         ↑

        🚁 inbound helis

Place the following line in the Repair units init field:
[this] execvm "ROS_HeliRepair\scripts\ROS_HeliRepair.sqf";

Place the following line in the wavein units init field:
[this] execvm "ROS_HeliRepair\scripts\ROS_wavein.sqf";

Now copy the ROS_HeliRepair folder to your mission root.
Add the sound classes from the provided description.ext to the Cfg_Sound into your description.ext.

OPTIONAL:
Use the Rotating Orange beacon light to show the repair pad is busy - default true 								   */

Rotating_Beacon = true;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// DO NOT MAKE CHANGES BELOW THIS LINE //////////////////////////////////////////////// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if !(isServer) exitWith {};

params ["_hRepairer"];

// Supported helipads
//_helipads = ["Land_HelipadCircle_F","Land_HelipadCivil_F","Land_HelipadEmpty_F","Land_HelipadRescue_F","Land_HelipadSquare_F","HeliH","HeliHCivil","Heli_H_civil","HeliHEmpty","HeliHRescue","Heli_H_rescue"];

_nHeliPads = [];
_nHeliPad = objNull;
_ftruck = objNull;
_wlight = objNull;
_ctl = false;
ROSHeliRepaired = false;
publicVariable "ROSHeliRepaired";
ROSHeliRefueled = false;
publicVariable "ROSHeliRefueled";
ROS_rothBeaconOn = false;
publicVariable "ROS_rothBeaconOn";
_initPos = getPosATL _hRepairer;
_nearestHeli = objNull;
_heliDamage = 0;
_heliFuel = 0;
_vehType = "";
_firstpos = [0,0,0];
_reppos = [0,0,0];
_heliPadlamp = objNull;

// Disable damage on repairer
_hRepairer allowDamage false;

// Remove Repairer's weapons
_pweapon = primaryWeapon _hRepairer;
_sweapon = secondaryWeapon _hRepairer;
{_hRepairer removeWeapon _x} foreach [_pweapon,_sweapon];

// Prevent unit from being profiled by Alive
_hRepairer setVariable ["ALIVE_profileIgnore", true];

_nHeliPads = nearestObjects [_hRepairer, ["HeliH"], 30];
if (count _nHeliPads >0) then {_nHeliPad = _nHeliPads select 0};
if (isNull _nHeliPad) exitWith {["There is no nearby helipad within (~20m) of the repair unit"] remoteExec ["hint",0]};

// If unit not close to initpos move to relative position
_pos = (_nHeliPad modeltoworld [20,3.5,0]);
if (_hRepairer distance2D _pos >2) then {
	_hRepairer setpos _pos;
	_hRepairer setdir (_hRepairer getdir _nHeliPad);
	_initPos = getPosATL _hRepairer;
};

// Light center of helipad
_heliPadlamp = "PortableHelipadLight_01_red_F" createVehicle [0,0,0];
_heliPadlamp setpos (_nHeliPad modeltoworld [0,0,-0.1]);
_heliPadlamp enableSimulationGlobal false;
_heliPadlamp allowdamage false;
_heliPadlamp setdir (getdir _hRepairer);

// Oil spill on helipad
_oil1 = "Oil_Spill_F" createVehicle [0,0,0];
_oil1 setpos (_heliPadlamp modeltoworld [0,1.5,0]);

// Place red light on vest
_r1 = "Chemlight_red" createVehicleLocal [0,0,0];
_r1 attachTo [_hRepairer, [0,0.1,0], "Spine3"];

ROS_rothBeaconOn = false;
publicVariable "ROS_rothBeaconOn";

sleep 1;

// Add Rotating Orange light on all clients
if (Rotating_Beacon) then {
	[[_heliPadlamp],"ROS_HeliRepair\scripts\ROS_hOlight.sqf"] remoteExec ["execVM", 0, true];
};

_hitpartType = ["#c svetlo","#cabin_light","#cabin_light1","#cabin_light2","#cabin_light3","#cam_gunner","#cargo_light_1","#cargo_light_2","#cargo_light_3","#cargo_light_4","#gear_1_light_1_hit","#gear_1_light_2_hit","#gear_2_light_1_hit","#gear_3_light_1_hit","#gear_3_light_2_hit","#gear_f_lights","#glass11","#hitlight1","#hitlight2","#hitlight3","#l svetlo","#l2 svetlo","#light_1","#light_1_hit","#light_1_hitpoint","#light_2","#light_2_hit","#light_2_hitpoint","#light_3_hit","#light_4_hit","#light_f","#light_fg125","#light_g","#light_hd_1","#light_hd_2","#light_hitpoint","#light_l","#light_l_flare","#light_l_hitpoint","#light_l2","#light_l2_flare","#light_r","#light_r_flare","#light_r_hitpoint","#light_r2","#light_r2_flare","#p svetlo","#p2 svetlo","#reverse_light_hit","#rl_nav_illum","#rl_op_red_illum","#rl_op_teal_illum","#rl_remspot_illum","#searchlight","#svetlo","#t svetlo","#wing_left_light","#wing_right_light","armor_composite_65","glass_pod_01_hitpoint","hit_ammo","hit_optic_crows_day","hit_optic_driver","hit_optic_sosnau","hitatgmsight","hitbody","hitduke1","hitengine","hitfuel","hitfuel_l","hitfueltank_left","hitglass1","hithrotor","hithull","hithull_structural","hitlfwheel","hitvrotor","hitwindshield_1","armor_composite_40","armor_composite_50","armor_composite_60","armor_composite_70","armor_composite_75","armor_composite_80","armor_composite_85","armor_composite_95","glass_1_hitpoint","glass_10_hitpoint","glass_11_hitpoint","glass_12_hitpoint","glass_13_hitpoint","glass_14_hitpoint","glass_15_hitpoint","glass_16_hitpoint","glass_17_hitpoint","glass_18_hitpoint","glass_19_hitpoint","glass_2_hitpoint","glass_20_hitpoint","glass_3_hitpoint","glass_4_hitpoint","glass_5_hitpoint","glass_6_hitpoint","glass_7_hitpoint","glass_8_hitpoint","glass_9_hitpoint","glass_pod_02_hitpoint","glass_pod_03_hitpoint","glass_pod_04_hitpoint","glass_pod_05_hitpoint","glass_pod_06_hitpoint","hit_ammo","hit_gps_headmirror","hit_gps_optical","hit_gps_tis","hit_light_l","hit_light_r","hit_lightl","hit_lightr","hit_longbow","hit_optic_1g46","hit_optic_1k13","hit_optic_1k13","hit_optic_9s475","hit_optic_citv","hit_optic_comcwss","hit_optic_comm2","hit_optic_comperiscope","hit_optic_comperiscope1","hit_optic_comperiscope2","hit_optic_comperiscope3","hit_optic_comperiscope4","hit_optic_comperiscope5","hit_optic_comperiscope6","hit_optic_comperiscope7","hit_optic_comsight","hit_optic_crows_day","hit_optic_crows_day","hit_optic_crows_lrf","hit_optic_crows_ti","hit_optic_driver","hit_optic_driver_rear","hit_optic_driver1","hit_optic_driver2","hit_optic_driver3","hit_optic_dvea","hit_optic_essa","hit_optic_gps","hit_optic_gps_ti","hit_optic_loaderperiscope","hit_optic_mainsight","hit_optic_nsvt","hit_optic_periscope","hit_optic_periscope1","hit_optic_periscope2","hit_optic_periscope3","hit_optic_periscope4","hit_optic_pnvs","hit_optic_sosnau","hit_optic_tads","hit_optic_tkn3","hit_optic_tkn3","hit_optic_tkn4s","hit_optic_tpd1k","hit_optic_tpn4","hit_optics_cdr_civ","hit_optics_cdr_peri","hit_optics_dvr_dve","hit_optics_dvr_peri","hit_optics_dvr_rearcam","hit_optics_gnr","hitaasight","hitammo","hitammohull","hitavionics","hitbattery_l","hitbattery_r","hitbody","hitcomgun","hitcomsight","hitcomturret","hitcontrolrear","hitdoor_1_1","hitdoor_1_2","hitdoor_2_1","hitdoor_2_2","hitduke1","hitduke2","hitengine","hitengine_1","hitengine_2","hitengine_3","hitengine_4","hitengine_c","hitengine_l1","hitengine_l2","hitengine_r1","hitengine_r2","hitengine1","hitengine2","hitengine3","hitengine4","hitfuel","hitfuel_l","hitfuel_lead_left","hitfuel_lead_right","hitfuel_left","hitfuel_left_wing","hitfuel_r","hitfuel_right","hitfuel_right_wing","hitfuel2","hitfuell","hitfuelr","hitfueltank","hitfueltank_left","hitfueltank_right","hitgear","hitglass1","hitglass10","hitglass11","hitglass12","hitglass13","hitglass14","hitglass15","hitglass16","hitglass17","hitglass18","hitglass19","hitglass1a","hitglass1b","hitglass2","hitglass20","hitglass21","hitglass3","hitglass4","hitglass5","hitglass6","hitglass7","hitglass8","hitglass9","hitgun","hitgun1","hitgun2","hitgun3","hitgun4","hitguncom","hitguncomm2","hitgunlauncher","hitgunloader","hitgunnsvt","hithood","hithrotor","hithstabilizerl1","hithull","hithull_structural","hithydraulics","hitlaileron","hitlaileron_link","hitlauncher","hitlbwheel","hitlcelevator","hitlcrudder","hitlf2wheel","hitlfwheel","hitlglass","hitlight","hitlightback","hitlightfront","hitlightl","hitlightr","hitlmwheel","hitlrf2wheel","hitltrack","hitmainsight","hitmissiles","hitperiscope1","hitperiscope10","hitperiscope11","hitperiscope12","hitperiscope13","hitperiscope14","hitperiscope2","hitperiscope3","hitperiscope4","hitperiscope5","hitperiscope6","hitperiscope7","hitperiscope8","hitperiscope9","hitperiscopecom1","hitperiscopecom2","hitperiscopegun1","hitperiscopegun2","hitperiscopegun3","hitperiscopegun4","hitpylon1","hitpylon10","hitpylon11","hitpylon2","hitpylon3","hitpylon4","hitpylon5","hitpylon6","hitpylon7","hitpylon8","hitpylon9","hitraileron","hitraileron_link","hitrbwheel","hitrelevator","hitreservewheel","hitrf2wheel","hitrfwheel","hitrglass","hitrightrudder","hitrmwheel","hitrotor","hitrotor1","hitrotor2","hitrotor3","hitrotor4","hitrotor5","hitrotor6","hitrotorvirtual","hitrrudder","hitrtrack","hitsearchlight","hitspare","hitstarter1","hitstarter2","hitstarter3","hittail","hittransmission","hitturret","hitturret1","hitturret2","hitturret3","hitturret4","hitturretcom","hitturretcomm2","hitturretlauncher","hitturretloader","hitturretnsvt","hitvrotor","hitvstabilizer1","hitwinch","hitwindshield_2","ind_hydr_l","ind_hydr_r","indicatoreng1","indicatoreng2","indicatoroil1","indicatoroil2","usespare","warningaileron","warningelevator"];

_hitpartText = ["Light","Cabin Light","Cabin Light","Cabin Light","Cabin Light","Cam Gunner","Cargo Light","Cargo Light","Cargo Light","Cargo Light","Gear Light","Gear Light","Gear Light","Gear Light","Gear Light","Gear Light","Glass","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Light","Searchlight","Light","Light","Light","Light","Armor","Glass","Ammo","Optics","Optics","Optics","Sight","Body","Duke","Engine Part","Fuel","Fuel","Fuel","Glass","Rotor","Hull","Hull","Wheel","Rotor","Windshield","Armor","Armor","Armor","Armor","Armor","Armor","Armor","Armor","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Ammo","Mirror","GPS","GPS","Light","Light","Light","Light","Longbow","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Optics","Sight","Ammo","Ammo","Avionics","Battery","Battery","Body","Gun","Sight","Turret","Control","Door","Door","Door","Door","Duke","Duke","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Engine Part","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel System","Fuel Tank","Fuel Tank","Fuel Tank","Gear","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Glass","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Gun","Hood","Rotor","Stabilizer","Hull","Hull","Hydraulics","Aileron","Aileron","Launcher","Wheel","Elevator","Rudder","Wheel","Wheel","Glass","Light","Light","Light","Light","Light","Wheel","Wheel","Track","Sight","Missiles","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Periscope","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Pylon","Aileron","Aileron","Wheel","Elevator","Wheel","Wheel","Wheel","Glass","Rudder","Wheel","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rotor","Rudder","Track","Searchlight","Spare","Starter","Starter","Starter","Tail","Transmission","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Turret","Rotor","Stabilizer","Winch","Windshield","Hydraulics","Hydraulics","Indicator Engine","Indicator Engine","Indicator Oil","Indicator Oil","Spare","Aileron","Elevator"];

// Remove repairer NVGoggles
_hRepairer unassignitem "nvgoggles";
_hRepairer removeitem "nvgoggles";

_dir = getDir _hRepairer;
_ftruckpos = _nHeliPad modeltoworld [21.8721,-1.82813,0];
_ftruck = createvehicle ["C_Van_01_fuel_F", _ftruckpos, [], 0, "NONE"];
_ftruck setpos _ftruckpos;
_ftruck setdir (_ftruck getdir _nHeliPad)-180;

// White spotlight rear of Ftruck
_wlight = "Reflector_Cone_01_narrow_white_F" createVehicle [0,0,0];
_wlight setpos (_ftruck modelToWorld [-0.1,-3.48,0.855]);
_wlight setdir (_wlight getdir _nHeliPad);
_wlight hideObjectGlobal true;

sleep 1;
_refueler = "B_engineer_F" createvehicle [0,0,0];
_refueler setpos (_ftruck modeltoworld [2.5,-2.5,-1.7]);
_refueler setdir (_refueler getdir _nHeliPad);
// Prevent unit from being profiled by Alive
_refueler setVariable ["ALIVE_profileIgnore", true];
[_refueler, "Acts_CivilIdle_1"] remoteExec ["switchMove",_refueler];

// Place white light in front or refueler
_lightp = "#lightpoint" createVehicle [0,0,0];
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


// Create fuel pipes
ROS_heliFuelPipes_Fnc = {
	Hhose0 = createVehicle ["LayFlatHose_01_CurveShort_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Hhose1 = createvehicle ["LayFlatHose_01_CurveLong_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Hhose2 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Hhose3 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Hhose4 = createvehicle ["LayFlatHose_01_SBend_F", [0,0,0], [], 0, "CAN_COLLIDE"];
	Hhose5 = createVehicle ["LayFlatHose_01_CurveShort_F", [0,0,0], [], 0, "CAN_COLLIDE"];

	Hhose2 attachto [Hhose1,[-0.55,-5,0]];
	Hhose3 attachto [Hhose2,[0.86,-5,0]];
	Hhose4 attachto [Hhose3,[0.86,-5,0]];
	Hhose1 setdir (getdir _ftruck +180);
	Hhose5 attachto [Hhose4,[0.43,-3.1,0.47]];
	Hhose5 setdir (getdir Hhose4-140);
	Hhose5 setvectorup [1,0,0];
	Hhose0 attachto [Hhose1,[1.4,2.9,0.47]];
	Hhose0 setvectorUp [-0.5,0.5,0];
	Hhose0 setvectorDir [0.149259,0.988798,0];
};

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

ROS_Repair_heli_completed = false;
publicVariable "ROS_Repair_heli_fnc_completed";

ROS_Repair_heli_fnc = {
	params ["_hRepairer", "_veh", "_initPos", "_hitpartType", "_hitpartText", "_nHeliPad", "_ftruck", "_wlight"];

	_rdist = 0;
	_pilot = driver _veh;
	_hitpartDesc = "";
	_allHPvalues = [];
	_hweldingrod = objnull;
	_hweldingCart = objNull;
	_hrepaircase = objNull;

	// Switch on rotating orange pad light
	ROS_rothBeaconOn = true;
	publicVariable "ROS_rothBeaconOn";

	// Repair the Heli
	[""] remoteExec ["hint", _pilot];

	// Create Repaircase
	_hrepaircase = "Land_PlasticCase_01_small_F" createVehicle (position _hRepairer);
	_hrepaircase enableSimulationGlobal false;
	_hrepaircase setposatl (_hRepairer modelToWorld [0.5,-0.2,-0.5]);
	_hrepaircase setdir (getdir _hRepairer +10);

	if (isEngineOn _veh && isTouchingGround _veh && _veh distance2D _nHeliPad <5 && alive _veh) then {
		if (isplayer _pilot) then {
			[_hRepairer, "Switch the engine and lights off and Exit the vehicle."] remoteExec ["sidechat",0];
			["Please switch the engine and lights off and Exit the vehicle."] remoteExec["hint",0];
		};
	};

	// Align heli with pad
	["Aligning vehicle with repair bay"] remoteExec ["hint", (driver _veh)];
	_veh setPos (getpos _nHeliPad);

	// Force engine and lights off
	[_veh, false] remoteExec ["engineOn", _veh];
	[_veh, false] remoteExec ["setPilotLight", _veh];

	[""] remoteExec ["hint",0];

	if (isplayer _pilot && vehicle _pilot == _veh && isengineOn _veh) then {
		[_hRepairer,"Switch the engine and lights off and Exit the vehicle."] remoteExec ["sidechat", _pilot];
		["Switch the engine and lights off and Exit the vehicle."] remoteExec ["hint", _pilot];
	};

	waitUntil {!(isengineOn _veh) or !alive _veh};

	// Force pilot out once engine off
	_pilot action ["getOut", _veh];
	waitUntil {vehicle _pilot == _pilot or !alive _veh};
	sleep 1;
	[""] remoteExec ["hint", _pilot];

	// Lock Vehicle
	if (isPlayer _pilot && (vehicle _pilot == _pilot) && alive _veh && !(isEngineOn _veh)) then {[_veh, true] remoteExec ["lock", _veh]};

	_hRepairer setBehaviour "careless";
	_hRepairer setspeedMode "limited";
	_hRepairer allowFleeing 0;
	_hRepairer allowDamage false;

	// [hitpointsNamesArray, selectionsNamesArray, damageValuesArray]
	_allHPnames = ((getAllHitPointsDamage _veh) select 0);
	_allHPvalues = ((getAllHitPointsDamage _veh) select 2);
	_numDamHP = {_x >0} count _allHPvalues;
	// Vehicle doesnt have hitpoints simulate some minor global damage
	if (_allHPvalues isEqualTo [] && damage _veh == 0) then {_veh setdamage 0.3};

	sleep 1;

	// Attach repair case to repairer's hand
	_hrepaircase setdir (getdir _hRepairer -5);
	_hrepaircase attachto [_hRepairer,[0.01,-0.06,-0.21],"RightHandMiddle1"];

	// Get approx size of hull
	_bbr = 0 boundingBoxReal _veh;
	_ba1 = _bbr select 0;
	_ba2 = _bbr select 1;
	_bsd = _bbr select 2; // sphere diameter
	_maxW = abs ((_ba2 select 0) - (_ba1 select 0));
	_maxL = abs ((_ba2 select 1) - (_ba1 select 1));

	if (_maxL > _maxW) then {_maxW = _maxL};

	_reppos = [0,0,0];
	_xoffSet = 0;

	// Create moveto positions
	_firstpos = _veh getPos [_maxW+1, (getdir _veh)+90];

	// A3 / RHS
	if ("RHS_MELB" in typeof _veh) then {_xoffSet =2.2;};
	if ("RHS_AH64D" in typeof _veh or "Apache_AH1" in typeOf _veh) then {_xoffSet =3;};
	if ("RHS_UH60M" in typeof _veh or "vtx_UH60M_MEDEVAC" in typeOf _veh or "vtx_UH60M_SLICK" in typeOf _veh) then {_xoffSet =3;};
	if ("vtx_MH60M" in typeOf _veh or "vtx_HH60" in typeof _veh) then {_xoffSet = 3;};
	if ("vtx_MH60M_DAP" in typeOf _veh or "vtx_MH60M_DAP_MLASS" in typeof _veh) then {_xoffSet = 3;};
	if ("160thsoar_PJ_dap" in typeOf _veh) then {_xoffSet = 3;};
	if ("160thsoar_PJ" in typeOf _veh) then {_xoffSet = 3;};
	if ("B_Heli_Light" in typeof _veh) then {_xoffSet =2.3;};
	if ("C_Heli_Light" in typeof _veh) then {_xoffSet =2;};
	if ("I_C_Heli_Light" in typeof _veh) then {_xoffSet =2;};
	if ("O_Heli_Light_02" in typeof _veh or "rhs_ka60" in typeOf _veh) then {_xoffSet =2.55;};
	if ("B_Heli_Attack" in typeof _veh) then {_xoffSet =2.6;};
	if ("B_Heli_Transport_03" in typeof _veh) then {_xoffSet =3.85;};
	if ("Heli_Transport_01" in typeof _veh) then {_xoffSet =2.8;};
	if ("O_Heli_Attack" in typeof _veh) then {_xoffSet =4.3;};
	if ("O_Heli_Transport" in typeof _veh) then {_xoffSet =4.8;};
	if ("I_Heli_light_03" in typeof _veh or "Wildcat_AH1" in typeOf _veh) then {_xoffSet =2.1;};
	if ("I_E_Heli_light_03" in typeof _veh) then {_xoffSet =2.1;};
	if ("RHS_AH1Z" in typeof _veh) then {_xoffSet =3.5;};
	if ("RHS_UH1Y" in typeof _veh) then {_xoffSet =2.4;};
	if ("C_IDAP_Heli_Transport" in typeof _veh) then {_xoffSet =3.9;};
	if ("RHS_Ka52" in typeOf _veh) then {_xoffSet = 6.1;};
	if ("rhs_mi28" in typeOf _veh) then {
		_xoffSet =3.1;
		_firstpos = _veh getPos [_maxW-6, (getdir _veh)+90];
	};
	if ("RHS_Mi8" in typeOf _veh) then {
		_xoffSet =2.95;
		_firstpos = _veh getPos [_maxW-6, (getdir _veh)+90];
	};
	if ("RHS_Mi24" in typeOf _veh) then {
		_xoffSet =2.7;
		_firstpos = _veh getPos [_maxW-4.5, (getdir _veh)+90];
	};
	if ("I_Heli_Transport_02" in typeof _veh or "Merlin_HC3" in typeOf _veh) then {
		_xoffSet = 3.9;
		_firstpos = _veh getPos [_maxW-4, (getdir _veh)+90];
	};
	if ("rhsusf_CH53E_USMC" in typeof _veh) then {
		_xoffSet = 4.8;
		_firstpos = _veh getPos [_maxW+7.1, (getdir _veh)+90];
	};
	if ("RHS_CH_47F" in typeof _veh) then {
		_xoffSet = 3.3;
		_firstpos = _veh getPos [_maxW-4, (getdir _veh)+90];
	};

	xoffSet = _xoffSet; // remove

	// SOG
	if ("vn_b_air_uh1c" in typeOf _veh) then {_xoffSet =2.25;};
	if ("vn_i_air_uh1c" in typeOf _veh) then {_xoffSet =2.25;};
	if ("vn_b_air_uh1d" in typeOf _veh) then {_xoffSet =2.65;};
	if ("vn_i_air_uh1d" in typeOf _veh) then {_xoffSet =2.65;};
	if ("vn_b_air_oh6a" in typeOf _veh) then {_xoffSet =2.0;};
	if ("vn_b_air_ah1g" in typeOf _veh) then {_xoffSet =2.2;};
	if ("vn_b_air_ch34" in typeOf _veh) then {_xoffSet =2.4;};
	if ("vn_i_air_ch34" in typeOf _veh) then {_xoffSet =2.4;};
	if ("vn_o_air_mi2" in typeof _veh) then {_xoffSet =2.4;};

	if (_xoffSet >=0) then {
		_reppos = _veh getPos [_xoffSet, (getDir _veh)+90];
	} else {
		_reppos = _veh getPos [(_maxW/3.6), (getDir _veh)+90];
	};

	// Move to first pos
	_hRepairer enableai "move";
	_hRepairer domove _firstPos;

	waitUntil {_hRepairer distance2D _firstpos <3.5};

	_hRepairer setdir (getdir _veh)-90;
	_hRepairer disableAI "anim";
	_hRepairer setDir (_hRepairer getDir _reppos);

	// Forced walk to reppos
	_maxD = (_firstpos distance2D _reppos);
	while {_hRepairer distance2D _reppos >0.12 && alive _veh && !(_hRepairer distance2D _firstpos > _maxD)} do {
		_hRepairer playMoveNow "amovpercmwlksnonwnondf";
		sleep 0.0001;
	};

	_hRepairer switchMove "";
	_hRepairer setposatl _reppos;

	// Place Toolbox
	_hRepairer playactionnow "takeflag";
	sleep 0.5;
	detach _hrepaircase;
	_hRepairer playMoveNow "amovpercmstpsnonwnondnon";
	_hrepaircase setposatl (_hRepairer modelToWorld [0.5,-0.2,0]);
	_hrepaircase setdir (getdir _hRepairer +10);
	_hrepaircase enableSimulationGlobal false;

	sleep 1;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Start REPAIR AND OR REFUEL
	if (selectMax _allHPvalues >=0.1 or damage _veh >0.1) then {

		// Create welding cart
		_hweldingCart = createVehicle ["Land_WeldingTrolley_01_F", (position _hRepairer), [], 0, "NONE"];
		_hweldingCart setposatl (_hRepairer modelToWorld [-1,-0.2,0]);

		_pweapon = primaryWeapon _hRepairer;
		_sweapon = secondaryWeapon _hRepairer;
		{_hRepairer removeWeapon _x} foreach [_pweapon,_sweapon];

		sleep 2;

		// Create welding tool
		_hweldingRod = createVehicle ["Land_TorqueWrench_01_F", (position _hRepairer), [], 0, "NONE"];
		_hweldingRod attachto [_hRepairer,[-0.05,0.15,-0.02],"RightHandMiddle1"];
		_hweldingRod setVectorDirAndUp [[0,-0.1,1],[1,0,0]];
		_hRepairer disableai "anim";
		_hRepairer switchmove "Acts_Examining_Device_Player";

		// Repair - welding effects exec on all machines except ded server
		[[_pilot, _hRepairer, _veh, _hweldingRod, _hweldingCart],"ROS_HeliRepair\scripts\ROS_Hwelder.sqf"] remoteExec ["BIS_fnc_execVM", [0,-2] select isDedicated, true];

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
				if (isplayer _pilot) then {[format ["Repairing:\n%1", _hitpartDesc]] remoteExec ["hint", _pilot]};
			};

			[_veh, _hp, 0, true] call BIS_fnc_setHitPointDamage;
			if (_i == _numDamHP-1) exitWith {
				_veh setdamage 0;
				sleep 0.3;
				// Kill sound obj
				deletevehicle _hweldingCart;
				_snd = nearestObject [_hRepairer, "#soundonvehicle"];
				deleteVehicle _snd;
				{if (typeOf _x == "#particlesource") then {deleteVehicle _x}} forEach (_veh nearObjects 7);
				ROSHeliRepaired = true;
				publicVariable "ROSHeliRepaired";
			};
			sleep _delay;
		};

		if (isplayer _pilot) then {["Repair completed"] remoteExec ["hint", _pilot];};

		sleep 0.5;

		// Remove weldingrod
		_hweldingrod = (attachedObjects _hRepairer) select 1;
		if(!isnull _hweldingrod) then {deleteVehicle _hweldingrod};

		_hRepairer playMoveNow "amovpercmstpsnonwnondnon";

		sleep 2;
	}; // end Repair

	ROSHeliRepaired = true;
	publicVariable "ROSHeliRepaired";

	/////////////////////////////////////////////////////////////////////////////////////////////////////

	// Start Refuel
	_fInc = 0;
	_fveh = fuel _veh;

	sleep 1;

	[_hRepairer, "Acts_JetsCrewaidLCrouch_in"] remoteExec ["switchMove" ,0];

	if (fuel _veh <=0.9) then {
		sleep 0.5;
		Hhose1 setpos (_ftruck modelToWorld [2.9,-16.2,-1.74]);
		sleep 1;

		if (isplayer _pilot) then {["The vehicle is being refueled Sir"] remoteExec ["hint", _pilot]};
		[[Hhose1, _pilot], ["refuel_startH", 50]] remoteExec ["say3D", 0];
		sleep 2;
		for "_i" from _fveh to 1 step 0.1 do {
			[[Hhose1, _pilot], ["refuel_loopH", 50]] remoteExec ["say3D", 0];
			sleep 5;
			if (isplayer _pilot) then {[format ["Refueling: %1 %2", ((fuel _veh)*100) toFixed 1, '%']] remoteExec ["hint", _pilot]};
			if (_i<1) then {[_veh, ((fuel _veh)+0.1)] remoteExec ["setfuel", _veh]};
		};
		[[Hhose1, _pilot], ["refuel_endH", 50]] remoteExec ["say3D", 0];
		if (isplayer _pilot) then {["Refueled: 100.0"] remoteExec ["hint", _pilot]};
		[_veh, 1] remoteExec ["setfuel", _veh];
	} else {
		// Top up
		[_veh, 1] remoteExec ["setfuel", _veh];
	}; // end fuel < 0.9

	sleep 1;

	ROSHeliRefueled = true;
	publicVariable "ROSHeliRefueled";

	sleep 1;

	/////////////////////////////////////////////////////////////////////////////////////////////////////

	// Clean up
	if (!isNull Hhose1) then {
		{deleteVehicle _x; sleep 0.1;} forEach [Hhose0,Hhose1,Hhose2,Hhose3,Hhose4,Hhose5];
	};

	waitUntil {isnull Hhose5};

	deleteVehicle _hrepaircase;

	[_hRepairer, "Acts_JetsCrewaidLCrouch_out"] remoteExec ["switchMove", 0];

	sleep 2;

	[_hRepairer, "amovpercmstpsnonwnondnon"] remoteExec ["switchMove", 0];

	[[_hRepairer, _pilot], ["RepairedSirH", 50]] remoteExec ["say3D", 0];
	_vehType = getText(configFile>>"CfgVehicles">>typeOf (_veh)>>"DisplayName");
	if (isplayer _pilot) then {
		[_hRepairer, true] remoteExec ["setRandomLip", 0];
		// Turn to face player
		_hRepairer disableAI "move";
		_tb = _hRepairer getdir _pilot;
		_cb = getdir _hRepairer;
		_ad = round (_tb - _cb + 540) mod 360 -180;
 		_inc = 0;
		if (_ad <0) then {_inc -1} else {_inc =1};
	   	for "i" from 0 to _ad step _inc do {
	   		_hRepairer setdir (_cb + i);
	    	sleep 0.001;
	    };

		[_veh, format ["%1 has been repaired and refueled Sir", _vehType]] remoteExec ["sidechat", _pilot];
		[format ["%1 has been\nrepaired and refueled Sir", _vehType]] remoteExec ["hint", _pilot];
		sleep 0.7;
		[_hRepairer, false] remoteExec ["setRandomLip", 0];
		["Wait until repair personnel\nhave cleared the repair area."] remoteExec ["hint", _pilot];
	};

	// Unlock Vehicle
	if (isPlayer _pilot) then {[_veh, false] remoteExec ["lock", _veh]};

	_hRepairer enableai "anim";
	_hRepairer enableai "move";

	_wp0 = (group _hRepairer) addWaypoint [_initPos, 0];
	_wp0 setWaypointType "MOVE";
	_hRepairer setspeedMode "limited";

	waitUntil {_hRepairer distance2D _initPos <3};
	[""] remoteExec ["hint", _pilot];
	sleep 1;

	_hRepairer setdir (_hRepairer getdir _nHeliPad);
	_hRepairer disableAI "MOVE";

	ROSHeliRefueled = true;
	publicVariable "ROSHeliRefueled";
	ROSHeliRepaired = true;
	publicVariable "ROSHeliRepaired";

	// Switch off Fuel truck spotlight and rot orange light when no near heli
	if (vehicle _pilot == _veh) then {
		_wlight hideObjectGlobal true;
		// Switch off orange repair light
		ROS_rothBeaconOn = false;
		publicVariable "ROS_rothBeaconOn";
	};

	if (true) exitWith {true};

}; // End ROS_Repair_heli_fnc


/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


// Find nearest damaged Heli
while {true} do {

	// Look for helis nearby and repair them
	_nearestHeli = objNull;
	_nearestHelis = (nearestObjects [_nHeliPad, ["Helicopter"], 80]) select {_x distance _nHeliPad <80 && alive _x && !isNull driver _x && alive driver _x};
	if (count _nearestHelis >0) then {_nearestHeli = _nearestHelis select 0};
	if (!isNull _nearestHeli) then {

		// Is pad clear - if not remove debris
		_neardead = allDead select {_x distance2d _nHeliPad <15};
		if (count _neardead>0) then {
			["Please hold while we clear the debris"] remoteExec ["hint", (driver _nearestheli)];
			sleep 5;
			{deletevehicle _x; sleep 1;} foreach _neardead;
		};

		_heliDamage = selectMax ((getAllHitPointsDamage _nearestHeli) select 2);
		_heliFuel = fuel _nearestHeli;

		// Max allowed distance from helipad center (cannot be too large - allow for repairer pathing)
		_pDist = 6.5;

		if (!isTouchingGround _nearestHeli && _heliFuel <0.9 or _heliDamage >=0.1) then {
			if !(_ctl) then {
				if (isplayer (driver _nearestHeli)) then {
					[[_nearestheli, (driver _nearestHeli)], ["ClearToLandH", 50]] remoteExec ["say3D", (driver _nearestHeli)];
					sleep 0.2;
					_ctl =true;
				};
			};
		};

		if (isTouchingGround _nearestHeli) then {

			if (_heliFuel <0.9 or _heliDamage >=0.1) then {
				if (_nearestHeli distance2D _nHeliPad >_pDist) then {
					if (isplayer (driver _nearestHeli)) then {
						[format ["You should be <%1m from the center of the pad.\nYou need to move closer to the center.", _pDist]] remoteExec ["hint",(driver _nearestHeli)]};
				};
			};

			if (_heliFuel >=0.9 && _heliDamage <0.1) then {
				if (isplayer (driver _nearestHeli)) then {
					["This vehicle does not need\nto be repaired or refueled.\nPlease vacate the repair bay.\nThank you!"] remoteExec ["hint", (driver _nearestheli)]};
				sleep 5;
				[""] remoteExec ["hint", (driver _nearestheli)];
			};

			//Switch on spotlight on rear of fuel truck
			if (isObjectHidden _wlight) then {_wlight hideObjectGlobal false;};

			// Prepare fuel pipes
			[] call ROS_HeliFuelPipes_Fnc;

			// Start repair if fuel (<0.9) or vehicle damage (any hp>0.1)
			if (_nearestHeli distance2D _nHeliPad <= _pDist && (_heliFuel <0.9 or _heliDamage >=0.1)) then {
				if (isplayer (driver _nearestHeli)) then {
					["Aligning with repair bay"] remoteExec ["hint", (driver _nearestHeli)];
					_nearestHeli setPos (getpos _nHeliPad);
					sleep 1;
					[_hRepairer, _nearestHeli, _initPos, _hitpartType, _hitpartText, _nHeliPad, _ftruck, _wlight] call ROS_Repair_heli_fnc;
					_ctl = false;
				};
			};

			// Switch off orange repair light
			if (ROS_rothBeaconOn) then {
				ROS_rothBeaconOn = false;
				publicVariable "ROS_rothBeaconOn";
			};

			// Clear var nheli
			_nearestHeli = objNull;
			ROSHeliRepaired = false;
			publicVariable "ROSHeliRepaired";
			ROSHeliRefueled = false;
			publicVariable "ROSHeliRefueled";
		}; // istouchingground
	}; // !isnull nearestheli

	sleep 2;

}; // end while

