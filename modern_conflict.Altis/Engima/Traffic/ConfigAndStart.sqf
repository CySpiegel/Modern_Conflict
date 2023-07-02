/* 
 * This file contains parameters to config and function call to start an instance of
 * traffic in the mission. The file is edited by the mission developer.
 *
 * See file Engima\Traffic\Documentation.txt for documentation and a full reference of 
 * how to customize and use Engima's Traffic.
 */

private ["_parameters"];

private _civilianVehicLeLimit = ["cys_ambiant_civilian_driving", 1] call BIS_fnc_getParamValue;
private _enemyVehicLeLimit = ["cys_ambiant_enemy_driving", 1] call BIS_fnc_getParamValue;

// Set traffic parameters.
_civ_parameters = [
	["SIDE", civilian],
	["VEHICLES", ["CFP_C_ASIA_Datsun_Pickup_01", "CFP_C_ASIA_Land_Rover_01", "CFP_C_ASIA_MB_4WD_01", "CFP_C_ASIA_Offroad_01", "CFP_C_ASIA_Praga_V3S_01", "CFP_C_ASIA_Skoda_Octavia_01", "CFP_C_ASIA_Ural_01", "CFP_C_ASIA_UAZ_01", "CFP_C_ASIA_SUV_01", "d3s_zil_130_04", "d3s_zil_130_05", "d3s_zil_131_4", "d3s_zil_130_07", "d3s_actros_14_giga", "d3s_maz_7429"]],
	["VEHICLES_COUNT", _civilianVehicLeLimit],
	["MIN_SPAWN_DISTANCE", 800],
	["MAX_SPAWN_DISTANCE", 2500],
	["MIN_SKILL", 0.4],
	["MAX_SKILL", 0.6],
	["AREA_MARKER", "mcaa"],
	["HIDE_AREA_MARKER", true],
	["DEBUG", false]
];


// Set traffic patrols.
_enemy_parameters = [
	["SIDE", OPFOR],
	["VEHICLES", ["CFP_O_IS_Hilux_01", "cfp_o_is_LR_M2", "cfp_o_is_offroad_M2", "cfp_o_is_pickup_PK_flag"]],
	["VEHICLES_COUNT", _enemyVehicLeLimit],
	["MIN_SPAWN_DISTANCE", 800],
	["MAX_SPAWN_DISTANCE", 3500],
	["MIN_SKILL", 0.4],
	["MAX_SKILL", 0.6],
	["AREA_MARKER", "patroll"],
	["HIDE_AREA_MARKER", true],
	["DEBUG", false]
];

// Start an instance of the traffic
if (_civilianVehicLeLimit > 0) then {
	_civ_parameters spawn ENGIMA_TRAFFIC_StartTraffic;
};

if (_enemyVehicLeLimit > 0) then {
	_enemy_parameters spawn ENGIMA_TRAFFIC_StartTraffic;
};


//MIDDLE EASTERN PRESET
//	["VEHICLES", ["C_Quadbike_01_F", "CUP_C_TT650_TK_CIV", "CUP_C_Ikarus_TKC", "CUP_C_Lada_GreenTK_CIV", "CUP_C_Lada_TK2_CIV", "CUP_C_LR_Transport_CTK", "CUP_C_SUV_TK", "CUP_C_UAZ_Unarmed_TK_CIV", "CUP_C_UAZ_Open_TK_CIV", "CUP_C_Ural_Civ_01", "CUP_C_Volha_Blue_TKCIV", "CUP_C_Volha_Gray_TKCIV", "CUP_C_Volha_Limo_TKCIV"]],

//MIDDLE EASTERN PRESET WITH NEW TRUCKS
//["VEHICLES", ["CFP_C_AFRISLAMIC_Datsun_Pickup_Old_01", "CFP_C_AFRISLAMIC_Skoda_White_01", "CFP_C_AFRISLAMIC_Skoda_Green_01", "CFP_C_AFRISLAMIC_Skoda_Blue_01", "d3s_zil_130_04", "d3s_zil_130_05", "d3s_zil_131_4", "d3s_zil_130_07", "d3s_actros_14_giga", "d3s_maz_7429"]],


//EUROPEAN PRESET
//	["VEHICLES", ["CUP_C_Skoda_Blue_CIV", "CUP_C_Skoda_Green_CIV", "CUP_C_Skoda_Red_CIV", "CUP_C_Skoda_White_CIV", "CUP_C_S1203_Militia_CIV", "CUP_C_Datsun_Covered", "CUP_C_Datsun_Plain", "CUP_C_Datsun_Tubeframe", "CUP_C_Golf4_red_Civ", "CUP_C_Ikarus_Chernarus", "CUP_C_Lada_White_CIV", "CUP_C_Lada_Red_CIV", "CUP_C_SUV_CIV", "CUP_C_Ural_Civ_03", "CUP_C_Ural_Open_Civ_03"]],


// MIDDLE EASTERN MIX WITH HORSES

//["VEHICLES", ["C_Quadbike_01_F", "CUP_C_TT650_TK_CIV", "CUP_C_Ikarus_TKC", "CUP_C_Lada_GreenTK_CIV", "CUP_C_Lada_TK2_CIV", "CUP_C_LR_Transport_CTK", "CUP_C_UAZ_Unarmed_TK_CIV", "CUP_C_UAZ_Open_TK_CIV", "CUP_C_Volha_Blue_TKCIV", "CUP_C_Volha_Gray_TKCIV", "CUP_C_Volha_Limo_TKCIV", "CFP_C_AFRISLAMIC_Datsun_Pickup_Old_01", "CFP_C_AFRISLAMIC_Skoda_White_01", "CFP_C_AFRISLAMIC_Skoda_Green_01", "CFP_C_AFRISLAMIC_Skoda_Blue_01", "d3s_zil_130_04", "d3s_zil_130_05", "d3s_zil_131_4", "d3s_zil_130_07", "d3s_actros_14_giga", "d3s_maz_7429"]],

//ASIAN PRESET
////MIDDLE EASTERN PRESET WITH NEW TRUCKS
//["VEHICLES", ["CFP_C_ASIA_Datsun_Pickup_01", "CFP_C_ASIA_Land_Rover_01", "CFP_C_ASIA_MB_4WD_01", "CFP_C_ASIA_Offroad_01", "CFP_C_ASIA_Praga_V3S_01", "CFP_C_ASIA_Skoda_Octavia_01", "CFP_C_ASIA_Ural_01", "CFP_C_ASIA_UAZ_01", "CFP_C_ASIA_SUV_01", "d3s_zil_130_04", "d3s_zil_130_05", "d3s_zil_131_4", "d3s_zil_130_07", "d3s_actros_14_giga", "d3s_maz_7429"]],