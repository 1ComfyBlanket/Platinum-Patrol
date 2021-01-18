_unit = _this select 0;

// Example
/*
_Unit setSkill ["aimingAccuracy",(0.7 + (random 0.3))];
_Unit setSkill ["aimingShake",1];
_Unit setSkill ["spotDistance",(0.5 + (random 0.5))];
_Unit setSkill ["spotTime",1];
_Unit setSkill ["courage",1];
_Unit setSkill ["commanding",1];
_Unit setSkill ["aimingSpeed",1];
_Unit setSkill ["general",1];
_Unit setSkill ["endurance",1];
_Unit setSkill ["reloadSpeed",1];

// Delete the unit 5 minutes after they die and no player is within 500 meters. Useful for corpse removal
// without having bodies disappear next to players. They might need the gear from the dead!
_unit addEventHandler ["Killed",{
	(_this select 0) spawn {
		sleep 280;
		waitUntil {sleep 20; {_this distance _x < 500} count (switchableUnits + playableUnits) == 0};
		deleteVehicle _this;
	};
}];
*/
