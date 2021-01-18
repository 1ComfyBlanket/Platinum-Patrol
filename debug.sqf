if (!isServer) exitWith {};

_track_fnc = {
	_unit = _this select 0;
	
	_track_markerName = format["_track_marker_%1", (name _unit)];
	
	_track_marker = createMarker [str _track_markerName, (getPos _unit)];
	_track_marker setMarkerType "mil_dot";
	_track_marker setMarkerColor "ColorBlue";
	
	while {alive _unit} do {
		if (_unit getVariable ["isHostile",false]) then {
			_track_marker setMarkerColor "ColorRed";
		};
		_track_marker setMarkerPos (position _unit);
		uiSleep 0.1;
	};
	
	deleteMarker (str _track_markerName);
};

while {true} do {
	{
		if (!(_x getVariable ["track_isTracked", false])) then {
			_x setVariable ["track_isTracked", true, false];
			[_x] spawn _track_fnc;
		};
	} forEach allUnits;
	
	_allAI = allunits - playableUnits - switchableUnits;
	_ServerAI = {local _x && simulationEnabled _x} count  _allAI;
	_HCAI = (count _allAI) - ({local _x} count  _allAI);
	[[[_ServerAI,_HCAI,_allAI,PPA_HC_Queue],{
		_ServerAI = _this select 0;
		_HCAI = _this select 1;
		_allAI = _this select 2;
		_PPA_HC_Queue = _this select 3;
		hintSilent format[
			"Total AI: %1\nCached AI: %10\nServer AI: %6\nHC AI: %7/%8\nHC Queue: %9 groups\n\nBLUFOR Groups: %2/144\nOPFOR Groups: %3/144\nINDFOR Groups: %4/144\nCivilian Groups: %5/144",
			count _allAI,										// %1
			{side _x == blufor} count allGroups,				// %2
			{side _x == opfor} count allGroups,					// %3
			{side _x == independent} count allGroups,			// %4
			{side _x == civilian} count allGroups,				// %5
			_ServerAI,											// %6
			_HCAI,												// %7
			PPA_MaxHC,											// %8
			count _PPA_HC_Queue,								// %9
			{!simulationEnabled _x} count _allAI				// %10
			];
	}], "BIS_fnc_spawn", true, false] spawn BIS_fnc_MP;
	uiSleep 1;
};
