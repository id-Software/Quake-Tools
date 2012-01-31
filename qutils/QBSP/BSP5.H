
// bsp5.h

#include "cmdlib.h"
#include "mathlib.h"
#include "bspfile.h"

typedef struct
{
	vec3_t	normal;
	vec_t	dist;
	int		type;
} plane_t;


#include "map.h"

#define	MAX_THREADS	4

#define	ON_EPSILON	0.05
#define	BOGUS_RANGE	18000

// the exact bounding box of the brushes is expanded some for the headnode
// volume.  is this still needed?
#define	SIDESPACE	24

//============================================================================


typedef struct
{
	int		numpoints;
	vec3_t	points[8];			// variable sized
} winding_t;

#define MAX_POINTS_ON_WINDING	64

winding_t *BaseWindingForPlane (plane_t *p);
void CheckWinding (winding_t *w);
winding_t	*NewWinding (int points);
void		FreeWinding (winding_t *w);
winding_t	*CopyWinding (winding_t *w);
winding_t	*ClipWinding (winding_t *in, plane_t *split, qboolean keepon);
void	DivideWinding (winding_t *in, plane_t *split, winding_t **front, winding_t **back);

//============================================================================
 
#define	MAXEDGES			32
#define	MAXPOINTS			28		// don't let a base face get past this
									// because it can be split more later

typedef struct visfacet_s
{
	struct visfacet_s	*next;
	
	int				planenum;
	int				planeside;	// which side is the front of the face
	int				texturenum;
	int				contents[2];	// 0 = front side

	struct visfacet_s	*original;		// face on node
	int				outputnumber;		// only valid for original faces after
										// write surfaces
	int				numpoints;
	vec3_t			pts[MAXEDGES];		// FIXME: change to use winding_t
	int				edges[MAXEDGES];
} face_t;


typedef struct surface_s
{
	struct surface_s	*next;
	struct surface_s	*original;	// before BSP cuts it up
	int			planenum;
	int			outputplanenum;		// only valid after WriteSurfacePlanes
	vec3_t		mins, maxs;
	qboolean		onnode;				// true if surface has already been used
									// as a splitting node
	face_t		*faces;	// links to all the faces on either side of the surf
} surface_t;


//
// there is a node_t structure for every node and leaf in the bsp tree
//
#define	PLANENUM_LEAF		-1

typedef struct node_s
{
	vec3_t			mins,maxs;		// bounding volume, not just points inside

// information for decision nodes	
	int				planenum;		// -1 = leaf node	
	int				outputplanenum;	// only valid after WriteNodePlanes
	int				firstface;		// decision node only
	int				numfaces;		// decision node only
	struct node_s	*children[2];	// only valid for decision nodes
	face_t			*faces;			// decision nodes only, list for both sides
	
// information for leafs
	int				contents;		// leaf nodes (0 for decision nodes)
	face_t			**markfaces;	// leaf nodes only, point to node faces
	struct portal_s	*portals;
	int				visleafnum;		// -1 = solid
	int				valid;			// for flood filling
	int				occupied;		// light number in leaf for outside filling
} node_t;

//=============================================================================

// brush.c

#define	NUM_HULLS		2				// normal and +16

#define	NUM_CONTENTS	2				// solid and water

typedef struct brush_s
{
	struct brush_s	*next;
	vec3_t			mins, maxs;
	face_t			*faces;
	int				contents;
} brush_t;

typedef struct
{
	vec3_t		mins, maxs;
	brush_t		*brushes;		// NULL terminated list
} brushset_t;

extern	int			numbrushplanes;
extern	plane_t		planes[MAX_MAP_PLANES];

brushset_t *Brush_LoadEntity (entity_t *ent, int hullnum);
int	PlaneTypeForNormal (vec3_t normal);
int	FindPlane (plane_t *dplane, int *side);

//=============================================================================

// csg4.c

// build surfaces is also used by GatherNodeFaces
extern	face_t	*validfaces[MAX_MAP_PLANES];
surface_t *BuildSurfaces (void);

face_t *NewFaceFromFace (face_t *in);
surface_t *CSGFaces (brushset_t *bs);
void SplitFace (face_t *in, plane_t *split, face_t **front, face_t **back);

//=============================================================================

// solidbsp.c

void DivideFacet (face_t *in, plane_t *split, face_t **front, face_t **back);
void CalcSurfaceInfo (surface_t *surf);
void SubdivideFace (face_t *f, face_t **prevptr);
node_t *SolidBSP (surface_t *surfhead, qboolean midsplit);

//=============================================================================

// merge.c

void MergePlaneFaces (surface_t *plane);
face_t *MergeFaceToList (face_t *face, face_t *list);
face_t *FreeMergeListScraps (face_t *merged);
void MergeAll (surface_t *surfhead);

//=============================================================================

// surfaces.c

extern	int		c_cornerverts;
extern	int		c_tryedges;
extern	face_t		*edgefaces[MAX_MAP_EDGES][2];

extern	int		firstmodeledge;
extern	int		firstmodelface;

void SubdivideFaces (surface_t *surfhead);

surface_t *GatherNodeFaces (node_t *headnode);

void MakeFaceEdges (node_t *headnode);

//=============================================================================

// portals.c

typedef struct portal_s
{
	int			planenum;
	node_t		*nodes[2];		// [0] = front side of planenum
	struct portal_s	*next[2];	
	winding_t	*winding;
} portal_t;

extern	node_t	outside_node;		// portals outside the world face this

void PortalizeWorld (node_t *headnode);
void WritePortalfile (node_t *headnode);
void FreeAllPortals (node_t *node);

//=============================================================================

// region.c

void GrowNodeRegions (node_t *headnode);

//=============================================================================

// tjunc.c

void tjunc (node_t *headnode);

//=============================================================================

// writebsp.c

void WriteNodePlanes (node_t *headnode);
void WriteClipNodes (node_t *headnode);
void WriteDrawNodes (node_t *headnode);

void BumpModel (int hullnum);
int FindFinalPlane (dplane_t *p);

void BeginBSPFile (void);
void FinishBSPFile (void);

//=============================================================================

// draw.c

void Draw_ClearBounds (void);
void Draw_AddToBounds (vec3_t v);
void Draw_DrawFace (face_t *f);
void Draw_ClearWindow (void);
void Draw_SetRed (void);
void Draw_SetGrey (void);
void Draw_SetBlack (void);
void DrawPoint (vec3_t v);

void Draw_SetColor (int c);
void SetColor (int c);
void DrawPortal (portal_t *p);
void DrawLeaf (node_t *l, int color);
void DrawBrush (brush_t *b);

void DrawWinding (winding_t *w);
void DrawTri (vec3_t p1, vec3_t p2, vec3_t p3);

//=============================================================================

// outside.c

qboolean FillOutside (node_t *node);

//=============================================================================

extern	qboolean	drawflag;
extern	qboolean nofill;
extern	qboolean notjunc;
extern	qboolean noclip;
extern	qboolean	verbose;

extern	int		subdivide_size;

extern	int		hullnum;

extern	brushset_t	*brushset;

void qprintf (char *fmt, ...);	// only prints if verbose

extern	int		valid;

extern	char	portfilename[1024];
extern	char	bspfilename[1024];
extern	char	pointfilename[1024];

extern	qboolean	worldmodel;


// misc functions

face_t *AllocFace (void);
void FreeFace (face_t *f);

struct portal_s *AllocPortal (void);
void FreePortal (struct portal_s *p);

surface_t *AllocSurface (void);
void FreeSurface (surface_t *s);

node_t *AllocNode (void);
struct brush_s *AllocBrush (void);

//=============================================================================

