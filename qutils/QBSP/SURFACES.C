// divide.h

#include "bsp5.h"


surface_t	newcopy_t;

/*
a surface has all of the faces that could be drawn on a given plane

the outside filling stage can remove some of them so a better bsp can be generated

*/

int	subdivides;


/*
===============
SubdivideFace

If the face is >256 in either texture direction, carve a valid sized
piece off and insert the remainder in the next link
===============
*/
void SubdivideFace (face_t *f, face_t **prevptr)
{
	float		mins, maxs;
	vec_t		v;
	int			axis, i;
	plane_t		plane;
	face_t		*front, *back, *next;
	texinfo_t	*tex;

// special (non-surface cached) faces don't need subdivision
	tex = &texinfo[f->texturenum];

	if ( tex->flags & TEX_SPECIAL)
		return;


	for (axis = 0 ; axis < 2 ; axis++)
	{
		while (1)
		{
			mins = 9999;
			maxs = -9999;
			
			for (i=0 ; i<f->numpoints ; i++)
			{
				v = DotProduct (f->pts[i], tex->vecs[axis]);
				if (v < mins)
					mins = v;
				if (v > maxs)
					maxs = v;
			}
		
			if (maxs - mins <= subdivide_size)
				break;
			
		// split it
			subdivides++;
			
			VectorCopy (tex->vecs[axis], plane.normal);
			v = VectorLength (plane.normal);
			VectorNormalize (plane.normal);			
			plane.dist = (mins + subdivide_size - 16)/v;
			next = f->next;
			SplitFace (f, &plane, &front, &back);
			if (!front || !back)
				Error ("SubdivideFace: didn't split the polygon");
			*prevptr = back;
			back->next = front;
			front->next = next;
			f = back;
		}
	}
}


/*
================
SubdivideFaces
================
*/
void SubdivideFaces (surface_t *surfhead)
{
	surface_t       *surf;
	face_t          *f , **prevptr;

	qprintf ("--- SubdivideFaces ---\n");

	subdivides = 0;

	for (surf = surfhead ; surf ; surf=surf->next)
	{
		prevptr = &surf->faces;
		while (1)
		{
			f = *prevptr;
			if (!f)
				break;
			SubdivideFace (f, prevptr);
			f = *prevptr;
			prevptr = &f->next;
		}
	}

	qprintf ("%i faces added by subdivision\n", subdivides);
	
}


/*
=============================================================================

GatherNodeFaces

Frees the current node tree and returns a new chain of the surfaces that
have inside faces.
=============================================================================
*/

void GatherNodeFaces_r (node_t *node)
{
	face_t	*f, *next;
	
	if (node->planenum != PLANENUM_LEAF)
	{
//
// decision node
//
		for (f=node->faces ; f ; f=next)
		{
			next = f->next;
			if (!f->numpoints)
			{	// face was removed outside
				FreeFace (f);
			}
			else
			{
				f->next = validfaces[f->planenum];
				validfaces[f->planenum] = f;
			}
		}
		
		GatherNodeFaces_r (node->children[0]);
		GatherNodeFaces_r (node->children[1]);
		
		free (node);
	}
	else
	{
//
// leaf node
//
		free (node);
	}
}

/*
================
GatherNodeFaces

================
*/
surface_t *GatherNodeFaces (node_t *headnode)
{
	memset (validfaces, 0, sizeof(validfaces));
	GatherNodeFaces_r (headnode);
	return BuildSurfaces ();	
}

//===========================================================================

typedef struct hashvert_s
{
	struct hashvert_s	*next;
	vec3_t	point;
	int		num;
	int		numplanes;		// for corner determination
	int		planenums[2];
	int		numedges;
} hashvert_t;

#define	POINT_EPSILON	0.01

int		c_cornerverts;

hashvert_t	hvertex[MAX_MAP_VERTS];
hashvert_t	*hvert_p;

face_t		*edgefaces[MAX_MAP_EDGES][2];
int		firstmodeledge = 1;
int		firstmodelface;

//============================================================================

#define	NUM_HASH	4096

