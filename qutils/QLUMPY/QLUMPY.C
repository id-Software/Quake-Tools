#define VERSION "2.0"
#include "qlumpy.h"


#define MAXLUMP		0x50000         // biggest possible lump


byte            *byteimage, *lbmpalette;
int              byteimagewidth, byteimageheight;

char            basepath[1024];
char            lumpname[16];

char			destfile[1024];

byte            *lumpbuffer, *lump_p;

qboolean		savesingle;
qboolean		outputcreated;

/*
=============================================================================

							MAIN

=============================================================================
*/

void GrabRaw (void);
void GrabPalette (void);
void GrabPic (void);
void GrabMip (void);
void GrabColormap (void);
void GrabColormap2 (void);

typedef struct
{
	char    *name;
	void    (*function) (void);
} command_t;

command_t       commands[] =
{
	{"palette",GrabPalette},
	{"colormap",GrabColormap},
	{"qpic",GrabPic},
	{"miptex",GrabMip},
	{"raw",GrabRaw},

	{"colormap2",GrabColormap2},

	{NULL,NULL}                     // list terminator
};



/*
==============
LoadScreen
==============
*/
void LoadScreen (char *name)
{
	char	*expanded;

	expanded = ExpandPathAndArchive (name);

	printf ("grabbing from %s...\n",expanded);
	LoadLBM (expanded, &byteimage, &lbmpalette);

	byteimagewidth = bmhd.w;
	byteimageheight = bmhd.h;
}


/*
================
CreateOutput
================
*/
void CreateOutput (void)
{
	outputcreated = true;
//
// create the output wadfile file
//
	NewWad (destfile, false);	// create a new wadfile
}

/*
===============
WriteLump
===============
*/
void WriteLump (int type, int compression)
{
	int		size;
	
	if (!outputcreated)
		CreateOutput ();

//
// dword align the size
//
	while ((int)lump_p&3)
		*lump_p++ = 0;

	size = lump_p - lumpbuffer;
	if (size > MAXLUMP)
		Error ("Lump size exceeded %d, memory corrupted!",MAXLUMP);

//
// write the grabbed lump to the wadfile
//
	AddLump (lumpname,lumpbuffer,size,type, compression);
}

/*
===========
WriteFile

Save as a seperate file instead of as a wadfile lump
===========
*/
void WriteFile (void)
{
	char	filename[1024];
	char	*exp;

	sprintf (filename,"%s/%s.lmp", destfile, lumpname);
	exp = ExpandPath(filename);
	printf ("saved %s\n", exp);
	SaveFile (exp, lumpbuffer, lump_p-lumpbuffer);		
}

/*
================
ParseScript
================
*/
void ParseScript (void)
{
	int			cmd;
	int			size;
	
	do
	{
		//
		// get a command / lump name
		//
		GetToken (true);
		if (endofscript)
			break;
		if (!Q_strcasecmp (token,"$LOAD"))
		{
			GetToken (false);
			LoadScreen (token);
			continue;
		}

		if (!Q_strcasecmp (token,"$DEST"))
		{
			GetToken (false);
			strcpy (destfile, ExpandPath(token));
			continue;
		}

		if (!Q_strcasecmp (token,"$SINGLEDEST"))
		{
			GetToken (false);
			strcpy (destfile, token);
			savesingle = true;
			continue;
		}


		//
		// new lump
		//
		if (strlen(token) >= sizeof(lumpname) )
			Error ("\"%s\" is too long to be a lump name",token);
		memset (lumpname,0,sizeof(lumpname));			
		strcpy (lumpname, token);
		for (size=0 ; size<sizeof(lumpname) ; size++)
			lumpname[size] = tolower(lumpname[size]);

		//
		// get the grab command
		//
		lump_p = lumpbuffer;

		GetToken (false);

		//
		// call a routine to grab some data and put it in lumpbuffer
		// with lump_p pointing after the last byte to be saved
		//
		for (cmd=0 ; commands[cmd].name ; cmd++)
			if ( !Q_strcasecmp(token,commands[cmd].name) )
			{
				commands[cmd].function ();
				break;
			}

		if ( !commands[cmd].name )
			Error ("Unrecognized token '%s' at line %i",token,scriptline);
	
		grabbed++;
		
		if (savesingle)
			WriteFile ();
		else	
			WriteLump (TYP_LUMPY+cmd, 0);
		
	} while (script_p < scriptend_p);
}

/*
=================
ProcessLumpyScript

Loads a script file, then grabs everything from it
=================
*/
void ProcessLumpyScript (char *basename)
{
	char            script[256];

	printf ("qlumpy script: %s\n",basename);
	
//
// create default destination directory
//
	strcpy (destfile, ExpandPath(basename));
	StripExtension (destfile);
	strcat (destfile,".wad");		// unless the script overrides, save in cwd

//
// save in a wadfile by default
//
	savesingle = false;
	grabbed = 0;
	outputcreated = false;
	
	
//
// read in the script file
//
	strcpy (script, basename);
	DefaultExtension (script, ".ls");
	LoadScriptFile (script);
	
	strcpy (basepath, basename);
	
	ParseScript ();				// execute load / grab commands
	
	if (!savesingle)
	{
		WriteWad ();				// write out the wad directory
		printf ("%i lumps grabbed in a wad file\n",grabbed);
	}
	else
		printf ("%i lumps written seperately\n",grabbed);
}


/*
==============================
main
==============================
*/
int main (int argc, char **argv)
{
	int		i;
	
	printf ("\nqlumpy "VERSION" by John Carmack, copyright (c) 1994 Id Software\n");

	if (argc == 1)
		Error ("qlumpy [-archive directory] scriptfile [scriptfile ...]");

	lumpbuffer = malloc (MAXLUMP);

	if (!strcmp(argv[1], "-archive"))
	{
		archive = true;
		strcpy (archivedir, argv[2]);
		printf ("Archiving source to: %s\n", archivedir);
		i = 3;
	}
	else
		i = 1;


	for ( ; i<argc ; i++)
	{
		SetQdirFromPath (argv[i]);
		ProcessLumpyScript (argv[i]);
	}
		
	return 0;
}
