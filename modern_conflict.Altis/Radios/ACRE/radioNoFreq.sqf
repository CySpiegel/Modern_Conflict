/*
Radio Net Programming.........//
Place this in the init.sqf in the root folder
_nop = [] execVM "radioNoFreq.sqf";
*/ 

params ["_unit", "_localUnitType"];


["ACRE_PRC152", "default", "example1"] call acre_api_fnc_copyPreset;
["ACRE_PRC117F", "default", "example1"] call acre_api_fnc_copyPreset;


// 152 Radio 
["ACRE_PRC152", "default", 1, "description", "Command Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 2, "description", "A Coy Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 3, "description", "8111 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 4, "description", "8111 Cmd Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 5, "description", "Element 1 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 6, "description", "Element 2 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 7, "description", "8112 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 8, "description", "8112 Cmd Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 9, "description", "Element 1 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 10, "description", "Element 2 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 11, "description", "Zeus Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 12, "description", "EOD Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 13, "description", "MPC Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 14, "description", "JTAC"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 15, "description", "Titan Command/Advisory"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 16, "description", "TADN 1"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 17, "description", "TADN 2"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 18, "description", "TADN 3"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 19, "description", "TADN 4"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 20, "description", "TACPORN"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 21, "description", "UNICOM/ATC"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 22, "description", "Common (Air)"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 23, "description", "CSAR"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC152", "default", 24, "description", "ARTY REQN"] call acre_api_fnc_setPresetChannelField;

// 117F Radio
["ACRE_PRC117F", "default", 1, "description", "Hades 1 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 1, "description", "Command Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 2, "description", "A Coy Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 3, "description", "8111 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 4, "description", "8111 Cmd Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 5, "description", "Element 1 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 6, "description", "Element 2 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 7, "description", "8112 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 8, "description", "8112 Cmd Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 9, "description", "Element 1 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 10, "description", "Element 2 Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 11, "description", "Zeus Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 12, "description", "EOD Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 13, "description", "MPC Net"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 14, "description", "JTAC"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 15, "description", "Titan Command/Advisory"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 16, "description", "TADN 1"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 17, "description", "TADN 2"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 18, "description", "TADN 3"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 19, "description", "TADN 4"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 20, "description", "TACPORN"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 21, "description", "UNICOM/ATC"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 22, "description", "Common (Air)"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 23, "description", "CSAR"] call acre_api_fnc_setPresetChannelField;
["ACRE_PRC117F", "default", 24, "description", "ARTY REQN"] call acre_api_fnc_setPresetChannelField;