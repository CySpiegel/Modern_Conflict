params ["_unit"];

removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

_unit forceAddUniform "U_I_G_Story_Protagonist_F";
_unit addVest "V_DeckCrew_red_F";

_unit addItemToUniform "FirstAidKit";
_unit addItemToUniform "Chemlight_green";
_unit addHeadgear "H_Cap_marshal";
_unit addGoggles "G_Lowprofile";

_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit linkItem "ItemWatch";
_unit linkItem "ItemRadio";

[_unit,"WhiteHead_09","male01eng"] call BIS_fnc_setIdentity;
