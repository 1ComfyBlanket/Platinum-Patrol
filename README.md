Platinum Patrol v1.74

Platinum Patrol is an AI spawning script that makes use of the headless client and uses simulation for
caching units to avoid FPS lag spikes from respawning them.

Features:
-Spawn AI randomly inside a trigger's area and to set their waypoints randomly inside
trigger's area. The spawn trigger can be different from the patrol trigger allows for some easy assault
movements.

-Spawn infantry into buildings while retaining their ability to patrol from building position to position.

-Caching uses simulation instead of deleting and respawning units. This prevents the spawning lag spikes.
 Since the units are never deleted they can still be killed by things such as mortars.
 
-AI is automatically assigned to the headless client.

Installation:
1)	Drag the PlatinumPatrol folder into your mission's root folder.

2)	Place the following into your init.sqf:
	call compile preprocessFileLineNumbers "PlatinumPatrol\init_ppa.sqf";
	
Running code on AI:
	Edit the "init_man.sqf" and "init_vehicle.sqf" file to your liking. You can use that to create custom loadouts
	for AI, set their difficulty or do just about anything you need to an AI when it's initialized.
	
Headless client setup:
1) Place a headless client "Unit > Game Logic > Virtual Entities > Headless Client"
2) Make it a playable unit "CONTROL > Playable"
3) Give the unit any name, but be sure to actually give it something otherwise it won't slot in
4) Open the "init_ppa.sqf" file and modify PPA_MaxHC variable to an amount suitable for your headless client.
   100 is the default max handled by the HC as that is the close to the limit for my community's headless client.
   Consult your server admin for info.
5) Optional: Set the PPA_HC_Players variable true to transfer AI to players too. Read the comment above it for more info.
Note: If you need to exclude a type of unit from being transferred to the headless client (i.e. scripting reasons)
	  then add the following to the init_man.sqf: "_unit setVariable ["PPA_NoHC",1];"
	  This will exclude that unit's ENTIRE SQUAD from the headless client due to the way it works, keep this in
	  mind.
Note2: You can add as many headless clients as many clients as your server supports. Just remember
	   to give them variable names.

Add any of the following functions below after you compile the script:

////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Starting Zones and Examples ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

Spawn infantry garrisoned in buildings:

o_infantry = ["O_Soldier_F","O_Soldier_LAT_F","O_Soldier_lite_F"];
[t_hq2,EAST,o_infantry,[0.4,0.2],700] spawn PPA_Garrison;

Parameters:
_this select 0: Name of the trigger used as the spawning area.
_this select 1: Side of the unit. WEST = BLUFOR, EAST = OPFOR, RESISTANCE = INDFOR, CIVILIAN = CIVILIAN
_this select 2: Array of unit class types that will be randomly selected.
_this select 3: Array: [Percentage of buildings in the area that are garrisoned, Percentage of building positions to fill]
				So if you want to garrison 40% of the buildings in an area and each building having 20% of their positions
				filled with a unit you would use the parameter [0.4,0.2] as shown in the example.
				Mind the hardcoded group limit (144 groups per side).
_this select 4: Caching radius in meters. Despawn radius is spawning radius + 100. Set to false to disable caching.


Spawn infantry that patrol their given area:

Notes: If the class array is made entirely of diver-type classes then they will be able to spawn and patrol in water as
       as well as land.

[[Spawn,Patrol],WEST,10,["AWARE","RED","FULL"],["B_Soldier_F"],[4,2],[4,4],1000] spawn PPA_Infantry;

Parameters:
_this select 0: Can either be an array of two trigger, first value (Spawn) is where they spawn and the second
				value (Patrol) is where their waypoints are placed. If instead a single trigger is provided
				not in array, it acts both as the spawning and patroling area.
_this select 1: Side of the unit. WEST = BLUFOR, EAST = OPFOR, RESISTANCE = INDFOR, CIVILIAN = CIVILIAN
_this select 2: Amount of waypoints that is generated.
_this select 3: Waypoint parameters. [BEHAVIOUR,COMBATMODE,SPEED]
				See the Biwiki for possible strings. https://community.bistudio.com/wiki/Category:Command_Group:_Waypoints
_this select 4: Array of infantry class types that will be randomly selected.
_this select 5: Array: Amount of squads that spawn + random amount.
_this select 6: Array: Amount of units that spawn in each squad + random amount.
_this select 7: Boolean: Set to false to disable all forms of caching.
				Float: Enter a number in meters for the caching range to use this script's caching method.
					   Despawn radius is cache range + 500. Recommended for vehicles.

