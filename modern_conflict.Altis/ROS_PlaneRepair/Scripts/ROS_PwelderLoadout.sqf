params ["_unit"];

if (!local _unit) exitWith {};

comment "Remove existing items";
removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

comment "Add containers";
_unit forceAddUniform "U_I_G_Story_Protagonist_F";
_unit addVest "V_DeckCrew_red_F";

comment "Add items to containers";
_unit addItemToUniform "FirstAidKit";
_unit addItemToUniform "Chemlight_green";
_unit addHeadgear "H_Cap_marshal";
_unit addGoggles "G_Lowprofile";

comment "Add items";
_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit linkItem "ItemWatch";
_unit linkItem "ItemRadio";

comment "Set identity";
[_unit,"WhiteHead_08","male04eng"] call BIS_fnc_setIdentity;
