// cmdlib.h

#ifndef __CMDLIB__
#define __CMDLIB__

#include <libc.h>
#include <errno.h>
#include <ctype.h>

#define strcmpi strcasecmp
#define stricmp strcasecmp
char *strupr (char *in);
char *strlower (char *in);
int filelength (int handle);
int tell (int handle);

#ifndef __BYTEBOOL__
#define __BYTEBOOL__
typedef enum {false, true} boolean;
typedef unsigned char byte;
#endif

double I_FloatTime (void);

int		GetKey (void);

void	Error (char *error, ...);
int		CheckParm (char *check);

int 	SafeOpenWrite (char *filename);
int 	SafeOpenRead (char *filename);
void 	SafeRead (int handle, void *buffer, long count);
void 	SafeWrite (int handle, void *buffer, long count);
void 	*SafeMalloc (long size);

long	LoadFile (char *filename, void **bufferptr);
void	SaveFile (char *filename, void *buffer, long count);

void 	DefaultExtension (char *path, char *extension);
void 	DefaultPath (char *path, char *basepath);
void 	StripFilename (char *path);
void 	StripExtension (char *path);

void 	ExtractFilePath (char *path, char *dest);
void 	ExtractFileBase (char *path, char *dest);
void	ExtractFileExtension (char *path, char *dest);

long 	ParseNum (char *str);

short	BigShort (short l);
short	LittleShort (short l);
long	BigLong (long l);
long	LittleLong (long l);
float	BigFloat (float l);
float	LittleFloat (float l);

extern	char		com_token[1024];
extern	boolean		com_eof;

char *COM_Parse (char *data);

#endif