Spawn vehicles that patrol their given area (this can also be used for statics such as HMG turrets):

Notes: You can put spawn any type of vehicle and depending on the type of vehicle it is will determine how it spawns
	   and where the waypoints can be placed. Air vehicles are spawned flying and their waypoints can be anywhere.
	   Ground vehicles spawn on land and their waypoints cannot be in water. Sea vehicles is vice versa.

[[Spawn,Patrol],EAST,10,["AWARE","RED","LIMITED"],[["B_Soldier_F"],["B_MRAP_01_gmg_F"]],[4,2],false] spawn PPA_Vehicle;

Parameters:
_this select 0: Can either be an array of two trigger, first value (Spawn) is where they spawn and the second
				value (Patrol) is where their waypoints are placed. If instead a single trigger is provided
				not in array, it acts both as the spawning and patroling area.
_this select 1: Side of the unit. WEST = BLUFOR, EAST = OPFOR, RESISTANCE = INDFOR, CIVILIAN = CIVILIAN
_this select 2: Amount of waypoints that is generated.
_this select 3: Waypoint parameters. [BEHAVIOUR,COMBATMODE,SPEED]
				See the Biwiki for possible strings. https://community.bistudio.com/wiki/Category:Command_Group:_Waypoints
_this select 4: Array of infantry crew and vehicle class types that will be randomly selected.
_this select 5: Array: Amount of vehicles that spawn + random amount.
_this select 6: Boolean: Set to false to disable all forms of caching.
				Float: Enter a number in meters for the caching range to use this script's caching method.
					   Despawn radius is cache range + 500. Recommended for vehicles.			
				
Changelog:
v1.74
-Removed the garrison patrolling for the sake them not getting stuck in A2 buildings.

v1.73
-Some changes to the garrison script to reset the position of units who get stuck between building waypoints.

v1.72
-Removed the client crashing check since player owned objects can't be touched until they drop out.

v1.71
-Garrisoned units will patrol yet again when transferred to a player.

v1.7
-Unlimited amount of headless clients are supported.
-Players can now act as an AI host for possible performance gains.
-AI is evenly distributed between clients, each respecting their own maximum amount of AI (PPA_MaxHC).
-Same as before, cached AI are local to the server. Only active AI change ownership.

v1.64
-Garrisoned units controlled by the headless client will now patrol in their building again.

v1.63
-Reverted the HC transfer speed change.
-IF the HC crashes and rejoins AI will again be transferred to it.

v1.62
-Added an init_vehicle.sqf for vehicles.
-SQF file name changes.
-Removed CBA requirement.
-Removed ALiVE support.

v1.61
-Fixed bodies going invisible once their squads died.

v1.6
-Caching function rewritten. Now uses EnableSimulationGlobal and HideObjectGlobal method. This prevents the sixth sense
 lag spikes you would get when walking near a zone from units being spawned in. You can also kill cached units (i.e. mortars).
-Vastly improved the speed of transferring AI from the server to the headless client.
-Fixed a bug that would sometimes cause newly spawned ground and sea vehicles to not follow their waypoints until cached.

v1.5
-Destroyed buildings will no longer spawn the garrison inside them, as if they died.
-Integrated the headless client.

v1.4
-Updated the garrison function, syntax has changed. It now filles a percentage of the houses in the area and
 fills a percentage of the positions in the houses based on parameter you give it. It no longer uses a "mega group"
 but now spawns a group per building garrisoned. Mind the hardcoded group limit (144 groups per side).
-Changed the way groups are purged to make it 100% reliable in deleting dead groups.
-Updated the group creation in all scripts to wait until the group count is no longer maxed out.

v1.3
-The script's caching function now also caches waypoints instead of generating new ones every time.
-Fixed the spawning trigger not being used as the spawning location.
-Hopefully improved garrison script so that units will be more inclined to stay in or near their buildings.

v1.2
-Consolidated the vehicle spawning functions into a single function to save space and make it simpler.
-Added the ability to spawn sea units such as divers and boats.
-Changed the syntax to adjust for the changes.
-Improved position checking for vehicle spawns.

v1.1
-Added an alternative caching method mainly intended for vehicles.
-Changed the garrison function to spawn a set number of AI rather than being a chance to spawn at each building position.
 The syntax has changed, check the instructions for the new syntax.

v1.0
-Inital release.
