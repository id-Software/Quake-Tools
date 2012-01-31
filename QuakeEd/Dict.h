
#import <appkit/appkit.h>

typedef struct
{
	char	*key;
	char	*value;
} dict_t;

@interface Dict:Storage
{
}

- initFromFile:(FILE *)fp;

- (id) parseMultipleFrom:(char *)value;
- (int) getValueUnits:(char *)key;
- delString:(char *)string fromValue:(char *)key;
- addString:(char *)string toValue:(char *)key;
- (char *)convertListToString:(id)list;
- (char *)getStringFor:(char *)name;
- removeKeyword:(char *)key;
- (unsigned int)getValueFor:(char *)name;
- changeStringFor:(char *)key to:(char *)value;
- (dict_t *) findKeyword:(char *)key;

- writeBlockTo:(FILE *)fp;
- writeFile:(char *)path;

// INTERNAL
- init;
- (id) parseBraceBlock:(FILE *)fp;
- setupMultiple:(char *)value;
- (char *)getNextParameter;

@end

int	GetNextChar(FILE *fp);
void CopyUntilWhitespc(FILE *fp,char *buffer);
void CopyUntilQuote(FILE *fp,char *buffer);
int FindBrace(FILE *fp);
int FindQuote(FILE *fp);
int FindWhitespc(FILE *fp);
int FindNonwhitespc(FILE *fp);

char *FindWhitespcInBuffer(char *buffer);
char *FindNonwhitespcInBuffer(char *buffer);
