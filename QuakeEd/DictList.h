
#import <appkit/appkit.h>

@interface DictList:List
{
}

- initListFromFile:(FILE *)fp;
- writeListFile:(char *)filename;
- (id) findDictKeyword:(char *)key;

@end
