
#import <appkit/appkit.h>

extern	id	things_i;

#define	ENTITYNAMEKEY	"spawn"

@interface Things:Object
{
	id	entity_browser_i;	// browser
	id	entity_comment_i;	// scrolling text window
	
	id	prog_path_i;
	
	int	lastSelected;	// last row selected in browser

	id	keyInput_i;
	id	valueInput_i;
	id	flags_i;
}

- initEntities;

- newCurrentEntity;
- setSelectedKey:(epair_t *)ep;

- clearInputs;
- (char *)spawnName;

// UI targets
- reloadEntityClasses: sender;
- selectEntity: sender;
- doubleClickEntity: sender;

// Action methods
- addPair:sender;
- delPair:sender;
- setAngle:sender;
- setFlags:sender;


@end
