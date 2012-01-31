#import "qedefs.h"

id xyview_i;

id	scalemenu_i, gridmenu_i, scrollview_i, gridbutton_i, scalebutton_i;

vec3_t		xy_viewnormal;		// v_forward for xy view
float		xy_viewdist;		// clip behind this plane

@implementation XYView

/*
==================
initFrame:
==================
*/
- initFrame:(const NXRect *)frameRect
{
	[super initFrame:frameRect];
	[self allocateGState];
	
	NXSetRect (&realbounds, 0,0,0,0);
	
	gridsize = 16;
	scale = 1.0;
	xyview_i = self;
	
	xy_viewnormal[2] = -1;
	xy_viewdist = -1024;
	
//		
// initialize the pop up menus
//
	scalemenu_i = [[PopUpList alloc] init];
	[scalemenu_i setTarget: self];
	[scalemenu_i setAction: @selector(scaleMenuTarget:)];

	[scalemenu_i addItem: "12.5%"];
	[scalemenu_i addItem: "25%"];
	[scalemenu_i addItem: "50%"];
	[scalemenu_i addItem: "75%"];
	[scalemenu_i addItem: "100%"];
	[scalemenu_i addItem: "200%"];
	[scalemenu_i addItem: "300%"];
	[[scalemenu_i itemList] selectCellAt: 4 : 0];
	
	scalebutton_i = NXCreatePopUpListButton(scalemenu_i);


	gridmenu_i = [[PopUpList alloc] init];
	[gridmenu_i setTarget: self];
	[gridmenu_i setAction: @selector(gridMenuTarget:)];

	[gridmenu_i addItem: "grid 1"];
	[gridmenu_i addItem: "grid 2"];
	[gridmenu_i addItem: "grid 4"];
	[gridmenu_i addItem: "grid 8"];
	[gridmenu_i addItem: "grid 16"];
	[gridmenu_i addItem: "grid 32"];
	[gridmenu_i addItem: "grid 64"];
	
	[[gridmenu_i itemList] selectCellAt: 4 : 0];
	
	gridbutton_i = NXCreatePopUpListButton(gridmenu_i);

// initialize the scroll view
	scrollview_i = [[PopScrollView alloc] 
		initFrame: 		frameRect 
		button1: 		scalebutton_i
		button2:		gridbutton_i
	];
	[scrollview_i setLineScroll: 64];
	[scrollview_i setAutosizing: NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];
	
// link objects together
	[[scrollview_i setDocView: self] free];
	
	return scrollview_i;

}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- setModeRadio: m
{ // this should be set from IB, but because I toss myself in a popscrollview
// the connection gets lost
	mode_radio_i = m;
	[mode_radio_i setTarget: self];
	[mode_radio_i setAction: @selector(drawMode:)];
	return self;
}

- drawMode: sender
{
	drawmode = [sender selectedCol];
	[quakeed_i updateXY];
	return self;
}

- setDrawMode: (drawmode_t)mode
{
	drawmode = mode;
	[mode_radio_i selectCellAt:0: mode];
	[quakeed_i updateXY];
	return self;
}


- (float)currentScale
{
	return scale;
}

/*
===================
setOrigin:scale:
===================
*/
- setOrigin: (NXPoint *)pt scale: (float)sc
{
	NXRect		sframe;
	NXRect		newbounds;
	
//
// calculate the area visible in the cliprect
//
	scale = sc;
	
	[superview getFrame: &sframe];
	[superview getFrame: &newbounds];
	newbounds.origin = *pt;
	newbounds.size.width /= scale; 
	newbounds.size.height /= scale; 
	
//
// union with the realbounds
//
	NXUnionRect (&realbounds, &newbounds);

//
// redisplay everything
//
	[quakeed_i disableDisplay];

//
// size this view
//
	[self sizeTo: newbounds.size.width : newbounds.size.height];
	[self setDrawOrigin: newbounds.origin.x : newbounds.origin.y];
	[self moveTo: newbounds.origin.x : newbounds.origin.y];
	
//
// scroll and scale the clip view
//
	[superview setDrawSize
		: sframe.size.width/scale 
		: sframe.size.height/scale];
	[superview setDrawOrigin: pt->x : pt->y];

	[quakeed_i reenableDisplay];
	[scrollview_i display];
	
	return self;
}

