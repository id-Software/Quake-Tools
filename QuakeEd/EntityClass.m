
#import "qedefs.h"

@implementation EntityClass

/*

the classname, color triple, and bounding box are parsed out of comments
A ? size means take the exact brush size.

/*QUAKED <classname> (0 0 0) ?
/*QUAKED <classname> (0 0 0) (-8 -8 -8) (8 8 8)

Flag names can follow the size description:

/*QUAKED func_door (0 .5 .8) ? START_OPEN STONE_SOUND DOOR_DONT_LINK GOLD_KEY SILVER_KEY

*/
char	*debugname;
- initFromText: (char *)text
{
	char	*t;
	int		len;
	int		r, i;
	char	parms[256], *p;
	
	[super init];
	
	text += strlen("/*QUAKED ");
	
// grab the name
	text = COM_Parse (text);
	name = malloc (strlen(com_token)+1);
	strcpy (name, com_token);
	debugname = name;
	
// grab the color
	r = sscanf (text," (%f %f %f)", &color[0], &color[1], &color[2]);
	if (r != 3)
		return NULL;
	
	while (*text != ')')
	{
		if (!*text)
			return NULL;
		text++;
	}
	text++;
	
// get the size	
	text = COM_Parse (text);
	if (com_token[0] == '(')
	{	// parse the size as two vectors
		esize = esize_fixed;
		r = sscanf (text,"%f %f %f) (%f %f %f)", &mins[0], &mins[1], &mins[2], &maxs[0], &maxs[1], &maxs[2]);
		if (r != 6)
			return NULL;

		for (i=0 ; i<2 ; i++)
		{
			while (*text != ')')
			{
				if (!*text)
					return NULL;
				text++;
			}
			text++;
		}
	}
	else
	{	// use the brushes
		esize = esize_model;
	}
	
// get the flags
	

// copy to the first /n
	p = parms;
	while (*text && *text != '\n')
		*p++ = *text++;
	*p = 0;
	text++;
	
// any remaining words are parm flags
	p = parms;
	for (i=0 ; i<8 ; i++)
	{
		p = COM_Parse (p);
		if (!p)
			break;
		strcpy (flagnames[i], com_token);
	} 

// find the length until close comment
	for (t=text ; t[0] && !(t[0]=='*' && t[1]=='/') ; t++)
	;
	
// copy the comment block out
	len = t-text;
	comments = malloc (len+1);
	memcpy (comments, text, len);
	comments[len] = 0;
	
	return self;
}

- (esize_t)esize
{
	return esize;
}

- (char *)classname
{
	return name;
}

- (float *)mins
{
	return mins;
}

- (float *)maxs
{
	return maxs;
}

- (float *)drawColor
{
	return color;
}

- (char *)comments
{
	return comments;
}


- (char *)flagName: (unsigned)flagnum
{
	if (flagnum >= MAX_FLAGS)
		Error ("EntityClass flagName: bad number");
	return flagnames[flagnum];
}

@end

//===========================================================================

@implementation EntityClassList

/*
=================
insertEC:
=================
*/
- (void)insertEC: ec
{
	char	*name;
	int		i;
	
	name = [ec classname];
	for (i=0 ; i<numElements ; i++)
	{
		if (strcasecmp (name, [[self objectAt: i] classname]) < 0)
		{
			[self insertObject: ec at:i];
			return;
		}
	}
	[self addObject: ec];
}


/*
=================
scanFile
=================
*/
- (void)scanFile: (char *)filename
{
	int		size;
	char	*data;
	id		cl;
	int		i;
	char	path[1024];
	
	sprintf (path,"%s/%s", source_path, filename);
	
	size = LoadFile (path, (void *)&data);
	
	for (i=0 ; i<size ; i++)
		if (!strncmp(data+i, "/*QUAKED",8))
		{
			cl = [[EntityClass alloc] initFromText: data+i];
			if (cl)
				[self insertEC: cl];
			else
				printf ("Error parsing: %s in %s\n",debugname, filename);
		}
		
	free (data);
}


/*
=================
scanDirectory
=================
*/
- (void)scanDirectory
{
	int		count, i;
	struct direct **namelist, *ent;
	
	[self empty];
	
     count = scandir(source_path, &namelist, NULL, NULL);
	
	for (i=0 ; i<count ; i++)
	{
		ent = namelist[i];
		if (ent->d_namlen <= 3)
			continue;
		if (!strcmp (ent->d_name+ent->d_namlen-3,".qc"))
			[self scanFile: ent->d_name];
	}
}


id	entity_classes_i;


- initForSourceDirectory: (char *)path
{
	[super init];
	
	source_path = path;	
	[self scanDirectory];
	
	entity_classes_i = self;
	
	nullclass = [[EntityClass alloc] initFromText:
"/*QUAKED UNKNOWN_CLASS (0 0.5 0) ?"];

	return self;
}

- (id)classForName: (char *)name
{
	int		i;
	id		o;
	
	for (i=0 ; i<numElements ; i++)
	{
		o = [self objectAt: i];
		if (!strcmp (name,[o classname]) )
			return o;
	}
	
	return nullclass;
}


@end

