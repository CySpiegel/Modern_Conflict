if(!isServer) exitWith {}; 
hint "Got Here";
_missions = ["HumanitarianSupply"] call BIS_fnc_selectRandom; //mission array + Random
[_missions] execVM "Missions\Humanitarian\makeHumanitarianOps.sqf";  //call mission