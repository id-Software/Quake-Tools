#import "qedefs.h"

id cameraview_i;

BOOL	timedrawing = 0;

@implementation CameraView

/*
==================
initFrame:
==================
*/
- initFrame:(const NXRect *)frameRect
{
	int		size;
	
	[super initFrame: frameRect];
	
	cameraview_i = self;
	
	xa = ya = za = 0;
	
	[self matrixFromAngles];
	
	origin[0] = 64;
	origin[1] = 64;
	origin[2] = 48;
	
	move = 16;
	
	size = bounds.size.width * bounds.size.height;
	zbuffer = malloc (size*4);
	imagebuffer = malloc (size*4);
	
	return self;
}

- setXYOrigin: (NXPoint *)pt
{
	origin[0] = pt->x;
	origin[1] = pt->y;
	return self;
}

- setZOrigin: (float)pt
{
	origin[2] = pt;
	return self;
}

- setOrigin: (vec3_t)org angle: (float)angle
{
	VectorCopy (org, origin);
	ya = angle;
	[self matrixFromAngles];
	return self;
}

- getOrigin: (vec3_t)org
{
	VectorCopy (origin, org);
	return self;
}

- (float)yawAngle
{
	return ya;
}

- upFloor:sender
{
	sb_floor_dir = 1;
	sb_floor_dist = 99999;
	[map_i makeAllPerform: @selector(feetToFloor)];
	if (sb_floor_dist == 99999)
	{
		qprintf ("already on top floor");
		return self;
	}
	qprintf ("up floor");
	origin[2] += sb_floor_dist;
	[quakeed_i updateCamera];
	return self;
}

- downFloor: sender
{
	sb_floor_dir = -1;
	sb_floor_dist = -99999;
	[map_i makeAllPerform: @selector(feetToFloor)];
	if (sb_floor_dist == -99999)
	{
		qprintf ("already on bottom floor");
		return self;
	}
	qprintf ("down floor");
	origin[2] += sb_floor_dist;
	[quakeed_i updateCamera];
	return self;
}

/*
===============================================================================

UI TARGETS

===============================================================================
*/

/*
============
homeView
============
*/
- homeView: sender
{
	xa = za = 0;
	
	[self matrixFromAngles];

	[quakeed_i updateAll];

	qprintf ("homed view angle");
	
	return self;
}

- drawMode: sender
{
	drawmode = [sender selectedCol];
	[quakeed_i updateCamera];
	return self;
}

- setDrawMode: (drawmode_t)mode
{
	drawmode = mode;
	[mode_radio_i selectCellAt:0: mode];
	[quakeed_i updateCamera];
	return self;
}

/*
===============================================================================

TRANSFORMATION METHODS

===============================================================================
*/

- matrixFromAngles
{
	if (xa > M_PI*0.4)
		xa = M_PI*0.4;
	if (xa < -M_PI*0.4)
		xa = -M_PI*0.4;
		
// vpn
	matrix[2][0] = cos(xa)*cos(ya);
	matrix[2][1] = cos(xa)*sin(ya);
	matrix[2][2] = sin(xa);

// vup	
	matrix[1][0] = cos(xa+M_PI/2)*cos(ya);
	matrix[1][1] = cos(xa+M_PI/2)*sin(ya);
	matrix[1][2] = sin(xa+M_PI/2);

// vright
	CrossProduct (matrix[2], matrix[1], matrix[0]);

	return self;
}


- inverseTransform: (vec_t *)invec to:(vec_t *)outvec
{
	vec3_t		inverse[3];
	vec3_t		temp;
	int			i,j;
	
	for (i=0 ; i<3 ; i++)
		for (j=0 ; j<3 ; j++)
			inverse[i][j] = matrix[j][i];
	
	temp[0] = DotProduct(invec, inverse[0]);
	temp[1] = DotProduct(invec, inverse[1]);
	temp[2] = DotProduct(invec, inverse[2]);		

	VectorAdd (temp, origin, outvec);

	return self;
}



/*
===============================================================================

						DRAWING METHODS

===============================================================================
*/

