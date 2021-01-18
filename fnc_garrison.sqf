PPA_Garrison_Filter = ["Land_Pier_F","land_nav_pier_c2","land_nav_pier_c2_end","land_nav_pier_c_t20","land_nav_pier_C_R30","land_nav_pier_c"];

PPA_Garrison = {
	if (!isServer) exitWith {};
	
	// Spawn units in buildings

	private ["_rad","_grp","_buildingArray"];

	_trigger = _this select 0;
	_side = _this select 1;
	_infantryClass = _this select 2;
	_squadCount = (_this select 3) select 0;
	_unitCount = (_this select 3) select 1;
	_cache = _this select 4;
	
	_buildingArray = [];

	_a = triggerArea _trigger select 0;
	_b = triggerArea _trigger select 1;
	_type = triggerArea _trigger select 3;

	if (_type) then {
		_rad = ceil(sqrt(_a^2 + _b^2));
	} else {
		_rad = if (_a > _b) then {_a} else {_b};
	};

	_buildings = nearestObjects [_trigger, ["House"], _rad];
	{
		_building = _x;
		
		if ({typeOf _building == _x} count PPA_Garrison_Filter == 0 && [_trigger,_building] call BIS_fnc_inTrigger) then {
			_buildingPos = [_building] call BIS_fnc_buildingPositions;
			if (count _buildingPos > 0) then {
				_buildingArray pushBack [_building,_buildingPos];
			};
		};
	} forEach _buildings;
	
	_squadMax = ceil(_squadCount * (count _buildingArray));
	if (_squadMax != 0) then {
		for "_i" from 1 to _squadMax do {
			if (count _buildingArray == 0) exitWith {};
			_buildingSet = _buildingArray call BIS_fnc_selectRandom;
			_buildingArray = _buildingArray - [_buildingSet];
	
			_building = _buildingSet select 0;
			_buildingPos = _buildingSet select 1;
			_buildingPos_full = _buildingSet select 1;
			
			waitUntil {{side _x == _side} count allGroups < 144};
			_grp = createGroup _side;
			
			_unitMax = ceil(_unitCount * (count _buildingPos));
			if (_unitMax != 0) then {
				for "_i" from 1 to _unitMax do {
					_wp = _buildingPos call BIS_fnc_selectRandom;
					_buildingPos = _buildingPos - [_wp];
					_unit = _grp createUnit [_infantryClass call BIS_fnc_selectRandom, _wp, [], 0, "NONE"];
					doStop _unit;
					_unit setVariable ["PPA_GarrisonUnit",_wp];
					[_unit] spawn PPA_Init_Man;
					//[_unit,_buildingPos_full] spawn PPA_Garrison_Patrol;
				};
			};
			
			[_grp] spawn PPA_Group_Purge;
			PPA_HC_Queue pushBack _grp;
			
			if (typeName _cache != "BOOL") then {
				[["UNCHANGED","NO CHANGE","UNCHANGED"],_grp,_cache] spawn PPA_UnitCache;
			};
		};
	};
};

PPA_Garrison_Patrol = {
	private ["_nearest","_nearestdist"];
	//Patrol in the building
	_unit = _this select 0;
	_buildingPos = _this select 1;
	
	while {alive _unit} do {
		_wp = _buildingPos call BIS_fnc_selectRandom;
		
		_unit doMove _wp;
		if (isMultiplayer && !local _unit) then {
			[[_unit,_wp], "doMove", owner _unit, false] spawn BIS_fnc_MP;
		};
		
		_time = time + 180;
		waitUntil {
			uiSleep 5;
			(_unit distance _wp < 1 || unitReady _unit || time > _time || !alive _unit) && simulationEnabled _unit
		};
		
		if (!alive _unit) exitWith {};
		
		// Check if the unit made it to the waypoint and force them there if they didn't and no player is in the immediate area.
		if (_unit distance _wp > 1 && {_unit distance _x < 100} count (switchableUnits + playableUnits) == 0) then {_unit setPosATL _wp};
		
		doStop _unit;
		
		uiSleep (10 + (random 10));
	};
};


