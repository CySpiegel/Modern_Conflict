
Calling the mission
```c++
[[],"Missions\Humanitarian\missionAir.sqf"] remoteExec ["BIS_fnc_execVM", 0];
```


Mission random Selection calls script file with inline functions.
```c++
if(!isServer) exitWith {};

//_missions = ["arty","cas","convoy","warehouse"] call BIS_fnc_selectRandom; //mission array + Random|

_missions = ["cas"] call BIS_fnc_selectRandom; //mission array + Random|

[_missions] execVM "cys_tasking\airOps\makeAirOps.sqf"; //call mission
```