typedef struct
{
	vec3_t	trans;
	int		clipflags;
	vec3_t	screen;			// only valid if clipflags == 0
} campt_t;
#define	CLIP_RIGHT	1
#define	CLIP_LEFT	2
#define	CLIP_TOP	4
#define	CLIP_BOTTOM	8
#define	CLIP_FRONT	16

int		cam_cur;
campt_t	campts[2];

vec3_t	r_matrix[3];
vec3_t	r_origin;
float	mid_x, mid_y;
float	topscale = (240.0/3)/160;
float	bottomscale = (240.0*2/3)/160;

extern	plane_t	frustum[5];

void MakeCampt (vec3_t in, campt_t *pt)
{
	vec3_t		temp;
	float		scale;
	
// transform the points
	VectorSubtract (in, r_origin, temp);
	
	pt->trans[0] = DotProduct(temp, r_matrix[0]);
	pt->trans[1] = DotProduct(temp, r_matrix[1]);
	pt->trans[2] = DotProduct(temp, r_matrix[2]);		

// check clip flags	
	if (pt->trans[2] < 1)
		pt->clipflags = CLIP_FRONT;
	else
		pt->clipflags = 0;

	if (pt->trans[0] > pt->trans[2])
		pt->clipflags |= CLIP_RIGHT;
	else if (-pt->trans[0] > pt->trans[2])
		pt->clipflags |= CLIP_LEFT;
		
	if (pt->trans[1] > pt->trans[2]*topscale )
		pt->clipflags |= CLIP_TOP;
	else if (-pt->trans[1] > pt->trans[2]*bottomscale )
		pt->clipflags |= CLIP_BOTTOM;
		
	if (pt->clipflags)
		return;
		
// project
	scale = mid_x/pt->trans[2];
	pt->screen[0] = mid_x + pt->trans[0]*scale;
	pt->screen[1] = mid_y + pt->trans[1]*scale;
}


void CameraMoveto(vec3_t p)
{
	campt_t	*pt;
	
	if (upath->numberOfPoints > 2048)
		lineflush ();
		
	pt = &campts[cam_cur];
	cam_cur ^= 1;
	MakeCampt (p,pt);
	if (!pt->clipflags)
	{	// onscreen, so move there immediately
		UPmoveto (upath, pt->screen[0], pt->screen[1]);
	}
}

void ClipLine (vec3_t p1, vec3_t p2, int planenum)
{
	float	d, d2, frac;
	vec3_t	new;
	plane_t	*pl;
	float	scale;
	
	if (planenum == 5)
	{	// draw it!
		scale = mid_x/p1[2];
		new[0] = mid_x + p1[0]*scale;
		new[1] = mid_y + p1[1]*scale;
		UPmoveto (upath, new[0], new[1]);
		
		scale = mid_x/p2[2];
		new[0] = mid_x + p2[0]*scale;
		new[1] = mid_y + p2[1]*scale;
		UPlineto (upath, new[0], new[1]);
		return;
	}

	pl = &frustum[planenum];
	
	d = DotProduct (p1, pl->normal) - pl->dist;	
	d2 = DotProduct (p2, pl->normal) - pl->dist;
	if (d <= ON_EPSILON && d2 <= ON_EPSILON)
	{	// off screen
		return;
	}
	
	if (d >= 0 && d2 >= 0)
	{	// on front
		ClipLine (p1, p2, planenum+1);
		return;
	}
	
	frac = d/(d-d2);
	new[0] = p1[0] + frac*(p2[0]-p1[0]);
	new[1] = p1[1] + frac*(p2[1]-p1[1]);
	new[2] = p1[2] + frac*(p2[2]-p1[2]);
	
	if (d > 0)
		ClipLine (p1, new, planenum+1);
	else
		ClipLine (new, p2, planenum+1);
}

int	c_off, c_on, c_clip;

