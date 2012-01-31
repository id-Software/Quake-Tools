
#import <appkit/appkit.h>
#import "mathlib.h"
#import "SetBrush.h"

extern	id xyview_i;

#define	MINSCALE	0.125
#define	MAXSCALE	2.0


extern	vec3_t		xy_viewnormal;		// v_forward for xy view
extern	float		xy_viewdist;		// clip behind this plane

extern	NXRect	xy_draw_rect;

void linestart (float r, float g, float b);
void lineflush (void);
void linecolor (float r, float g, float b);

void XYmoveto (vec3_t pt);
void XYlineto (vec3_t pt);

typedef enum {dr_wire, dr_flat, dr_texture} drawmode_t;


@interface XYView :  View
{
	NXRect		realbounds, newrect, combinedrect;
	NXPoint		midpoint;
	int			gridsize;
	float		scale;

// for textured view
	int			xywidth, xyheight;
	float		*xyzbuffer;
	unsigned	*xypicbuffer;

	drawmode_t	drawmode;

// UI links
	id			mode_radio_i;	
}

- (float)currentScale;

- setModeRadio: m;

- drawMode: sender;
- setDrawMode: (drawmode_t)mode;

- newSuperBounds;
- newRealBounds: (NXRect *)nb;

- addToScrollRange: (float)x :(float)y;
- setOrigin: (NXPoint *)pt scale: (float)sc;
- centerOn: (vec3_t)org;

- drawMode: sender;

- superviewChanged;

- (int)gridsize;
- (float)snapToGrid: (float)f;

@end
