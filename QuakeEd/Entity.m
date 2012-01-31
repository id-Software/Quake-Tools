
#include "qedefs.h"

@implementation Entity

vec3_t bad_mins = {-8, -8, -8};
vec3_t bad_maxs = {8, 8, 8};

- createFixedBrush: (vec3_t)org
{
	vec3_t	emins, emaxs;
	float	*v, *v2, *color;
	id		new;
	texturedef_t	td;
	
// get class
	new = [entity_classes_i classForName: [self valueForQKey: "classname"]];
	if (new)
	{
		v = [new mins];
		v2 = [new maxs];
	}
	else
	{
		v = bad_mins;
		v2 = bad_maxs;
	}

	color = [new drawColor];

	modifiable = NO;
	memset(&td,0,sizeof(td));
	strcpy (td.texture,"entity");

	VectorAdd (org, v, emins);
	VectorAdd (org, v2, emaxs);
	new = [[SetBrush alloc] initOwner: self mins:emins maxs:emaxs
		texture: &td];
	[new setEntityColor: color];

	[self addObject: new];
	
	return self;
}

- copyFromZone:(NXZone *)zone
{
	id	new, nb;
	epair_t	*e;
	int	i;
		
	new = [[Entity alloc] init];
	[new setModifiable: modifiable];
	
	for (e=epairs ; e ; e=e->next)
	{	// don't copy target and targetname fields
		if (strncmp(e->key,"target",6))
			[new setKey: e->key toValue: e->value];
	}

	for (i=0 ; i<numElements ; i++)
	{
		nb = [[self objectAt: i] copy];
		[nb setParent: new];
		[new addObject: nb];
	}
	
	return new;
}

- initClass: (char *)classname
{
	id		new;
	esize_t	esize;
	char	value[80];
	vec3_t	min, max;
	float	*v;
	
	[super init];
	
	modifiable = YES;

	[self setKey: "classname" toValue:classname];

// get class
	new = [entity_classes_i classForName: [self valueForQKey: "classname"]];
	if (!new)
		esize = esize_model;
	else
		esize = [new esize];
	
// create a brush if needed
	if (esize == esize_fixed)
	{
		v = [new mins];
		[[map_i selectedBrush] getMins: min maxs: max];	
		VectorSubtract (min, v, min);
	
		sprintf (value, "%i %i %i",(int)min[0], (int)min[1], (int)min[2]);
		[self setKey:"origin" toValue: value];

		[self createFixedBrush: min];
	}
	else
		modifiable = YES;
			
	return self;
}


- free
{
	epair_t	*e, *n;
	
	for (e=epairs ; e ; e=n)
	{
		n = e->next;
		free (e);
	}
	return [super free];
}

- (BOOL)modifiable
{
	return modifiable;
}

- setModifiable: (BOOL)m
{
	modifiable = m;
	return self;
}

- removeObject: o
{
	o = [super removeObject: o];
	if (numElements)
		return o;
// the entity is empty, so remove the entire thing
	if ( self == [map_i objectAt: 0])
		return o;	// never remove the world
		
	[map_i removeObject: self];
	[self free];

	return o;
}


- (char *)valueForQKey: (char *)k
{
	epair_t	*e;
	static char	ret[64];
	
	for (e=epairs ; e ; e=e->next)
		if (!strcmp(k,e->key))
		{
			strcpy (ret, e->value);
			return ret;
		}
	return "";
}

- getVector: (vec3_t)v forKey: (char *)k
{
	char	*c;
	
	c = [self valueForQKey: k];

	v[0] = v[1] = v[2] = 0;
		
	sscanf (c, "%f %f %f", &v[0], &v[1], &v[2]);

	return self;
}

- print
{
	epair_t	*e;
	
	for (e=epairs ; e ; e=e->next)
		printf ("%20s : %20s\n",e->key, e->value);

	return self;
}

- setKey:(char *)k toValue:(char *)v
{
	epair_t	*e;

	if (strlen(k) > MAX_KEY)
		Error ("setKey: %s > MAX_KEY", k);
	if (strlen(v) > MAX_VALUE)
		Error ("setKey: %s > MAX_VALUE", v);
		
	while (*k && *k <= ' ')
		k++;
	if (!*k)
		return self;	// don't set NULL values
		
	for (e=epairs ; e ; e=e->next)
		if (!strcmp(k,e->key))
		{
			memset (e->value, 0, sizeof(e->value));
			strcpy (e->value, v);
			return self;
		}

	e = malloc (sizeof(epair_t));
	memset (e, 0, sizeof(epair_t));
	
	strcpy (e->key, k);
	strcpy (e->value, v);
	e->next = epairs;
	epairs = e;
	
	return self;
}

- (int)numPairs
{
	int	i;
	epair_t	*e;
	
	i=0;
	for (e=epairs ; e ; e=e->next)
		i++;
	return i;
}

- (epair_t *)epairs
{
	return epairs;
}

- removeKeyPair: (char *)key
{
	epair_t	*e, *e2;
	
	if (!epairs)
		return self;
	e = epairs;
	if (!strcmp(e->key, key))
	{
		epairs = e->next;
		free (e);
		return self;
	}
	
	for (; e ; e=e->next)
	{
		if (e->next && !strcmp(e->next->key, key))
		{
			e2 = e->next;
			e->next = e2->next;
			free (e2);
			return self;
		}
	}
	
	printf ("WARNING: removeKeyPair: %s not found\n", key);
	return self;	
}


