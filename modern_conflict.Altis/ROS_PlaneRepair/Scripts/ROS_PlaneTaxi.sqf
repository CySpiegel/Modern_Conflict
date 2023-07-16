/*
Plane taxi - into and out of hangars, repair bays or carrier deck - by RickOShay v2.0
Throttle must be zeroed!

TAXI THE PLANE WITH:
Press and hold the W or UP key - to go forward
Press and hold the S or Down key - to reverse
Use Q or E to steer the plane while taxiing

Exiting the plane or throttling up the plane will terminate taxi routine

Part of ROS Plane Repair - called by ROS_PlaneRepair.sqf
[[_plane, _helipad], "ROS_PlaneRepair\scripts\ROS_PlaneTaxi.sqf"] remoteexec ["execVM", _plane];

Usage:
Plane taxi speed limited to 7km/h
Tested with all vanilla planes
Some modded planes that have center of mass set too far back may experience nose up when reversing
To counter this the COM is moved 1m forwards from the object center
*/


params ["_plane", "_helipad"];

// Get default COM and move com forward 1m (prevent nose up)
_defaultCom = getCenterOfMass _plane;
_plane setCenterOfMass [0,1,0];
// Extended pos is used to check if plane is aligned (facing the pad original dir)
_padExtPos = _helipad modelToWorld [0,17,0];

while {(alive _plane or !(isnull driver _plane) or (_plane distance _helipad > 1))} do {

    // Reverse
    if (_plane isKindOf "Plane" && isTouchingGround _plane && isplayer (driver _plane) && speed _plane < 7 && (inputAction "CarBack") ==1) then {
      if ((inputAction "CarBack") ==1) then {hintSilent "Reversing!"};
      _velP = velocity _plane;
      _dirP = direction _plane;
      if ((speed _plane) > -7) then {
        _spdP = -2;
        _plane setVelocity [
            (_velP select 0) + (sin _dirP * _spdP),
            (_velP select 1) + (cos _dirP * _spdP),
            (_velP select 2) - 0.1
        ];
      };
    };

    // Forward
    if (_plane isKindOf "Plane" && isTouchingGround _plane && isplayer (driver _plane) && speed _plane < 7 && (inputAction "CarForward") ==1) then {
      _velP = velocity _plane;
      _dirP = direction _plane;
      if ((speed _plane) > -7) then {
        _spdP = 3.5;
        _plane setVelocity [
            (_velP select 0) + (sin _dirP * _spdP),
            (_velP select 1) + (cos _dirP * _spdP),
            (_velP select 2) - 0.1
        ];
      };
    };

    hintSilent parseText format [
      "<t size='1' align='center' color='#ffffff' shadow='1' shadowColor='#000000'>
      ZERO YOUR THROTTLE!
      <br/><br/>
      Taxi or use keys to center the plane
      <br/>
      on the repair bay (2m)
      <br/><br/>
      <t align='center' color='#ffcc33' shadow='1' shadowColor='#000000'>TAXI KEYS
      <br/>
      </t>
      <br/>
      <t align='center' color='#ffcc33' align='center' shadow='1' shadowColor='#000000'>Forward:        W
      <br/>
      Pushback:     S
      <br/>
      Steer:      Q  or  E
      </t>
      <br/><br/>
      <t size='1' align='center' color='#f39403' shadow='1' shadowColor='#000000'>Distance to center:</t>
      <br/>
      <t size='2' align='center' color='#ff2203' shadow='1' shadowColor='#000000'>%1m</t><br/>",
      (round (_plane distance2D _helipad))
    ];

    sleep 0.001;

    if (_plane distance2D _helipad <=4 && speed _plane <3.5) exitWith {_plane setPosATL (getPosATL _helipad)};

    // Waituntil pilot disembarked or plane at helipad or plane dead
    // (!alive _plane or (isnull driver _plane) or (_plane distance _helipad < 1))
};

[""] remoteexec ["hint", _plane];

// Close RH infopanel
[_plane, [-1]] enableInfoPanelComponent ["right", "TransportFeedDisplayComponent", false];

// Reset default COM
_plane setCenterOfMass [_defaultCom, 0];