hashvert_t	*hashverts[NUM_HASH];

static	vec3_t	hash_min, hash_scale;

static	void InitHash (void)
{
	vec3_t	size;
	vec_t	volume;
	vec_t	scale;
	int		newsize[2];
	int		i;
	
	memset (hashverts, 0, sizeof(hashverts));

	for (i=0 ; i<3 ; i++)
	{
		hash_min[i] = -8000;
		size[i] = 16000;
	}

	volume = size[0]*size[1];
	
	scale = sqrt(volume / NUM_HASH);

	newsize[0] = size[0] / scale;
	newsize[1] = size[1] / scale;

	hash_scale[0] = newsize[0] / size[0];
	hash_scale[1] = newsize[1] / size[1];
	hash_scale[2] = newsize[1];
	
	hvert_p = hvertex;
}

static	unsigned HashVec (vec3_t vec)
{
	unsigned	h;
	
	h =	hash_scale[0] * (vec[0] - hash_min[0]) * hash_scale[2]
		+ hash_scale[1] * (vec[1] - hash_min[1]);
	if ( h >= NUM_HASH)
		return NUM_HASH - 1;
	return h;
}


/*
=============
GetVertex
=============
*/
int	GetVertex (vec3_t in, int planenum)
{
	int			h;
	int			i;
	hashvert_t	*hv;
	vec3_t		vert;
	
	for (i=0 ; i<3 ; i++)
	{
		if ( fabs(in[i] - Q_rint(in[i])) < 0.001)
			vert[i] = Q_rint(in[i]);
		else
			vert[i] = in[i];
	}
	
	h = HashVec (vert);
	
	for (hv=hashverts[h] ; hv ; hv=hv->next)
	{
		if ( fabs(hv->point[0]-vert[0])<POINT_EPSILON
		&& fabs(hv->point[1]-vert[1])<POINT_EPSILON
		&& fabs(hv->point[2]-vert[2])<POINT_EPSILON )
		{
			hv->numedges++;
			if (hv->numplanes == 3)
				return hv->num;		// allready known to be a corner
			for (i=0 ; i<hv->numplanes ; i++)
				if (hv->planenums[i] == planenum)
					return hv->num;		// allready know this plane
			if (hv->numplanes == 2)
				c_cornerverts++;
			else
				hv->planenums[hv->numplanes] = planenum;
			hv->numplanes++;
			return hv->num;
		}
	}
	
	hv = hvert_p;
	hv->numedges = 1;
	hv->numplanes = 1;
	hv->planenums[0] = planenum;
	hv->next = hashverts[h];
	hashverts[h] = hv;
	VectorCopy (vert, hv->point);
	hv->num = numvertexes;
	if (hv->num==MAX_MAP_VERTS)
		Error ("GetVertex: MAX_MAP_VERTS");
	hvert_p++;
		
// emit a vertex
	if (numvertexes == MAX_MAP_VERTS)
		Error ("numvertexes == MAX_MAP_VERTS");

	dvertexes[numvertexes].point[0] = vert[0];
	dvertexes[numvertexes].point[1] = vert[1];
	dvertexes[numvertexes].point[2] = vert[2];
	numvertexes++;

	return hv->num;
}

//===========================================================================


/*
==================
GetEdge

Don't allow four way edges
==================
*/
int	c_tryedges;

int GetEdge (vec3_t p1, vec3_t p2, face_t *f)
{
	int		v1, v2;
	dedge_t	*edge;
	int		i;

	if (!f->contents[0])
		Error ("GetEdge: 0 contents");

	c_tryedges++;		
	v1 = GetVertex (p1, f->planenum);
	v2 = GetVertex (p2, f->planenum);
	for (i=firstmodeledge ; i < numedges ; i++)
	{
		edge = &dedges[i];
		if (v1 == edge->v[1] && v2 == edge->v[0]
		&& !edgefaces[i][1]
		&& edgefaces[i][0]->contents[0] == f->contents[0])
		{
			edgefaces[i][1] = f;
			return -i;
		}
	}
	
// emit an edge
	if (numedges == MAX_MAP_EDGES)
		Error ("numedges == MAX_MAP_EDGES");
	edge = &dedges[numedges];
	numedges++;
	edge->v[0] = v1;
	edge->v[1] = v2;
	edgefaces[i][0] = f;
	
	return i;
}


