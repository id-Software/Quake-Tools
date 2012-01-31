// scriplib.h

#ifndef __CMDLIB__
#include "cmdlib.h"
#endif

#define	MAXTOKEN	128

extern	char	token[MAXTOKEN];
extern	char	*scriptbuffer,*script_p,*scriptend_p;
extern	int		grabbed;
extern	int		scriptline;
extern	qboolean	endofscript;


void LoadScriptFile (char *filename);
qboolean GetToken (qboolean crossline);
void UnGetToken (void);
qboolean TokenAvailable (void);