- centerOn: (vec3_t)org
{
	NXRect	sbounds;
	NXPoint	mid, delta;
	
	[[xyview_i superview] getBounds: &sbounds];
	
	mid.x = sbounds.origin.x + sbounds.size.width/2;
	mid.y = sbounds.origin.y + sbounds.size.height/2;
	
	delta.x = org[0] - mid.x;
	delta.y = org[1] - mid.y;

	sbounds.origin.x += delta.x;
	sbounds.origin.y += delta.y;
	
	[self setOrigin: &sbounds.origin scale: scale];
	return self;
}

/*
==================
newSuperBounds

When superview is resized
==================
*/
- newSuperBounds
{
	NXRect	r;
	
	[superview getBounds: &r];
	[self newRealBounds: &r];
	
	return self;
}

/*
===================
newRealBounds

Called when the realbounds rectangle is changed.
Should only change the scroll bars, not cause any redraws.
If realbounds has shrunk, nothing will change.
===================
*/
- newRealBounds: (NXRect *)nb
{
	NXRect		sbounds;
	
	realbounds = *nb;
	
//
// calculate the area visible in the cliprect
//
	[superview getBounds: &sbounds];
	NXUnionRect (nb, &sbounds);

//
// size this view
//
	[quakeed_i disableDisplay];

	[self suspendNotifyAncestorWhenFrameChanged:YES];
	[self sizeTo: sbounds.size.width : sbounds.size.height];
	[self setDrawOrigin: sbounds.origin.x : sbounds.origin.y];
	[self moveTo: sbounds.origin.x : sbounds.origin.y];
	[self suspendNotifyAncestorWhenFrameChanged:NO];

	[scrollview_i reflectScroll: superview];
	[quakeed_i reenableDisplay];
	
	[[scrollview_i horizScroller] display];
	[[scrollview_i vertScroller] display];
	
	return self;
}


/*
====================
scaleMenuTarget:

Called when the scaler popup on the window is used
====================
*/

- scaleMenuTarget: sender
{
	char	const	*item;
	NXRect		visrect, sframe;
	float		nscale;
	
	item = [[sender selectedCell] title];
	sscanf (item,"%f",&nscale);
	nscale /= 100;
	
	if (nscale == scale)
		return NULL;
		
// keep the center of the view constant
	[superview getBounds: &visrect];
	[superview getFrame: &sframe];
	visrect.origin.x += visrect.size.width/2;
	visrect.origin.y += visrect.size.height/2;
	
	visrect.origin.x -= sframe.size.width/2/nscale;
	visrect.origin.y -= sframe.size.height/2/nscale;
	
	[self setOrigin: &visrect.origin scale: nscale];
	
	return self;
}

/*
==============
zoomIn
==============
*/
- zoomIn: (NXPoint *)constant
{
	id			itemlist;
	int			selected, numrows, numcollumns;

	NXRect		visrect;
	NXPoint		ofs, new;

//
// set the popup
//
	itemlist = [scalemenu_i itemList];
	[itemlist getNumRows: &numrows numCols:&numcollumns];
	
	selected = [itemlist selectedRow] + 1;
	if (selected >= numrows)
		return NULL;
		
	[itemlist selectCellAt: selected : 0];
	[scalebutton_i setTitle: [[itemlist selectedCell] title]];

//
// zoom the view
//
	[superview getBounds: &visrect];
	ofs.x = constant->x - visrect.origin.x;
	ofs.y = constant->y - visrect.origin.y;
	
	new.x = constant->x - ofs.x / 2;
	new.y = constant->y - ofs.y / 2;

	[self setOrigin: &new scale: scale*2];
	
	return self;
}


