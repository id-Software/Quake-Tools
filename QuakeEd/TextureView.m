
#import "qedefs.h"

/*

NOTE: I am specifically not using cached image reps, because the data is also needed for texturing the views, and a cached rep would waste tons of space.

*/

@implementation TextureView

- init
{
	deselectIndex = -1;
	return self;
}

- setParent:(id)from
{
	parent_i = from;
	return self;
}

- (BOOL)acceptsFirstMouse
{
	return YES;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int		i;
	int		max;
	id		list_i;
	texpal_t *t;
	int		x;
	int		y;
	NXPoint	p;
	NXRect	r;
	int		selected;
	
	selected = [parent_i getSelectedTexture];
	list_i = [parent_i getList];
	PSselectfont("Helvetica-Medium",FONTSIZE);
	PSrotate(0);
	
	PSsetgray(NX_LTGRAY);
	PSrectfill(rects->origin.x, rects->origin.y, 
		rects->size.width, rects->size.height);

	if (!list_i)		// WADfile didn't init
		return self;

	if (deselectIndex != -1)
	{
		t = [list_i elementAt:deselectIndex];
		r = t->r;
		r.origin.x -= TEX_INDENT;
		r.origin.y -= TEX_INDENT;
		r.size.width += TEX_INDENT*2;
		r.size.height += TEX_INDENT*2;
		
		PSsetgray(NXGrayComponent(NX_COLORLTGRAY));
		PSrectfill(r.origin.x, r.origin.y,
			r.size.width, r.size.height);
		p = t->r.origin;
		p.y += TEX_SPACING;
		[t->image drawAt:&p];
		PSsetgray(0);
		x = t->r.origin.x;
		y = t->r.origin.y + 7;
		PSmoveto(x,y);
		PSshow(t->name);
		PSstroke();
		deselectIndex = -1;
	}

	max = [list_i count];
	PSsetgray(0);

	for (i = 0;i < max; i++)
	{
		t = [list_i elementAt:i];
		r = t->r;
		r.origin.x -= TEX_INDENT/2;
		r.size.width += TEX_INDENT;
		r.origin.y += 4;
		if (NXIntersectsRect(&rects[0],&r) == YES &&
			t->display)
		{
			if (selected == i)
			{
				PSsetgray(1);
				PSrectfill(r.origin.x,r.origin.y,
					r.size.width,r.size.height);
				PSsetrgbcolor(1,0,0);
				PSrectstroke(r.origin.x, r.origin.y,
					 r.size.width, r.size.height);
				PSsetgray(0);
			}
			
			p = t->r.origin;
			p.y += TEX_SPACING;
			[t->image drawAt:&p];
			x = t->r.origin.x;
			y = t->r.origin.y + 7;
			PSmoveto(x,y);
			PSshow(t->name);
		}
	}
	PSstroke();
	return self;
}

- deselect
{
	deselectIndex = [parent_i getSelectedTexture];
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		i;
	int		max;
	int		oldwindowmask;
	texpal_t *t;
	id		list;
	NXRect	r;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	list = [parent_i getList];
	max = [list count];
	for (i = 0;i < max; i++)
	{
		t = [list elementAt:i];
		r = t->r;
		if (NXPointInRect(&loc,&r) == YES)
		{
			[self deselect]; 
			[parent_i	setSelectedTexture:i];
			break;
		}
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}

@end