/*
=============
targetname

If the entity does not have a "targetname" key, a unique one is generated
=============
*/
- (char *)targetname
{
	char	*t;
	int		i, count;
	id		ent;
	int		tval, maxt;
	char	name[20];
	
	t = [self valueForQKey: "targetname"];
	if (t && t[0])
		return t;
		
// make a unique name of the form t<number>
	count = [map_i count];
	maxt = 0;
	for (i=1 ; i<count ; i++)
	{
		ent = [map_i objectAt: i];
		t = [ent valueForQKey: "targetname"];
		if (!t || t[0] != 't')
			continue;
		tval = atoi (t+1);
		if (tval > maxt)
			maxt = tval;
	}
	
	sprintf (name,"t%i",maxt+1);
	
	[self setKey: "targetname" toValue: name];
	
	return [self valueForQKey: "targetname"];	// so it's not on the stack
}

/*
==============================================================================

FILE METHODS

==============================================================================
*/

int	nument;

- initFromTokens
{
	char	key[MAXTOKEN];
	id		eclass, brush;
	char	*spawn;
	vec3_t	emins, emaxs;
	vec3_t	org;
	texturedef_t	td;
	esize_t	esize;
	int		i, c;
	float	*color;
	
	[self init];

	if (!GetToken (true))
	{
		[self free];
		return nil;
	}

	if (strcmp (token, "{") )
		Error ("initFromFileP: { not found");
		
	do
	{
		if (!GetToken (true))
			break;
		if (!strcmp (token, "}") )
			break;
		if (!strcmp (token, "{") )
		{	// read a brush
			brush = [[SetBrush alloc] initFromTokens: self];
			[self addObject: brush];
		}
		else
		{	// read a key / value pair
			strcpy (key, token);
			GetToken (false);
			[self setKey: key toValue:token];
		}
	} while (1);
	
	nument++;

// get class
	spawn = [self valueForQKey: "classname"];
	eclass = [entity_classes_i classForName: spawn];

	esize = [eclass esize];

	[self getVector: org forKey: "origin"];
	
	if ([self count] && esize != esize_model)
	{
		printf ("WARNING:Entity with brushes and wrong model type\n"); 
		[self empty];
	}
	
	if (![self count] && esize == esize_model)
	{
		printf ("WARNING:Entity with no brushes and esize_model\n"); 
		[texturepalette_i getTextureDef: &td];
		for (i=0 ; i<3 ; i++)
		{
			emins[i] = org[i] - 8;
			emaxs[i] = org[i] + 8;
		}
		brush = [[SetBrush alloc] initOwner: self mins:emins maxs:emaxs
			texture: &td];
		[self addObject: brush];
	}
	
// create a brush if needed
	if (esize == esize_fixed)
		[self createFixedBrush: org];
	else
		modifiable = YES;

// set all the brush colors
	color = [eclass drawColor];

	c = [self count];
	for (i=0 ; i<c ; i++)
	{
		brush = [self objectAt: i];
		[brush setEntityColor: color];
	}
	
	return self;
}


- writeToFILE: (FILE *)f region:(BOOL)reg;
{
	epair_t	*e;
	int		i;
	id		new;
	char	value[80];
	vec3_t	mins, maxs, org;
	float	*v;
	BOOL	temporg;
	char	oldang[80];
	
	temporg = NO;
	if (reg)
	{
		if ( !strcmp ([self valueForQKey: "classname"], "info_player_start") )
		{	// move the playerstart temporarily to the camera position
			temporg = YES;
			strcpy (oldang, [self valueForQKey: "angle"]);
			sprintf (value, "%i", (int)([cameraview_i yawAngle]*180/M_PI));
			[self setKey: "angle" toValue: value];
		}
		else if ( self != [map_i objectAt: 0] 
		&& [[self objectAt: 0] regioned] )
			return self;	// skip the entire entity definition
	}
	
	fprintf (f,"{\n");

// set an origin epair
	if (!modifiable)
	{
		[[self objectAt: 0] getMins: mins maxs: maxs];
		if (temporg)
		{
			[cameraview_i getOrigin: mins];
			mins[0] -= 16;
			mins[1] -= 16;
			mins[2] -= 48;
		}
		new = [entity_classes_i classForName: 
			[self valueForQKey: "classname"]];
		if (new)
			v = [new mins];
		else
			v = vec3_origin;
			
		VectorSubtract (mins, v, org);
		sprintf (value, "%i %i %i",(int)org[0], (int)org[1], (int)org[2]);
		[self setKey:"origin" toValue: value];
	}
		
	for (e=epairs ; e ; e=e->next)
		fprintf (f,"\"%s\"\t\"%s\"\n", e->key, e->value);
		
// fixed size entities don't save out brushes
	if ( modifiable )
	{
		for (i=0 ; i<numElements ; i++)
			[[self objectAt: i] writeToFILE: f region: reg];
	}
	
	fprintf (f,"}\n");
	
	if (temporg)
		[self setKey: "angle" toValue: oldang];

	return self;
}

/*
==============================================================================

INTERACTION

==============================================================================
*/

@end