/*
==============
zoomOut
==============
*/
- zoomOut: (NXPoint *)constant
{
	id			itemlist;
	int			selected, numrows, numcollumns;

	NXRect		visrect;
	NXPoint		ofs, new;
	
//
// set the popup
//
	itemlist = [scalemenu_i itemList];
	[itemlist getNumRows: &numrows numCols:&numcollumns];
	
	selected = [itemlist selectedRow] - 1;
	if (selected < 0)
		return NULL;
		
	[itemlist selectCellAt: selected : 0];
	[scalebutton_i setTitle: [[itemlist selectedCell] title]];

//
// zoom the view
//
	[superview getBounds: &visrect];
	ofs.x = constant->x - visrect.origin.x;
	ofs.y = constant->y - visrect.origin.y;
	
	new.x = constant->x - ofs.x * 2;
	new.y = constant->y - ofs.y * 2;

	[self setOrigin: &new scale: scale/2];
	
	return self;
}


/*
====================
gridMenuTarget:

Called when the scaler popup on the window is used
====================
*/

- gridMenuTarget: sender
{
	char	const	*item;
	int			grid;
	
	item = [[sender selectedCell] title];
	sscanf (item,"grid %d",&grid);

	if (grid == gridsize)
		return NULL;
		
	gridsize = grid;
	[quakeed_i updateAll];

	return self;
}


/*
====================
snapToGrid
====================
*/
- (float) snapToGrid: (float)f
{
	int		i;
	
	i = rint(f/gridsize);
	
	return i*gridsize;
}

- (int)gridsize
{
	return gridsize;
}



/*
===================
addToScrollRange::
===================
*/
- addToScrollRange: (float)x :(float)y;
{
	if (x < newrect.origin.x)
	{
		newrect.size.width += newrect.origin.x - x;
		newrect.origin.x = x;
	}
	
	if (y < newrect.origin.y)
	{
		newrect.size.height += newrect.origin.y - y;
		newrect.origin.y = y;
	}
	
	if (x > newrect.origin.x + newrect.size.width)
		newrect.size.width += x - (newrect.origin.x+newrect.size.width);
		
	if (y > newrect.origin.y + newrect.size.height)
		newrect.size.height += y - (newrect.origin.y+newrect.size.height);
		
	return self;
}

/*
===================
superviewChanged
===================
*/
- superviewChanged
{	
	[self newRealBounds: &realbounds];
	
	return self;
}


/*
===============================================================================

						DRAWING METHODS

===============================================================================
*/

vec3_t	cur_linecolor;

void linestart (float r, float g, float b)
{
	beginUserPath (upath,NO);
	cur_linecolor[0] = r;
	cur_linecolor[1] = g;
	cur_linecolor[2] = b;
}

void lineflush (void)
{
	if (!upath->numberOfPoints)
		return;
	endUserPath (upath, dps_ustroke);
	PSsetrgbcolor (cur_linecolor[0], cur_linecolor[1], cur_linecolor[2]);
	sendUserPath (upath);
	beginUserPath (upath,NO);
}

void linecolor (float r, float g, float b)
{
	if (cur_linecolor[0] == r && cur_linecolor[1] == g && cur_linecolor[2] == b)
		return;	// do nothing
	lineflush ();
	cur_linecolor[0] = r;
	cur_linecolor[1] = g;
	cur_linecolor[2] = b;
}

void XYmoveto (vec3_t pt)
{
	if (upath->numberOfPoints > 2048)
		lineflush ();
	UPmoveto (upath, pt[0], pt[1]);
}

void XYlineto (vec3_t pt)
{
	UPlineto (upath, pt[0], pt[1]);
}

/*
============
drawGrid

Draws tile markings every 64 units, and grid markings at the grid scale if
the grid lines are greater than or equal to 4 pixels apart

Rect is in global world (unscaled) coordinates
============
*/

