
#import <appkit/appkit.h>
#import "mathlib.h"

extern	id zview_i;

// zplane controls the objects displayed in the xyview
extern	float	zplane;
extern	float	zplanedir;

@interface ZView :  View
{
	float		minheight, maxheight;
	float		oldminheight, oldmaxheight;
	float		topbound, bottombound;		// for floor clipping
	
	float		scale;
	
	vec3_t		origin;
}

- clearBounds;
- getBounds: (float *)top :(float *)bottom;

- getPoint: (NXPoint *)pt;
- setPoint: (NXPoint *)pt;

- addToHeightRange: (float)height;

- newRealBounds;
- newSuperBounds;

- XYDrawSelf;

- (BOOL)XYmouseDown: (NXPoint *)pt;

- setXYOrigin: (NXPoint *)pt;

- setOrigin: (NXPoint *)pt scale: (float)sc;

@end

