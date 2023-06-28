if(!isServer) exitWith {}; 
_missions = ["supplydrop"] call BIS_fnc_selectRandom; //mission array + Random
[_missions] execVM "Missions\Humanitarian\init.sqf";  //call mission