- drawGrid: (const NXRect *)rect
{
	int	x,y, stopx, stopy;
	float	top,bottom,right,left;
	char	text[10];
	BOOL	showcoords;
	
	showcoords = [quakeed_i showCoordinates];

	left = rect->origin.x-1;
	bottom = rect->origin.y-1;
	right = rect->origin.x+rect->size.width+2;
	top = rect->origin.y+rect->size.height+2;

	PSsetlinewidth (0.15);

//
// grid
//
// can't just divide by grid size because of negetive coordinate
// truncating direction
//
	if (gridsize >= 4/scale)
	{
		y = floor(bottom/gridsize);
		stopy = floor(top/gridsize);
		x = floor(left/gridsize);
		stopx = floor(right/gridsize);
		
		y *= gridsize;
		stopy *= gridsize;
		x *= gridsize;
		stopx *= gridsize;
		if (y<bottom)
			y+= gridsize;
		if (x<left)
			x+= gridsize;
		if (stopx >= right)
			stopx -= gridsize;
		if (stopy >= top)
			stopy -= gridsize;
			
		beginUserPath (upath,NO);
		
		for ( ; y<=stopy ; y+= gridsize)
			if (y&63)
			{
				UPmoveto (upath, left, y);
				UPlineto (upath, right, y);
			}
	
		for ( ; x<=stopx ; x+= gridsize)
			if (x&63)
			{
				UPmoveto (upath, x, top);
				UPlineto (upath, x, bottom);
			}
		endUserPath (upath, dps_ustroke);
PSsetrgbcolor (0.8,0.8,1.0);	// thin grid color
		sendUserPath (upath);
	
	}

//
// tiles
//
	PSsetgray (0);		// for text

	if (scale > 4.0/64)
	{
		y = floor(bottom/64);
		stopy = floor(top/64);
		x = floor(left/64);
		stopx = floor(right/64);
		
		y *= 64;
		stopy *= 64;
		x *= 64;
		stopx *= 64;
		if (y<bottom)
			y+= 64;
		if (x<left)
			x+= 64;
		if (stopx >= right)
			stopx -= 64;
		if (stopy >= top)
			stopy -= 64;
			
		beginUserPath (upath,NO);
		
		for ( ; y<=stopy ; y+= 64)
		{
			if (showcoords)
			{
				sprintf (text, "%i",y);
				PSmoveto(left,y);
				PSshow(text);
			}
			UPmoveto (upath, left, y);
			UPlineto (upath, right, y);
		}
	
		for ( ; x<=stopx ; x+= 64)
		{
			if (showcoords)
			{
				sprintf (text, "%i",x);
				PSmoveto(x,bottom+2);
				PSshow(text);
			}
			UPmoveto (upath, x, top);
			UPlineto (upath, x, bottom);
		}
	
		endUserPath (upath, dps_ustroke);
		PSsetgray (12.0/16);
		sendUserPath (upath);
	}

	return self;
}

/*
==================
drawWire
==================
*/
- drawWire: (const NXRect *)rects
{
	NXRect	visRect;
	int	i,j, c, c2;
	id	ent, brush;
	vec3_t	mins, maxs;
	BOOL	drawnames;

	drawnames = [quakeed_i showNames];
	
	if ([quakeed_i showCoordinates])	// if coords are showing, update everything
	{
		[self getVisibleRect:&visRect];
		rects = &visRect;
		xy_draw_rect = *rects;
	}

	
	NXRectClip(rects);
		
// erase window
	NXEraseRect (rects);
	
// draw grid
	[self drawGrid: rects];

// draw all entities, world first so entities take priority
	linestart (0,0,0);

	c = [map_i count];
	for (i=0 ; i<c ; i++)
	{
		ent = [map_i objectAt: i];
		c2 = [ent count];
		for (j = c2-1 ; j >=0 ; j--)
		{
			brush = [ent objectAt: j];
			if ( [brush selected] )
				continue;
			if ([brush regioned])
				continue;
			[brush XYDrawSelf];
		}
		if (i > 0 && drawnames)
		{	// draw entity names
			brush = [ent objectAt: 0];
			if (![brush regioned])
			{
				[brush getMins: mins maxs: maxs];
				PSmoveto(mins[0], mins[1]);
				PSsetrgbcolor (0,0,0);
				PSshow([ent valueForQKey: "classname"]);
			}
		}
	}

	lineflush ();
	
// resize if needed
	newrect.origin.x -= gridsize;
	newrect.origin.y -= gridsize;
	newrect.size.width += 2*gridsize;
	newrect.size.height += 2*gridsize;
	if (!NXEqualRect (&newrect, &realbounds))
		[self newRealBounds: &newrect];

	return self;
}


