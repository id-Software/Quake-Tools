

#define		MAX_FACES		16

typedef float	vec5_t[5];

typedef struct
{
	int		numpoints;
	vec5_t	points[8];			// variable sized
} winding_t;

#define MAX_POINTS_ON_WINDING	64

typedef struct
{
	vec3_t		normal;
	float		dist;
} plane_t;

typedef struct
{
// implicit rep
	vec3_t			planepts[3];
	texturedef_t	texture;

// cached rep
	plane_t			plane;
	qtexture_t		*qtexture;
	float			light;		// 0 - 1.0
	winding_t		*w;
} face_t;

#define	ON_EPSILON		0.1
#define	FP_EPSILON		0.01
#define	VECTOR_EPSILON	0.0001

#define	SIDE_FRONT		0
#define	SIDE_BACK		1
#define	SIDE_ON			2


winding_t *ClipWinding (winding_t *in, plane_t *split);
winding_t	*CopyWinding (winding_t *w);
winding_t *NewWinding (int points);


@interface SetBrush : Object
{
	BOOL		regioned;		// not active
	BOOL		selected;

	BOOL		invalid;		// not a proper polyhedron

	id			parent;			// the entity this brush is in
	vec3_t		bmins, bmaxs;
	vec3_t		entitycolor;
	int			numfaces;
	face_t		faces[MAX_FACES];
}

- initOwner: own mins:(float *)mins maxs:(float *)maxs texture:(texturedef_t *)tex;
- initFromTokens: own;
- setMins:(float *)mins maxs:(float *)maxs;

- parent;
- setParent: (id)p;

- setEntityColor: (vec3_t)color;

- calcWindings;

- writeToFILE: (FILE *)f region: (BOOL)reg;

- (BOOL)selected;
- (BOOL)regioned;
- setSelected: (BOOL)s;
- setRegioned: (BOOL)s;

- getMins: (vec3_t)mins maxs: (vec3_t)maxs;

- (BOOL)containsPoint: (vec3_t)pt;

- freeWindings;
- removeIfInvalid;

extern	vec3_t	region_min, region_max;
- newRegion;

- (texturedef_t *)texturedef;
- (texturedef_t *)texturedefForFace: (int)f;
- setTexturedef: (texturedef_t *)tex;
- setTexturedef: (texturedef_t *)tex forFace:(int)f;

- XYDrawSelf;
- ZDrawSelf;
- CameraDrawSelf;
- XYRenderSelf;
- CameraRenderSelf;

- hitByRay: (vec3_t)p1 : (vec3_t) p2 : (float *)time : (int *)face;

//
// single brush actions
//
extern	int		numcontrolpoints;
extern	float	*controlpoints[MAX_FACES*3];
- getZdragface: (vec3_t)dragpoint;
- getXYdragface: (vec3_t)dragpoint;
- getXYShearPoints: (vec3_t)dragpoint;

- addFace: (face_t *)f;

//
// multiple brush actions
//
- carveByClipper;

extern	vec3_t	sb_translate;
- translate;

extern	id		carve_in, carve_out;
- select;
- deselect;
- remove;
- flushTextures;

extern	vec3_t	sb_mins, sb_maxs;
- addToBBox;

extern	vec3_t	sel_x, sel_y, sel_z;
extern	vec3_t	sel_org;
- transform;

- flipNormals;

- carve;
- setCarveVars;

extern	id	sb_newowner;
- moveToEntity;

- takeCurrentTexture;

extern	vec3_t	select_min, select_max;
- selectPartial;
- selectComplete;
- regionPartial;
- regionComplete;

extern	float	sb_floor_dir, sb_floor_dist;
- feetToFloor;

- (int) getNumBrushFaces;
- (face_t *)getBrushFace: (int)which;

@end

