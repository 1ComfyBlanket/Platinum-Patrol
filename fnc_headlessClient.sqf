// The setGroupOwner command has to be staggered because it doesn't immediately transfer AI to the HC (latency)
// Thus it can cause multiple groups to be sent to the HC despite it being over the max if they aren't queued like this.

private ["_unitCount","_HC_LeastUnits","_AICount","_client","_return","_HC_Array"];

PPA_HC_Queue = [];
PPA_HC_Array = [];

if (!isMultiplayer) exitWith {};

PPA_HC_AddToArray = {
	_client = _this select 0;
	
	if !(_client in PPA_HC_Array) then {PPA_HC_Array pushBack _client};
};

PPA_HC_AICount = {
	if (PPA_HC_Players) then {
		_HC_Array = PPA_HC_Array + playableUnits + switchableUnits;
	} else {
		_HC_Array = PPA_HC_Array;
	};
	_HC_LeastUnits = [];
	_AICountArray = [];
	{
		_client = _x;
		
		_AICount = {owner _x == owner _client} count (allUnits - playableUnits - switchableUnits);
		_AICountArray pushBack _AICount;
	
		if ({_AICount <= _x} count _AICountArray == count _AICountArray && _client != player) then {
			_HC_LeastUnits = [_client,_AICount];
		};
	} forEach _HC_Array;
	
	_HC_LeastUnits
};

sleep 3;

// Adding headless clients to the array.
if (!hasInterface && !isDedicated) then {
	[[player], "PPA_HC_AddToArray", false, false] spawn BIS_fnc_MP;
};

// The server runs this loop to constantly be checking for new AI groups to add to the headless clients.
if (isServer) then {
	while {true} do {
		waitUntil {
			sleep 3;
			_allAI = allunits - playableUnits - switchableUnits;
			_serverAI = {local _x} count _allAI;
			count PPA_HC_Queue > 0 && _serverAI > 0
		};
		{
			_grp = _x;
			
			_HC_LeastUnits = call PPA_HC_AICount;
			if (count _HC_LeastUnits > 0) then {
				_client = _HC_LeastUnits select 0;
				_AICount = _HC_LeastUnits select 1;
			};
			
			_units = units _grp;
			if (count _HC_LeastUnits > 0 && {_AICount + (count _units) <= PPA_MaxHC && {!simulationEnabled _x} count (units _grp) == 0 && {_x getVariable ["PPA_NoHC",0] == 1} count _units == 0 && {alive _x} count _units > 0 && !isNull _grp && {_x getVariable ["PPA_Cached",0] == 1} count _units == 0 && local _grp && !isNull _client}) then {
				_time = time + 60;
				while {local _grp && !isNull _grp && !isNull _client && time <= _time} do {
					_grp setGroupOwner (owner _client);
					sleep 1;
				};
			};
		} forEach PPA_HC_Queue;
	};
};