/*
=============
drawSolid
=============
*/
- drawSolid
{
	unsigned char	*planes[5];
	NXRect	visRect;

	[self getVisibleRect:&visRect];

//
// draw the image into imagebuffer
//
	r_origin[0] = visRect.origin.x;
	r_origin[1] = visRect.origin.y;
	
	r_origin[2] = scale/2;	// using Z as a scale for the 2D projection
	
	r_width = visRect.size.width*r_origin[2];
	r_height = visRect.size.height*r_origin[2];
	
	if (r_width != xywidth || r_height != xyheight)
	{
		xywidth = r_width;
		xyheight = r_height;

		if (xypicbuffer)
		{
			free (xypicbuffer);
			free (xyzbuffer);
		}
		xypicbuffer = malloc (r_width*(r_height+1)*4);
		xyzbuffer = malloc (r_width*(r_height+1)*4);
	}
	
	r_picbuffer = xypicbuffer;
	r_zbuffer = xyzbuffer;
	
	REN_BeginXY ();
	REN_ClearBuffers ();

//
// render the entities
//
	[map_i makeAllPerform: @selector(XYRenderSelf)];

//
// display the output
//
	[self lockFocus];
	[[self window] setBackingType:NX_RETAINED];

	planes[0] = (unsigned char *)r_picbuffer;
	NXDrawBitmap(
		&visRect,  
		r_width, 
		r_height,
		8,
		3,
		32,
		r_width*4,
		NO,
		NO,
		NX_RGBColorSpace,
		planes
	);
	
	NXPing ();
	[[self window] setBackingType:NX_BUFFERED];
	[self unlockFocus];
	
	return self;
}

/*
===================
drawSelf
===================
*/
NXRect	xy_draw_rect;
- drawSelf:(const NXRect *)rects :(int)rectCount
{
	static float	drawtime;	// static to shut up compiler warning

	if (timedrawing)
		drawtime = I_FloatTime ();

	xy_draw_rect = *rects;
	newrect.origin.x = newrect.origin.y = 99999;
	newrect.size.width = newrect.size.height = -2*99999;

// setup for text
	PSselectfont("Helvetica-Medium",10/scale);
	PSrotate(0);

	if (drawmode == dr_texture || drawmode == dr_flat)
		[self drawSolid];
	else
		[self drawWire: rects];
	
	if (timedrawing)
	{
		NXPing ();
		drawtime = I_FloatTime() - drawtime;
		printf ("CameraView drawtime: %5.3f\n", drawtime);
	}

	return self;
}



/*
===============================================================================

						USER INTERACTION

===============================================================================
*/

