#import <appkit/appkit.h>
#import "SetBrush.h"
#import "EditWindow.h"

extern	id	brush_i;

extern	BOOL	brushdraw;			// YES when drawing cutbrushes and ents

@interface Brush : SetBrush
{
	id			cutbrushes_i;
	id			cutentities_i;
	boolean		updatemask[MAXBRUSHVERTEX];
	BOOL		dontdraw;				// for modal instance loops	
	BOOL		deleted;				// when not visible at all	
}

- init;

- initFromSetBrush: br;

- deselect;
- (BOOL)isSelected;

- (BOOL)XYmouseDown: (NXPoint *)pt;		// return YES if brush handled
- (BOOL)ZmouseDown: (NXPoint *)pt;		// return YES if brush handled

- _keyDown:(NXEvent *)theEvent;

- (NXPoint)centerPoint;						// for camera flyby mode

- InstanceSize;
- XYDrawSelf;
- ZDrawSelf;
- CameraDrawSelf;

- flipHorizontal: sender;
- flipVertical: sender;
- rotate90: sender;

- makeTall: sender;
- makeShort: sender;
- makeWide: sender;
- makeNarrow: sender;

- placeEntity: sender;

- cut: sender;
- copy: sender;

- addBrush;

@end


