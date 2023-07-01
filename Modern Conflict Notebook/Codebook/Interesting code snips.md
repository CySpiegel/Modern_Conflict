
I think the **radius** parameter should be treated as a 'minimum distance' from the **centre** position. I found that the parameter name **radius** was not very clear. Also, if **radius** is greater than **max distance** then the function will always return an empty array. Here is an snippet of code I use to find a safe landing zone for an extraction helicopter. It may be useful for someone.
```json
_centre = [getMarkerPos "marker", random 150, random 360] call BIS_fnc_relPos;
_extraction_point = [];
_max_distance = 100;
while { count _extraction_point < 1 } do
{
	_extraction_point = _centre findEmptyPosition [30, _max_distance, "UH60M_EP1"];
	_max_distance = _max_distance + 50;
};
```
In the above example, make sure that "_max_distance" is greater than 30, otherwise the while loop will go forever.