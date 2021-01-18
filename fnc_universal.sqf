// Returns a randomized position within the trigger's area.
PPA_Random_Pos = {
	private ["_xr","_yr"];
	
	_trigger = _this select 0;
	
	// Trigger area and type
	_a = triggerArea _trigger select 0;
	_b = triggerArea _trigger select 1;
	_dir = (triggerArea _trigger select 2) * -1;
	_type = triggerArea _trigger select 3;
	
	// Trigger coordinates
	_xt = getPos _trigger select 0;
	_yt = getPos _trigger select 1;
	
	// Generate random pos within trigger's area
	if (_type) then {
		// Rectangle
		_xr = _xt + (random(_a * 2) - _a);
		_yr = _yt + (random(_b * 2) - _b);
	} else {
		// Ellipse
		_rdir = random 360;
		_xr = _xt + (random(_a * 2) - _a) * sin(_rdir);
		_yr = _yt + (random(_b * 2) - _b) * cos(_rdir);
	};
	_xc = _xt + (_xr - _xt) * cos(_dir) - (_yr - _yt) * sin(_dir);
	_yc = _yt + (_xr - _xt) * sin(_dir) + (_yr - _yt) * cos(_dir);
	
	// Return coordinates
	_pos = [_xc,_yc];
	_pos
};

// Get bearing from point A to point B
PPA_Bearing = {
	_pos1 = _this select 0;
	_pos2 = _this select 1;
	
	_deltaX = (getPos _pos1 select 0) - (_pos2 select 0);
	_deltaY = (getPos _pos1 select 1) - (_pos2 select 1);
	_dir = (_deltaX atan2 _deltaY) + 180;
	
	_dir
};

// Waypoints spawned at patrol trigger
PPA_Create_Waypoints = {
	private ["_pos"];
	
	for "_i" from 1 to _wpCount do {
		switch (_classType) do {
			case "Air": {
				_pos = [_patrolTrigger] call PPA_Random_Pos;
			};
			case "Land": {
				waitUntil {
					_pos = [_patrolTrigger] call PPA_Random_Pos;
					!surfaceIsWater _pos
				};
			};
			case "Sea": {
				waitUntil {
					_pos = [_patrolTrigger] call PPA_Random_Pos;
					surfaceIsWater _pos
				};
			};
		};
		_wp =_grp addWaypoint [_pos, 0];
		_wp setWaypointBehaviour _wpBehaviour;
		_wp setWaypointCombatMode _wpCombat;
		_wp setWaypointSpeed _wpSpeed;
		_wp setWaypointType "MOVE";
	};
	
	if (_wpCount > 0) then {
		_wpPos = waypointPosition [_grp, 1];
		_wp =_grp addWaypoint [_wpPos, 0];
		_wp setWaypointBehaviour _wpBehaviour;
		_wp setWaypointCombatMode _wpCombat;
		_wp setWaypointSpeed _wpSpeed;
		_wp setWaypointType "CYCLE";
		
		// Turn unit towards their first waypoint
		_dir = [_unit,_wpPos] call PPA_Bearing;
		if (vehicle _unit != _unit) then {
			(vehicle _unit) setDir _dir;
		} else {
			{_x setDir _dir} forEach (units(group _unit));
		};
	} else {
		if (vehicle _unit != _unit) then {
			(vehicle _unit) setDir (random 360);
		} else {
			{_x setDir (random 360)} forEach (units(group _unit));
		};
	};
};

PPA_Delete_GroupMP = {
	_grp = _this select 0;
	deleteGroup _grp;
};

PPA_Group_Purge = {
	_grp = _this select 0;
	
	waitUntil {uiSleep 1; {alive _x} count (units _grp) == 0 || {_x getVariable ["PPA_Cached",0] == 1} count (units _grp) > 0};
	
	PPA_HC_Queue = PPA_HC_Queue - [_grp];
	
	_time = time + 30;
	waitUntil {
		if (isNull PPA_Group_Trashcan) then {PPA_Group_Trashcan = createGroup civilian};
		
		// Dedicated server ID is always 2, thanks KillzoneKid.
		if (isDedicated) then {
			PPA_Group_Trashcan setGroupOwner 2;
			_grp setGroupOwner 2;
		} else {
			PPA_Group_Trashcan setGroupOwner (owner player);
			_grp setGroupOwner (owner player);
		};
		
		(units _grp) joinSilent PPA_Group_Trashcan;
		deleteGroup _grp;
		
		// DeleteGroup only works on groups local to the client that issued the command.
		if (!local _grp && !isNull _grp) then {
			[[_grp], "PPA_Delete_GroupMP", groupOwner _grp, false] spawn BIS_fnc_MP;
		};
		
		uiSleep 2;
		isNull _grp && time > _time
	};
};

