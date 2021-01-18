call compile preprocessFileLineNumbers "PlatinumPatrol\fnc_universal.sqf";
call compile preprocessFileLineNumbers "PlatinumPatrol\fnc_garrison.sqf";
PPA_Infantry = compile preprocessFileLineNumbers "PlatinumPatrol\fnc_infantry.sqf";
PPA_Vehicle = compile preprocessFileLineNumbers "PlatinumPatrol\fnc_vehicle.sqf";
PPA_SpawnCrew = compile preprocessFileLineNumbers "PlatinumPatrol\fnc_spawnCrew.sqf";
PPA_UnitCache = compile preprocessFileLineNumbers "PlatinumPatrol\fnc_cache.sqf";
PPA_Init_Man = compile preprocessFileLineNumbers "PlatinumPatrol\init_man.sqf";
PPA_Init_Vehicle = compile preprocessFileLineNumbers "PlatinumPatrol\init_vehicle.sqf";

if (isServer) then {
	PPA_Center_West = createCenter west;
	PPA_Center_East = createCenter east;
	PPA_Center_Civilian = createCenter civilian;
	PPA_Center_Resistance = createCenter resistance;
	
	// Dead units are still considered part of a group (thus the group can't be deleted) so they are moved to
	// to this trash group to empty it out their old one. This is so their bodies don't have to be deleted.
	PPA_Group_Trashcan = createGroup civilian;
};

// Max amount of units sent to the headless clients. This depends on server to server, but for a3g the limit
// is little over 100. This maximum limit is per client, not total. i.e. two headless clients means twice as many
// units can be taken off the server's back.
PPA_MaxHC = 100;
// Enable the transferring of ownership to players instead of just the headless clients for further performance gains.
// Warning: If a player crashes (same as an HC crashing) the AI local to that player will be frozen until they completely
// drop. For that reason this is off by default, but feel free to use it if your players are generally stable.
PPA_HC_Players = false;
execVM "PlatinumPatrol\fnc_headlessClient.sqf";

// Debug that tracks living units on the map, group count for each side, and headless client information
// Note: Headless client information is only accurate if there is a single headless client and PPA_HC_Players is disabled.
// Otherwise it will just look like everything is pooling into one client. It's only a visual bug. I might fix that some other time.
//execVM "platinumpatrol\debug.sqf";