/*
================
dragLoop:
================
*/
static	NXPoint		oldreletive;
- dragFrom: (NXEvent *)startevent 
	useGrid: (BOOL)ug
	callback: (void (*) (float dx, float dy)) callback
{
	NXEvent		*event;
	NXPoint		startpt, newpt;
	NXPoint		reletive, delta;

	startpt = startevent->location;
	[self convertPoint:&startpt  fromView:NULL];
	
	oldreletive.x = oldreletive.y = 0;
	
	if (ug)
	{
		startpt.x = [self snapToGrid: startpt.x];
		startpt.y = [self snapToGrid: startpt.y];
	}
	
	while (1)
	{
		event = [NXApp getNextEvent: NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK
			| NX_RMOUSEUPMASK | NX_RMOUSEDRAGGEDMASK | NX_APPDEFINEDMASK];

		if (event->type == NX_LMOUSEUP || event->type == NX_RMOUSEUP)
			break;
		if (event->type == NX_APPDEFINED)
		{	// doesn't work.  grrr.
			[quakeed_i applicationDefined:event];
			continue;
		}
		
		newpt = event->location;
		[self convertPoint:&newpt  fromView:NULL];

		if (ug)
		{
			newpt.x = [self snapToGrid: newpt.x];
			newpt.y = [self snapToGrid: newpt.y];
		}

		reletive.x = newpt.x - startpt.x;
		reletive.y = newpt.y - startpt.y;
		if (reletive.x == oldreletive.x && reletive.y == oldreletive.y)
			continue;

		delta.x = reletive.x - oldreletive.x;
		delta.y = reletive.y - oldreletive.y;
		oldreletive = reletive;			

		callback (delta.x , delta.y );
		
	}

	return self;
}

//============================================================================


void DragCallback (float dx, float dy)
{
	sb_translate[0] = dx;
	sb_translate[1] = dy;
	sb_translate[2] = 0;

	[map_i makeSelectedPerform: @selector(translate)];
	
	[quakeed_i redrawInstance];
}

- selectionDragFrom: (NXEvent*)theEvent	
{
	qprintf ("dragging selection");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	DragCallback ];
	[quakeed_i updateAll];
	qprintf ("");
	return self;
	
}

//============================================================================

void ScrollCallback (float dx, float dy)
{
	NXRect		basebounds;
	NXPoint		neworg;
	float		scale;
	
	[ [xyview_i superview] getBounds: &basebounds];
	[xyview_i convertRectFromSuperview: &basebounds];

	neworg.x = basebounds.origin.x - dx;
	neworg.y = basebounds.origin.y - dy;
	
	scale = [xyview_i currentScale];
	
	oldreletive.x -= dx;
	oldreletive.y -= dy;
	[xyview_i setOrigin: &neworg scale: scale];
}

- scrollDragFrom: (NXEvent*)theEvent	
{
	qprintf ("scrolling view");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ScrollCallback ];
	qprintf ("");
	return self;
	
}

//============================================================================

vec3_t	direction;

void DirectionCallback (float dx, float dy)
{
	vec3_t	org;
	float	ya;
	
	direction[0] += dx;
	direction[1] += dy;
	
	[cameraview_i getOrigin: org];

	if (direction[0] == org[0] && direction[1] == org[1])
		return;
		
	ya = atan2 (direction[1] - org[1], direction[0] - org[0]);

	[cameraview_i setOrigin: org angle: ya];
	[quakeed_i newinstance];
	[cameraview_i display];
}

- directionDragFrom: (NXEvent*)theEvent	
{
	NXPoint			pt;

	qprintf ("changing camera direction");

	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	direction[0] = pt.x;
	direction[1] = pt.y;
	
	DirectionCallback (0,0);
	
	[self	dragFrom:	theEvent 
			useGrid:	NO
			callback:	DirectionCallback ];
	qprintf ("");
	return self;	
}

//============================================================================

id	newbrush;
vec3_t	neworg, newdrag;

void NewCallback (float dx, float dy)
{
	vec3_t	min, max;
	int		i;
	
	newdrag[0] += dx;
	newdrag[1] += dy;
	
	for (i=0 ; i<3 ; i++)
	{
		if (neworg[i] < newdrag[i])
		{
			min[i] = neworg[i];
			max[i] = newdrag[i];
		}
		else
		{
			min[i] = newdrag[i];
			max[i] = neworg[i];
		}
	}
	
	[newbrush  setMins: min maxs: max];
	
	[quakeed_i redrawInstance];
}

