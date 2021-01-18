if (!isServer) exitWith {};

private ["_unit","_spawnTrigger","_patrolTrigger","_pos","_grp","_classType","_diver"];

if (typeName (_this select 0) == "ARRAY") then {
	_spawnTrigger = (_this select 0) select 0;
	_patrolTrigger = (_this select 0) select 1;
} else {
	_spawnTrigger = _this select 0;
	_patrolTrigger = _this select 0;
};
_side = _this select 1;
_wpCount = _this select 2;
_wpSettings = _this select 3;
_wpBehaviour = _wpSettings select 0;
_wpCombat = _wpSettings select 1;
_wpSpeed = _wpSettings select 2;
_infantryClass = _this select 4;
_squadMin = (_this select 5) select 0;
_squadMax = (_this select 5) select 1;
_unitMin = (_this select 6) select 0;
_unitMax = (_this select 6) select 1;
_cache = _this select 7;

// Spawn squads
_squadCount = _squadMin + round(random(_squadMax));
if (_squadCount <= 0) exitWith {};

for "_i" from 1 to _squadCount do {
	switch (_side) do {
		case west: {_diver = "B_Soldier_diver_base_F"};
		case east: {_diver = "O_Soldier_diver_base_F"};
		case resistance: {_diver = "I_Soldier_diver_base_F"};
		case civilian: {_diver = "None"};
	};
	
	waitUntil {{side _x == _side} count allGroups < 144};
	_grp = createGroup _side;
	
	if ({_x isKindOf _diver} count _infantryClass == count _infantryClass) then {
		_classType = "Air";
	} else {
		_classType = "Land";
	};
	
	// Checks position and makes sure it's on ground and not near another object
	if (_classType == "Air") then {
		_pos = [_spawnTrigger] call PPA_Random_Pos;
	} else {
		waitUntil {
			_pos = [_spawnTrigger] call PPA_Random_Pos;
			!surfaceIsWater _pos
		};
	};
	
	_unitCount = _unitMin + round(random(_unitMax));
	for "_i" from 1 to _unitCount do {
		_unit = _grp createUnit [_infantryClass call BIS_fnc_selectRandom, _pos, [], 0, "FORM"];
		[_unit] spawn PPA_Init_Man;
	};
	
	[_grp] spawn PPA_Group_Purge;
	call PPA_Create_Waypoints;
	PPA_HC_Queue pushBack _grp;
	
	[_wpSettings,_grp,_cache] spawn PPA_UnitCache;
};



