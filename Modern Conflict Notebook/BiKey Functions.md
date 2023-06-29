This works fine. I was helped from friend on discord and this post is if someone need this where are: object1(center), 1(min distance from center), 500 (max distance from center), 3 (not closer to any other object) 0 (not in/on water), 10 (targeted gradient), 0 (not on shore).
```json
_newpos = [object1, 1, 500, 3, 0, 10, 0] call BIS_fnc_findSafePos; 
```