- newBrushDragFrom: (NXEvent*)theEvent	
{
	id				owner;
	texturedef_t	td;
	NXPoint			pt;

	qprintf ("sizing new brush");
	
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	neworg[0] = [self snapToGrid: pt.x];
	neworg[1] = [self snapToGrid: pt.y];
	neworg[2] = [map_i currentMinZ];

	newdrag[0] = neworg[0];
	newdrag[1] = neworg[1];
	newdrag[2] = [map_i currentMaxZ];
	
	owner = [map_i currentEntity];
	
	[texturepalette_i getTextureDef: &td];
	
	newbrush = [[SetBrush alloc] initOwner: owner
		mins: neworg maxs: newdrag texture: &td];
	[owner addObject: newbrush];
	
	[newbrush setSelected: YES];
	
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	NewCallback ];
			
	[newbrush removeIfInvalid];
	
	[quakeed_i updateCamera];
	qprintf ("");
	return self;
	
}

//============================================================================

void ControlCallback (float dx, float dy)
{
	int		i;
	
	for (i=0 ; i<numcontrolpoints ; i++)
	{
		controlpoints[i][0] += dx;
		controlpoints[i][1] += dy;
	}
	
	[[map_i selectedBrush] calcWindings];	
	[quakeed_i redrawInstance];
}

- (BOOL)planeDragFrom: (NXEvent*)theEvent	
{
	NXPoint			pt;
	vec3_t			dragpoint;

	if ([map_i numSelected] != 1)
		return NO;
		
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	dragpoint[0] = pt.x;
	dragpoint[1] = pt.y;
	dragpoint[2] = 2048;
		
	[[map_i selectedBrush] getXYdragface: dragpoint];
	if (!numcontrolpoints)
		return NO;
	
	qprintf ("dragging brush plane");
	
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ControlCallback ];
			
	[[map_i selectedBrush] removeIfInvalid];
	
	[quakeed_i updateAll];

	qprintf ("");
	return YES;
}

- (BOOL)shearDragFrom: (NXEvent*)theEvent	
{
	NXPoint			pt;
	vec3_t			dragpoint;
	vec3_t			p1, p2;
	float			time;
	id				br;
	int				face;
	
	if ([map_i numSelected] != 1)
		return NO;
	br = [map_i selectedBrush];
	
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

// if the XY point is inside the brush, make the point on top
	p1[0] = pt.x;
	p1[1] = pt.y;
	VectorCopy (p1, p2);

	p1[2] = -2048*xy_viewnormal[2];
	p2[2] = 2048*xy_viewnormal[2];

	VectorCopy (p1, dragpoint);
	[br hitByRay: p1 : p2 : &time : &face];

	if (time > 0)
	{
		dragpoint[2] = p1[2] + (time-0.01)*xy_viewnormal[2];
	}
	else
	{
		[br getMins: p1 maxs: p2];
		dragpoint[2] = (p1[2] + p2[2])/2;
	}


	[br getXYShearPoints: dragpoint];
	if (!numcontrolpoints)
		return NO;
	
	qprintf ("dragging brush plane");
	
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ControlCallback ];
			
	[br removeIfInvalid];
	
	[quakeed_i updateAll];
	qprintf ("");
	return YES;
}


/*
===============================================================================

						INPUT METHODS

===============================================================================
*/


