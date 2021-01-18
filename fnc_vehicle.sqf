if (!isServer) exitWith {};

private ["_unit","_spawnTrigger","_patrolTrigger","_pos","_grp","_classType","_veh"];

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
_infantryClass = (_this select 4) select 0;
_vehicleClass = (_this select 4) select 1;
_squadMin = (_this select 5) select 0;
_squadMax = (_this select 5) select 1;
_cache = _this select 6;

// Spawn squads
_squadCount = _squadMin + round(random(_squadMax));
if (_squadCount <= 0) exitWith {};

for "_i" from 1 to _squadCount do {
	waitUntil {{side _x == _side} count allGroups < 144};
	_grp = createGroup _side;
	
	_className = _vehicleClass call BIS_fnc_selectRandom;
	switch (true) do {
		case (_className isKindOf "Air"): {_classType = "Air"};
		case (_className isKindOf "Ship"): {_classType = "Sea"};
		case ({_className isKindOf _x} count ["Air","Ship"] == 0): {_classType = "Land"};
	};
	
	// Checks position and makes sure it's on ground and not near another object
	switch (_classType) do {
		case "Air": {
			_pos = [_spawnTrigger] call PPA_Random_Pos;
		};
		case "Land": {
			waitUntil {
				_pos = [_spawnTrigger] call PPA_Random_Pos;
				_isFlat = _pos isFlatEmpty [(sizeOf _className) / 2, 0, 0.7, (sizeOf _className), 0, false, _spawnTrigger];
				count _isFlat > 0
			};
		};
		case "Sea": {
			waitUntil {
				_pos = [_spawnTrigger] call PPA_Random_Pos;
				_isFlat = _pos isFlatEmpty [(sizeOf _className) / 2, 0, 0.7, (sizeOf _className), 2, false, _spawnTrigger];
				count _isFlat > 0
			};
		};
	};
	
	if (_classType == "Air") then {
		_veh = createVehicle [_className, _pos, [], 0, "FLY"];
	} else {
		_veh = createVehicle [_className, _pos, [], 0, "NONE"];
	};
	[_veh] spawn PPA_Init_Vehicle;
	
	_crew = [_veh,_grp,false,"",_infantryClass] call PPA_SpawnCrew;
	
	[_grp] spawn PPA_Group_Purge;
	call PPA_Create_Waypoints;
	PPA_HC_Queue pushBack _grp;
	
	if (_veh isKindOf "Plane") then {
		_veh setPosATL [getPosATL _veh select 0, getPosATL _veh select 1, (getPosATL _veh select 2) + 100 + (random 200)];
		_vel = velocity _veh;
		_dir = direction _veh;
		_speed = 100;
		_veh setVelocity [(sin _dir*_speed), (cos _dir*_speed), 0];
	};
	
	[_wpSettings,_grp,_cache] spawn PPA_UnitCache;
};