void CameraLineto(vec3_t p)
{
	campt_t		*p1, *p2;
	int			bits;
	
	p2 = &campts[cam_cur];
	cam_cur ^= 1;
	p1 = &campts[cam_cur];
	MakeCampt (p, p2);

	if (p1->clipflags & p2->clipflags)
	{
		c_off++;
		return;		// entirely off screen
	}
	
	bits = p1->clipflags | p2->clipflags;
	
	if (! bits )
	{
		c_on++;
	UPmoveto (upath, p1->screen[0], p1->screen[1]);
		UPlineto (upath, p2->screen[0], p2->screen[1]);
		return;		// entirely on screen
	}
	
// needs to be clipped
	c_clip++;

	ClipLine (p1->trans, p2->trans, 0);
}


/*
=============
drawSolid
=============
*/
- drawSolid
{
	unsigned char	*planes[5];
		
//
// draw it
//
	VectorCopy (origin, r_origin);
	VectorCopy (matrix[0], r_matrix[0]);
	VectorCopy (matrix[1], r_matrix[1]);
	VectorCopy (matrix[2], r_matrix[2]);
	
	r_width = bounds.size.width;
	r_height = bounds.size.height;
	r_picbuffer = imagebuffer;
	r_zbuffer = zbuffer;

	r_drawflat = (drawmode == dr_flat);
	
	REN_BeginCamera ();
	REN_ClearBuffers ();

//
// render the setbrushes
//	
	[map_i makeAllPerform: @selector(CameraRenderSelf)];

//
// display the output
//
	[[self window] setBackingType:NX_RETAINED];
	
	planes[0] = (unsigned char *)imagebuffer;
	NXDrawBitmap(
		&bounds,  
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
	
	
	
	return self;
}


/*
===================
drawWire
===================
*/
- drawWire: (const NXRect *)rect
{
// copy current info to globals for the C callbacks	
	mid_x = bounds.size.width / 2;
	mid_y = 2 * bounds.size.height / 3;

	VectorCopy (origin, r_origin);
	VectorCopy (matrix[0], r_matrix[0]);
	VectorCopy (matrix[1], r_matrix[1]);
	VectorCopy (matrix[2], r_matrix[2]);
	
	r_width = bounds.size.width;
	r_height = bounds.size.height;
	r_picbuffer = imagebuffer;
	r_zbuffer = zbuffer;

	REN_BeginCamera ();
	
// erase window
	NXEraseRect (rect);
	
// draw all entities
	linestart (0,0,0);
	[map_i makeUnselectedPerform: @selector(CameraDrawSelf)];
	lineflush ();

	return self;
}

/*
===================
drawSelf
===================
*/
- drawSelf:(const NXRect *)rects :(int)rectCount
{
	static float	drawtime;	// static to shut up compiler warning

	if (timedrawing)
		drawtime = I_FloatTime ();

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
=============
XYDrawSelf
=============
*/
- XYDrawSelf
{
	
	PSsetrgbcolor (0,0,1.0);
	PSsetlinewidth (0.15);
	PSmoveto (origin[0]-16,origin[1]);
	PSrlineto (16,8);
	PSrlineto (16,-8);
	PSrlineto (-16,-8);
	PSrlineto (-16,8);
	PSrlineto (32,0);
	
	PSmoveto (origin[0],origin[1]);
	PSrlineto (64*cos(ya+M_PI/4), 64*sin(ya+M_PI/4));
	PSmoveto (origin[0],origin[1]);
	PSrlineto (64*cos(ya-M_PI/4), 64*sin(ya-M_PI/4));
	
	PSstroke ();
	
	return self;
}

/*
=============
ZDrawSelf
=============
*/
- ZDrawSelf
{
	PSsetrgbcolor (0,0,1.0);
	PSsetlinewidth (0.15);
	
	PSmoveto (-16,origin[2]);
	PSrlineto (16,8);
	PSrlineto (16,-8);
	PSrlineto (-16,-8);
	PSrlineto (-16,8);
	PSrlineto (32,0);
	
	PSmoveto (-15,origin[2]-47);
	PSrlineto (29,0);
	PSrlineto (0,54);
	PSrlineto (-29,0);
	PSrlineto (0,-54);

	PSstroke ();

	return self;
}


/*
===============================================================================

						XYZ mouse view methods

===============================================================================
*/

/*
================
modalMoveLoop
================
*/
- modalMoveLoop: (NXPoint *)basept :(vec3_t)movemod : converter
{
	vec3_t		originbase;
	NXEvent		*event;
	NXPoint		newpt;
//	NXPoint		brushpt;
	vec3_t		delta;
//	id			ent;
	int			i;
//	vec3_t		temp;
	
	qprintf ("moving camera position");

	VectorCopy (origin, originbase);	
		
//
// modal event loop using instance drawing
//
	goto drawentry;

	while (event->type != NX_LMOUSEUP && event->type != NX_RMOUSEUP)
	{
		//
		// calculate new point
		//
		newpt = event->location;
		[converter convertPoint:&newpt  fromView:NULL];
				
		delta[0] = newpt.x-basept->x;
		delta[1] = newpt.y-basept->y;
		delta[2] = delta[1];		// height change
		
		for (i=0 ; i<3 ; i++)
			origin[i] = originbase[i]+movemod[i]*delta[i];
		
#if 0	// FIXME	
		//
		// if command is down, look towards brush or entity
		//
		if (event->flags & NX_SHIFTMASK)
		{
			ent = [quakemap_i selectedEntity];
			if (ent)
			{
				[ent origin: temp];
				brushpt.x = temp[0];
				brushpt.y = temp[1];
			}
			else
				brushpt = [brush_i centerPoint];
			ya = atan2 (brushpt.y - newpt.y, brushpt.x - newpt.x);
			[self matrixFromAngles];
		}
#endif
					
drawentry:
		//
		// instance draw new frame
		//
		[quakeed_i newinstance];
		[self display];
		
		event = [NXApp getNextEvent: NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK
			| NX_RMOUSEUPMASK | NX_RMOUSEDRAGGEDMASK | NX_APPDEFINEDMASK];
	
		if (event->type == NX_KEYDOWN)
		{
			[self _keyDown: event];
			[self display];
			goto drawentry;
		}
		
	}

	return self;
}

//============================================================================

/*
===============
XYmouseDown
===============
*/
- (BOOL)XYmouseDown: (NXPoint *)pt flags:(int)flags	// return YES if brush handled
{	
	vec3_t		movemod;
	
	if (fabs(pt->x - origin[0]) > 16
	|| fabs(pt->y - origin[1]) > 16 )
		return NO;
	
#if 0	
	if (flags & NX_ALTERNATEMASK)
	{	// up / down drag
		movemod[0] = 0;
		movemod[1] = 0;
		movemod[2] = 1;
	}
	else
#endif
	{	
		movemod[0] = 1;
		movemod[1] = 1;
		movemod[2] = 0;
	}
	
	[self modalMoveLoop: pt : movemod : xyview_i];
	
	return YES;
}


/*
===============
ZmouseDown
===============
*/
- (BOOL)ZmouseDown: (NXPoint *)pt flags:(int)flags	// return YES if brush handled
{	
	vec3_t		movemod;
	
	if (fabs(pt->y - origin[2]) > 16
	|| pt->x < -8 || pt->x > 8 )
		return NO;
		
	movemod[0] = 0;
	movemod[1] = 0;
	movemod[2] = 1;
	
	[self modalMoveLoop: pt : movemod : zview_i];

	return YES;
}


//=============================================================================

/*
===================
viewDrag:
===================
*/
- viewDrag:(NXPoint *)pt
{
	float	dx,dy;
	NXEvent		*event;
	NXPoint		newpt;
	
//
// modal event loop using instance drawing
//
	goto drawentry;

	while (event->type != NX_RMOUSEUP)
	{
		//
		// calculate new point
		//
		newpt = event->location;
		[self convertPoint:&newpt  fromView:NULL];

		dx = newpt.x - pt->x;
		dy = newpt.y - pt->y;
		*pt = newpt;
	
		ya -= dx/bounds.size.width*M_PI/2 * 4;
		xa += dy/bounds.size.width*M_PI/2 * 4;
	
		[self matrixFromAngles];
		
drawentry:
		[quakeed_i newinstance];
		[self display];
		
		event = [NXApp getNextEvent: 
			NX_KEYDOWNMASK | NX_RMOUSEUPMASK | NX_RMOUSEDRAGGEDMASK];
	
		if (event->type == NX_KEYDOWN)
		{
			[self _keyDown: event];
			[self display];
			goto drawentry;
		}
		
	}

	return self;
}


//=============================================================================

/*
===================
mouseDown
===================
*/
- mouseDown:(NXEvent *)theEvent
{
	NXPoint			pt;
	int				i;
	vec3_t			p1, p2;
	float			forward, right, up;
	int				flags;
		
	pt = theEvent->location;
	
	[self convertPoint:&pt  fromView:NULL];

	VectorCopy (origin, p1);
	forward = 160;
	right = pt.x - 160;
	up = pt.y - 240*2/3;
	for (i=0 ; i<3 ; i++)
		p2[i] = forward*matrix[2][i] + up*matrix[1][i] + right*matrix[0][i];
	for (i=0 ; i<3 ; i++)
		p2[i] = p1[i] + 100*p2[i];

	flags = theEvent->flags & (NX_SHIFTMASK | NX_CONTROLMASK | NX_ALTERNATEMASK | NX_COMMANDMASK);

//
// bare click to select a texture
//
	if (flags == 0)
	{
		[map_i getTextureRay: p1 : p2];
		return self;
	}
	
//
// shift click to select / deselect a brush from the world
//
	if (flags == NX_SHIFTMASK)
	{		
		[map_i selectRay: p1 : p2 : NO];
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
	NXPoint			pt;
	int				flags;
		
	pt = theEvent->location;
	
	[self convertPoint:&pt  fromView:NULL];

	flags = theEvent->flags & (NX_SHIFTMASK | NX_CONTROLMASK | NX_ALTERNATEMASK | NX_COMMANDMASK);

//
// click = drag camera
//
	if (flags == 0)
	{
		qprintf ("looking");
		[self viewDrag: &pt];
		qprintf ("");
		return self;
	}		

	qprintf ("bad flags for click");
	NopSound ();
	
	return self;
}

/*
===============
keyDown
===============
*/

#define	KEY_RIGHTARROW		0xae
#define	KEY_LEFTARROW		0xac
#define	KEY_UPARROW			0xad
#define	KEY_DOWNARROW		0xaf


- _keyDown: (NXEvent *)theEvent
{
    int	ch;
	
    ch = tolower(theEvent->data.key.charCode);
	
	switch (ch)
	{
	case 13:
		return self;
		
	case 'a':
	case 'A':
		xa += M_PI/8;
		[self matrixFromAngles];
		[quakeed_i updateCamera];
		return self;
		
	case 'z':
	case 'Z':
		xa -= M_PI/8;
		[self matrixFromAngles];
		[quakeed_i updateCamera];
		return self;
		
	case KEY_RIGHTARROW:
		ya -= M_PI*move/(64*2);
		[self matrixFromAngles];
		[quakeed_i updateCamera];
		break;
		
	case KEY_LEFTARROW:
		ya += M_PI*move/(64*2);
		[self matrixFromAngles];
		[quakeed_i updateCamera];
		break;
		
	case KEY_UPARROW:
		origin[0] += move*cos(ya);
		origin[1] += move*sin(ya);
		[quakeed_i updateCamera];
		break;
		
	case KEY_DOWNARROW:
		origin[0] -= move*cos(ya);
		origin[1] -= move*sin(ya);
		[quakeed_i updateCamera];
		break;
		
	case '.':
		origin[0] += move*cos(ya-M_PI_2);
		origin[1] += move*sin(ya-M_PI_2);
		[quakeed_i updateCamera];
		break;
		
	case ',':
		origin[0] -= move*cos(ya-M_PI_2);
		origin[1] -= move*sin(ya-M_PI_2);
		[quakeed_i updateCamera];
		break;
		
	case 'd':
	case 'D':
		origin[2] += move;
		[quakeed_i updateCamera];
		break;
		
	case 'c':
	case 'C':
		origin[2] -= move;
		[quakeed_i updateCamera];
		break;
		
	}

	
    return self;
}


@end

