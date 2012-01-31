
#include "cmdlib.h"
#include "mathlib.h"
#include "bspfile.h"

void main (int argc, char **argv)
{
	int			i;
	char		source[1024];

	if (argc == 1)
		Error ("usage: bspinfo bspfile [bspfiles]");
		
	for (i=1 ; i<argc ; i++)
	{
		printf ("---------------------\n");
		strcpy (source, argv[i]);
		DefaultExtension (source, ".bsp");
		printf ("%s\n", source);
		
		LoadBSPFile (source);		
		PrintBSPFileSizes ();
		printf ("---------------------\n");
	}
}