/*
==================
FindFaceEdges
==================
*/
void FindFaceEdges (face_t *face)
{
	int		i;

	face->outputnumber = -1;	
	if (face->numpoints > MAXEDGES)
		Error ("WriteFace: %i points", face->numpoints);

	for (i=0; i<face->numpoints ; i++)
		face->edges[i] =  GetEdge
		(face->pts[i], face->pts[(i+1)%face->numpoints], face);	
}

/*
=============
CheckVertexes
// debugging
=============
*/
void CheckVertexes (void)
{
	int		cb, c0, c1, c2, c3;	
	hashvert_t	*hv;
	
	cb = c0 = c1 = c2 = c3 = 0;
	for (hv=hvertex ; hv!=hvert_p ; hv++)
	{
		if (hv->numedges < 0 || hv->numedges & 1)
			cb++;
		else if (!hv->numedges)
			c0++;
		else if (hv->numedges == 2)
			c1++;
		else if (hv->numedges == 4)
			c2++;
		else
			c3++;
	}
	
	qprintf ("%5i bad edge points\n", cb);
	qprintf ("%5i 0 edge points\n", c0);
	qprintf ("%5i 2 edge points\n", c1);
	qprintf ("%5i 4 edge points\n", c2);
	qprintf ("%5i 6+ edge points\n", c3);
}

/*
=============
CheckEdges
// debugging
=============
*/
void CheckEdges (void)
{
	dedge_t	*edge;
	int		i;
	dvertex_t	*d1, *d2;
	face_t		*f1, *f2;
	int		c_nonconvex;
	int		c_multitexture;
	
	c_nonconvex = c_multitexture = 0;
	
//	CheckVertexes ();
	
	for (i=1 ; i < numedges ; i++)
	{
		edge = &dedges[i];
		if (!edgefaces[i][1])
		{
			d1 = &dvertexes[edge->v[0]];
			d2 = &dvertexes[edge->v[1]];
			qprintf ("unshared edge at: (%8.2f, %8.2f, %8.2f) (%8.2f, %8.2f, %8.2f)\n",d1->point[0], d1->point[1], d1->point[2], d2->point[0], d2->point[1], d2->point[2]); 
		}
		else
		{
			f1 = edgefaces[i][0];
			f2 = edgefaces[i][1];
			if (f1->planeside != f2->planeside)
				continue;
			if (f1->planenum != f2->planenum)
				continue;
				
			// on the same plane, might be discardable
			if (f1->texturenum == f2->texturenum)
			{
				hvertex[edge->v[0]].numedges-=2;
				hvertex[edge->v[1]].numedges-=2;
				c_nonconvex++;
			}
			else
				c_multitexture++;
		}
	}

//	qprintf ("%5i edges\n", i);
//	qprintf ("%5i c_nonconvex\n", c_nonconvex);
//	qprintf ("%5i c_multitexture\n", c_multitexture);

//	CheckVertexes ();
}


/*
================
MakeFaceEdges_r
================
*/
void MakeFaceEdges_r (node_t *node)
{
	face_t	*f;
	
	if (node->planenum == PLANENUM_LEAF)
		return;
		
	for (f=node->faces ; f ; f=f->next)
		FindFaceEdges (f);
		
	MakeFaceEdges_r (node->children[0]);
	MakeFaceEdges_r (node->children[1]);
}

/*
================
MakeFaceEdges
================
*/
void MakeFaceEdges (node_t *headnode)
{
	qprintf ("----- MakeFaceEdges -----\n");
	
	InitHash ();
	c_tryedges = 0;
	c_cornerverts = 0;
	
	MakeFaceEdges_r (headnode);

//	CheckEdges ();

	GrowNodeRegions (headnode);

	firstmodeledge = numedges;
	firstmodelface = numfaces;
}

