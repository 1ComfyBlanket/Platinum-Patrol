if (!isServer) exitWith {};

private ["_units","_grp","_wpArray","_wpPosArray","_cache","_enabled"];

_wpSettings = _this select 0;
_wpBehaviour = _wpSettings select 0;
_wpCombat = _wpSettings select 1;
_wpSpeed = _wpSettings select 2;
_grp = _this select 1;
_cache = _this select 2;
if (typeName _cache == "BOOL") then {
	_cache = 0;
	_enabled = false;
} else {
	_enabled = true;
};

_side = side _grp;
_units = units _grp;

// For some reason ground and sea vehicle will sometimes get stuck and not follow their waypoints until cached.
// It was a long standing problem, just mostly unnoticable since it only affected newly spawned units.
_vehicleWPfix = true;

while {true} do {
	// Trigger to despawn units
	waitUntil {
		uiSleep 1;
		(({_unit = _x; {_unit distance _x < (_cache + 200)} count (switchableUnits + playableUnits) == 0} count (units _grp) == count (units _grp) || {alive _x} count _units == 0) && _enabled) || _vehicleWPfix
	};
	_vehicleWPfix = false;
	
	// If for some reason new units were added to the group from outside of Platinum Patrol.
	{
		if (!(_x in _units)) then {_units = _units + [_x]};
	} forEach (units _grp);

	// Cache waypoints
	_cWp = (currentWaypoint _grp) - 1;
	_wpArray = waypoints _grp;
	for "_i" from 1 to _cWp do {
		_wp = _wpArray select _i;
		_wpArray = _wpArray - [_wp];
		_wpArray pushBack _wp;
	};
	_wpPosArray = [];
	{
		_wpPos = waypointPosition _x;
		if (waypointType _x != "CYCLE") then {
			_wpPosArray pushBack _wpPos;
		};
	} forEach _wpArray;
	
	// Disable simulation
	{
		_x setVariable ["PPA_Cached",1];
		if (alive _x) then {
			_x enableSimulationGlobal false;
			_x hideObjectGlobal true;
			if (vehicle _x != _x) then {
				(vehicle _x) enableSimulationGlobal false;
				(vehicle _x) hideObjectGlobal true;
			};
		};
	} forEach _units;
	
	if ({alive _x} count _units == 0) exitWith {};
	
	// Trigger to respawn units
	waitUntil {
		uiSleep 1;
		{_unit = _x; {_unit distance _x < _cache} count (switchableUnits + playableUnits) > 0} count _units > 0 || {alive _x} count _units == 0 || !_enabled
	};
	if ({alive _x} count _units == 0) exitWith {
		{
			_x enableSimulationGlobal true;
			_x hideObjectGlobal false;
			if (vehicle _x != _x) then {
				(vehicle _x) enableSimulationGlobal true;
				(vehicle _x) hideObjectGlobal false;
			};
		} forEach _units;
	};
	
	waitUntil {{side _x == _side} count allGroups < 144};
	_grp = createGroup _side;
	{
		_x enableSimulationGlobal true;
		_x hideObjectGlobal false;
		if (vehicle _x != _x) then {
			(vehicle _x) enableSimulationGlobal true;
			(vehicle _x) hideObjectGlobal false;
		};
		_x setVariable ["PPA_Cached",0];
		
		// Garrisoned units need to be told to stop again after simulation is re-enabled. There also needs to be a delay.
		_wp = _x getVariable ["PPA_GarrisonUnit",[]];
		if (count _wp > 0 && {_x distance _wp < 10}) then {
			[_x] spawn {
				for "_i" from 1 to 10 do {
					doStop (_this select 0);
					sleep 0.1;
				};
			};
		};
	} forEach _units;
	_units joinSilent _grp;

	// Placing cached waypoints
	for "_i" from 1 to ((count _wpPosArray) - 1) do {
		_wp =_grp addWaypoint [(_wpPosArray select _i), 0];
		_wp setWaypointBehaviour _wpBehaviour;
		_wp setWaypointCombatMode _wpCombat;
		_wp setWaypointSpeed _wpSpeed;
		_wp setWaypointType "MOVE";
	};
	
	// Check if there are waypoints for the group other than their starting waypoint.
	if (count _wpPosArray > 1) then {
		_wpPos = waypointPosition [_grp, 1];
		_wp =_grp addWaypoint [_wpPos, 0];
		_wp setWaypointBehaviour _wpBehaviour;
		_wp setWaypointCombatMode _wpCombat;
		_wp setWaypointSpeed _wpSpeed;
		_wp setWaypointType "CYCLE";
	};
	
	[_grp] spawn PPA_Group_Purge;
	PPA_HC_Queue pushBack _grp;
};

