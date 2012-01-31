
entity stemp, otemp, s, old;


void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};


float	USED_SPAWN_PARMS = 8;

void() EncodeLevelParms =
{
	other.items = other.items - (other.items & (IT_KEY1 | IT_KEY2) );
	if (other.health > 100)
		other.health = 100;

	parm1 = other.items;
	parm2 = other.health;
	parm3 = other.armorvalue;
	parm4 = other.ammo_shells;
	parm5 = other.ammo_nails;
	parm6 = other.ammo_rockets;
	parm7 = other.weapon;
	parm8 = other.armortype;
};

void() SetNewGameParms =
{
	other = self;
	
	other.health = 100;
	other.ammo_shells = 25;
	other.ammo_nails = 0;
	other.ammo_rockets = 0;
	other.ammo_cells = 0;
	other.items = IT_SHOTGUN | IT_AXE;
	other.weapon = 1;
	other.armortype = 0;
	other.armorvalue = 0;

	EncodeLevelParms ();
};

void() DecodeLevelParms =
{
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.weapon = parm7;
	self.armortype = parm8;
};

void() T_changelevel =
{
	if (other.classname != "player")
		return;
	
	self.nextthink = time + 10;
	self.think = trigger_reactivate;
	self.solid = SOLID_NOT;
	
	EncodeLevelParms ();
	bprint ("\n\n");
	bprint (other.netname);
	bprint (" killed ");
	bprint (ftos(other.killed_monsters));
	bprint (" monsters out of ");
	bprint (ftos(total_monsters));
	bprint ("\n");
	
	bprint ("And found ");	
	bprint (ftos(other.found_secrets));
	bprint (" secrets out of ");
	bprint (ftos(total_secrets));
	bprint ("\n\n");
	changelevel (other, self.map, USED_SPAWN_PARMS);
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ?
When the player touches this, he gets sent to the map listed in the "map" variable.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("chagnelevel trigger doesn't have map");
	
	self.angles = '0 0 0';
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = T_changelevel;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
	else
		self.solid = SOLID_TRIGGER;
};


// the delay time has passed, so activate all targets
void() multi_fire =
{
	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
		self.nextthink = -1;
};

// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		self.enemy.found_secrets = self.enemy.found_secrets + 1;
		WriteByte (self.enemy, SVC_FOUNDSECRET);
	}

	if (self.message)
	{
		if (self.enemy.classname == "player")
		{
			sound (self.enemy, 0, "temp/talk.wav", 1,1);
			centerprint (self.enemy, self.message);
		}
	}
	
	if (self.noise)
		sound (self, 1, self.noise, 1, 1);

// don't trigger again until reset
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;

// either fire now, or after a delay
	if (!self.delay)
	{
		multi_fire ();
		if (self.wait == -1)
			remove(self);
	}
	else
	{
		self.nextthink = time + self.delay;
		self.think = multi_fire;
	}

};

void() multi_killed =
{
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	local	vector	for;

	if (other.classname != "player")
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.angles != '0 0 0')
	{
		makevectors (self.angles);
		for = v_forward;
		makevectors (other.angles);
		if (v_forward * for < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};


/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
	{
		precache_sound ("temp/secret.wav");
		self.noise = "temp/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("temp/talk.wav");
		self.noise = "temp/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
//	self.angles = '0 0 0';
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
			self.solid = SOLID_TRIGGER;
		}
	}
	settriggermodel (self, self.model);

	if (!self.target)
	{
		if (!self.message)
			error ("There is no target set!");
	}
	
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
//	self.classname = "trigger_secret";
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound ("temp/secret.wav");
		self.noise = "temp/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("temp/talk.wav");
		self.noise = "temp/talk.wav";
	}

	trigger_multiple ();
};



void() counter_use =
{
	local string junk;

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count > 4)
				centerprint (activator, "There are mroe to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	if (!self.target)
		error ("There is no target set!");
	self.use = counter_use;
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;

void() random_telesound =
{
	local	float v;
	local	string tmpstr;
		
	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, 1, tmpstr, 1, 1);
};

void() tfog1 = [	0,	tfog2	] {};
void() tfog2 = [	1,	tfog3	] {random_telesound();};
void() tfog3 = [	2,	tfog4	] {};
void() tfog4 = [	3,	tfog5	] {};
void() tfog5 = [	4,	tfog6	] {};
void() tfog6 = [	5,	tfog7	] {};
void() tfog7 = [	6,	tfog8	] {};
void() tfog8 = [	7,	tfog9	] {};
void() tfog9 = [	8,	tfog10	] {};
void() tfog10 = [	9,	tfog11	] {};
void() tfog11 = [ 	9,	tfog11	] {remove(self);};

void(vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.angles = '0 0 0';
	s.movetype = MOVETYPE_NONE;
	s.solid = SOLID_NOT;
	setmodel (s, "sprites/s_telep.spr");

	old = self;
	self = s;
	tfog1 ();
	self = old;
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

	if (other.health)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, 1000);
	}
};

void() tdeath_remove =
{
	remove (self);
	return;
};

void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.origin = org;
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
//	FIX ME (this does not set the size properly)
	setsize (death, '-20 -20 -20', '20 20 20');
	death.touch = tdeath_touch;
	death.nextthink = time + 0.1;
	death.think = tdeath_remove;
	death.owner = death_owner;
};

void() teleport_touch =
{
local entity	t;
local vector	org;


	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

// only teleport living creatures
	if (other.health <= 0)
		return;

// put a tfog where the player was
	spawn_tfog (other.origin);

// FIXME: precalc at awake time
	t = find (world, targetname, self.target);
	if (!t)
		objerror ("couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

	spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

	setorigin (other, t.origin);
	other.angles = t.mangle;
	if (other.classname == "player")
	{
		other.fixangle = 1;		// turn this way immediately
		other.teleport_time = time + 0.7;
		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;
		other.velocity = v_forward * 300;
	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};


/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.
*/
void() trigger_teleport =
{
	self.mangle = self.angles;
	self.angles = '0 0 0';
	setsize (self, self.mins, self.maxs);	
	
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = teleport_touch;
	self.angles = '0 0 0';
	// find the destination 
	if (!self.target)
		objerror ("no target");
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	self.mangle = self.angles;
	self.angles = '0 0 0';
	setsize (self, self.mins, self.maxs);	
	
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = trigger_skill_touch;
	self.angles = '0 0 0';
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		centerprint (other, self.message);
		sound (other, 0, "temp/talk.wav", 1,1);
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	self.mangle = self.angles;
	self.angles = '0 0 0';
	setsize (self, self.mins, self.maxs);	

	precache_sound ("temp/talk.wav");
	
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = trigger_onlyregistered_touch;
	self.angles = '0 0 0';
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.health)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	self.mangle = self.angles;
	self.angles = '0 0 0';
	
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = hurt_touch;
	self.angles = '0 0 0';
	if (!self.dmg)
		self.dmg = 5;
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
float PUSH_ONCE = 1;
void() trigger_push_touch;
void() trigger_push =
{
	
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = trigger_push_touch;
	SetMovedir();
};

void() trigger_push_touch =
{
	if (other.classname == "player")
		other.velocity = 1000 * self.movedir + 400 * '0 0 1';
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	settriggermodel (self, self.model);
	self.touch = trigger_monsterjump_touch;
	SetMovedir();
};