/*
===================
mouseDown
===================
*/
- mouseDown:(NXEvent *)theEvent
{
	NXPoint	pt;
	id		ent;
	vec3_t	p1, p2;
	int		flags;
	
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	p1[0] = p2[0] = pt.x;
	p1[1] = p2[1] = pt.y;
	p1[2] = xy_viewnormal[2] * -4096;
	p2[2] = xy_viewnormal[2] * 4096;

	flags = theEvent->flags & (NX_SHIFTMASK | NX_CONTROLMASK | NX_ALTERNATEMASK | NX_COMMANDMASK);
	
//
// shift click to select / deselect a brush from the world
//
	if (flags == NX_SHIFTMASK)
	{		
		[map_i selectRay: p1 : p2 : YES];
		return self;
	}
	
//
// cmd-shift click to set a target/targetname entity connection
//
	if (flags == (NX_SHIFTMASK|NX_COMMANDMASK) )
	{
		[map_i entityConnect: p1 : p2];
		return self;
	}
	
//
// bare click to either drag selection, or rubber band a new brush
//
	if ( flags == 0 )
	{
	// if double click, position Z checker
		if (theEvent->data.mouse.click > 1)
		{
			qprintf ("positioned Z checker");
			[zview_i setPoint: &pt];
			[quakeed_i newinstance];
			[quakeed_i updateZ];
			return self;
		}
		
	// check eye
		if ( [cameraview_i XYmouseDown: &pt flags: theEvent->flags] )
			return self;		// camera move
			
	// check z post
		if ( [zview_i XYmouseDown: &pt] )
			return self;		// z view move

	// check clippers
		if ( [clipper_i XYDrag: &pt] )
			return self;

	// check single plane dragging
		if ( [self planeDragFrom: theEvent] )
			return self;

	// check selection
		ent = [map_i grabRay: p1 : p2];
		if (ent)
			return [self selectionDragFrom: theEvent];
		
		if ([map_i numSelected])
		{
			qprintf ("missed");
			return self;
		}
		
		return [self newBrushDragFrom: theEvent];
	}
	
//
// control click = position and drag camera 
//
	if (flags == NX_CONTROLMASK)
	{
		[cameraview_i setXYOrigin: &pt];
		[quakeed_i newinstance];
		[cameraview_i display];
		[cameraview_i XYmouseDown: &pt flags: theEvent->flags];
		qprintf ("");
		return self;
	}
		
//
// command click = drag Z checker
//
	if (flags == NX_COMMANDMASK)
	{
// check single plane dragging
[self shearDragFrom: theEvent];
return self;

		qprintf ("moving Z checker");
		[zview_i setXYOrigin: &pt];
		[quakeed_i updateAll];
		[zview_i XYmouseDown: &pt];
		qprintf ("");
		return self;
	}

//
// alt click = set entire brush texture
//
	if (flags == NX_ALTERNATEMASK)
	{
		if (drawmode != dr_texture)
		{
			qprintf ("No texture setting except in texture mode!\n");
			NopSound ();
			return self;
		}
		[map_i setTextureRay: p1 : p2 : YES];
		[quakeed_i updateAll];
		return self;
	}
		
//
// ctrl-alt click = set single face texture
//
	if (flags == (NX_CONTROLMASK | NX_ALTERNATEMASK) )
	{
		if (drawmode != dr_texture)
		{
			qprintf ("No texture setting except in texture mode!\n");
			NopSound ();
			return self;
		}
		[map_i setTextureRay: p1 : p2 : NO];
		[quakeed_i updateAll];
		return self;
	}
		
	qprintf ("bad flags for click");
	NopSound ();
	return self;
}

/*
===================
rightMouseDown
===================
*/
- rightMouseDown:(NXEvent *)theEvent
{
	NXPoint	pt;
	int		flags;
		
	pt= theEvent->location;
	[self convertPoint:&pt  fromView:NULL];

	flags = theEvent->flags & (NX_SHIFTMASK | NX_CONTROLMASK | NX_ALTERNATEMASK | NX_COMMANDMASK);

	if (flags == NX_COMMANDMASK)
	{
		return [self scrollDragFrom: theEvent];		
	}

	if (flags == NX_ALTERNATEMASK)
	{
		return [clipper_i XYClick: pt];
	}
	
	if (flags == 0 || flags == NX_CONTROLMASK)
	{
		return [self directionDragFrom: theEvent];
	}
	
	qprintf ("bad flags for click");
	NopSound ();

	return self;
}


@end

