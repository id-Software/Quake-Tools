// solidbsp.c

#include "bsp5.h"

int		leaffaces;
int		nodefaces;
int		splitnodes;

int		c_solid, c_empty, c_water;

qboolean		usemidsplit;

//============================================================================

/*
==================
FaceSide

For BSP hueristic
==================
*/
int FaceSide (face_t *in, plane_t *split)
{
	int		frontcount, backcount;
	vec_t	dot;
	int		i;
	vec_t	*p;
	
	
	frontcount = backcount = 0;
	
// axial planes are fast
	if (split->type < 3)
		for (i=0, p = in->pts[0]+split->type ; i<in->numpoints ; i++, p+=3)
		{
			if (*p > split->dist + ON_EPSILON)
			{
				if (backcount)
					return SIDE_ON;
				frontcount = 1;
			}
			else if (*p < split->dist - ON_EPSILON)
			{
				if (frontcount)
					return SIDE_ON;
				backcount = 1;
			}
		}
	else	
// sloping planes take longer
		for (i=0, p = in->pts[0] ; i<in->numpoints ; i++, p+=3)
		{
			dot = DotProduct (p, split->normal);
			dot -= split->dist;
			if (dot > ON_EPSILON)
			{
				if (backcount)
					return SIDE_ON;
				frontcount = 1;
			}
			else if (dot < -ON_EPSILON)
			{
				if (frontcount)
					return SIDE_ON;
				backcount = 1;
			}
		}
	
	if (!frontcount)
		return SIDE_BACK;
	if (!backcount)
		return SIDE_FRONT;
	
	return SIDE_ON;
}

/*
==================
ChooseMidPlaneFromList

The clipping hull BSP doesn't worry about avoiding splits
==================
*/
surface_t *ChooseMidPlaneFromList (surface_t *surfaces, vec3_t mins, vec3_t maxs)
{
	int			j,l;
	surface_t	*p, *bestsurface;
	vec_t		bestvalue, value, dist;
	plane_t		*plane;

//
// pick the plane that splits the least
//
	bestvalue = 6*8192*8192;
	bestsurface = NULL;
	
	for (p=surfaces ; p ; p=p->next)
	{
		if (p->onnode)
			continue;

		plane = &planes[p->planenum];
		
	// check for axis aligned surfaces
		l = plane->type;
		if (l > PLANE_Z)
			continue;

	//
	// calculate the split metric along axis l, smaller values are better
	//
		value = 0;

		dist = plane->dist * plane->normal[l];
		for (j=0 ; j<3 ; j++)
		{
			if (j == l)
			{
				value += (maxs[l]-dist)*(maxs[l]-dist);
				value += (dist-mins[l])*(dist-mins[l]);
			}
			else
				value += 2*(maxs[j]-mins[j])*(maxs[j]-mins[j]);
		}
		
		if (value > bestvalue)
			continue;
		
	//
	// currently the best!
	//
		bestvalue = value;
		bestsurface = p;
	}

	if (!bestsurface)
	{
		for (p=surfaces ; p ; p=p->next)
			if (!p->onnode)
				return p;		// first valid surface
		Error ("ChooseMidPlaneFromList: no valid planes");
	}
		
	return bestsurface;
}



/*
==================
ChoosePlaneFromList

The real BSP hueristic
==================
*/
surface_t *ChoosePlaneFromList (surface_t *surfaces, vec3_t mins, vec3_t maxs, qboolean usefloors)
{
	int			j,k,l;
	surface_t	*p, *p2, *bestsurface;
	vec_t		bestvalue, bestdistribution, value, dist;
	plane_t		*plane;
	face_t		*f;
	
//
// pick the plane that splits the least
//
	bestvalue = 99999;
	bestsurface = NULL;
	bestdistribution = 9e30;
	
	for (p=surfaces ; p ; p=p->next)
	{
		if (p->onnode)
			continue;

		plane = &planes[p->planenum];
		k = 0;

		if (!usefloors && plane->normal[2] == 1)
			continue;

		for (p2=surfaces ; p2 ; p2=p2->next)
		{
			if (p2 == p)
				continue;
			if (p2->onnode)
				continue;
				
			for (f=p2->faces ; f ; f=f->next)
			{
				if (FaceSide (f, plane) == SIDE_ON)
				{
					k++;
					if (k >= bestvalue)
						break;
				}
				
			}
			if (k > bestvalue)
				break;
		}

		if (k > bestvalue)
			continue;
			
	// if equal numbers, axial planes win, then decide on spatial subdivision
	
		if (k < bestvalue || (k == bestvalue && plane->type < PLANE_ANYX) )
		{
		// check for axis aligned surfaces
			l = plane->type;
	
			if (l <= PLANE_Z)
			{	// axial aligned						
			//
			// calculate the split metric along axis l
			//
				value = 0;
		
				for (j=0 ; j<3 ; j++)
				{
					if (j == l)
					{
						dist = plane->dist * plane->normal[l];
						value += (maxs[l]-dist)*(maxs[l]-dist);
						value += (dist-mins[l])*(dist-mins[l]);
					}
					else
						value += 2*(maxs[j]-mins[j])*(maxs[j]-mins[j]);
				}
				
				if (value > bestdistribution && k == bestvalue)
					continue;
				bestdistribution = value;
			}
		//
		// currently the best!
		//
			bestvalue = k;
			bestsurface = p;
		}

	}


	return bestsurface;
}


/*
==================
SelectPartition

Selects a surface from a linked list of surfaces to split the group on
returns NULL if the surface list can not be divided any more (a leaf)
==================
*/
surface_t *SelectPartition (surface_t *surfaces)
{
	int			i,j;
	vec3_t		mins, maxs;
	surface_t	*p, *bestsurface;

//
// count onnode surfaces
//
	i = 0;
	bestsurface = NULL;
	for (p=surfaces ; p ; p=p->next)
		if (!p->onnode)
		{
			i++;
			bestsurface = p;
		}
		
	if (i==0)
		return NULL;
		
	if (i==1)
		return bestsurface;	// this is a final split
	
//
// calculate a bounding box of the entire surfaceset
//
	for (i=0 ; i<3 ; i++)
	{
		mins[i] = 99999;
		maxs[i] = -99999;
	}

	for (p=surfaces ; p ; p=p->next)
		for (j=0 ; j<3 ; j++)
		{
			if (p->mins[j] < mins[j])
				mins[j] = p->mins[j];
			if (p->maxs[j] > maxs[j])
				maxs[j] = p->maxs[j];
		}

	if (usemidsplit) // do fast way for clipping hull
		return ChooseMidPlaneFromList (surfaces, mins, maxs);
		
// do slow way to save poly splits for drawing hull
#if 0
	bestsurface = ChoosePlaneFromList (surfaces, mins, maxs, false);
	if (bestsurface)	
		return bestsurface;
#endif		
	return ChoosePlaneFromList (surfaces, mins, maxs, true);
}

//============================================================================

/*
=================
CalcSurfaceInfo

Calculates the bounding box
=================
*/
void CalcSurfaceInfo (surface_t *surf)
{
	int		i,j;
	face_t	*f;
	
	if (!surf->faces)
		Error ("CalcSurfaceInfo: surface without a face");
		
//
// calculate a bounding box
//
	for (i=0 ; i<3 ; i++)
	{
		surf->mins[i] = 99999;
		surf->maxs[i] = -99999;
	}

	for (f=surf->faces ; f ; f=f->next)
	{
if (f->contents[0] >= 0 || f->contents[1] >= 0)
Error ("Bad contents");
		for (i=0 ; i<f->numpoints ; i++)
			for (j=0 ; j<3 ; j++)
			{
				if (f->pts[i][j] < surf->mins[j])
					surf->mins[j] = f->pts[i][j];
				if (f->pts[i][j] > surf->maxs[j])
					surf->maxs[j] = f->pts[i][j];
			}
	}
}



/*
==================
DividePlane
==================
*/
void DividePlane (surface_t *in, plane_t *split, surface_t **front, surface_t **back)
{
	face_t		*facet, *next;
	face_t		*frontlist, *backlist;
	face_t		*frontfrag, *backfrag;
	surface_t	*news;
	plane_t		*inplane;	
	
	inplane = &planes[in->planenum];
	
// parallel case is easy
	if (VectorCompare (inplane->normal, split->normal))
	{
// check for exactly on node
		if (inplane->dist == split->dist)
		{	// divide the facets to the front and back sides
			news = AllocSurface ();
			*news = *in;

			facet=in->faces;
			in->faces = NULL;
			news->faces = NULL;
			in->onnode = news->onnode = true;
			
			for ( ; facet ; facet=next)
			{
				next = facet->next;
				if (facet->planeside == 1)
				{
					facet->next = news->faces;
					news->faces = facet;
				}
				else
				{
					facet->next = in->faces;
					in->faces = facet;
				}
			}
				
			if (in->faces)
				*front = in;
			else
				*front = NULL;
			if (news->faces)
				*back = news;
			else
				*back = NULL;
			return;
		}
		
		if (inplane->dist > split->dist)
		{
			*front = in;
			*back = NULL;
		}
		else
		{
			*front = NULL;
			*back = in;
		}
		return;
	}
	
// do a real split.  may still end up entirely on one side
// OPTIMIZE: use bounding box for fast test
	frontlist = NULL;
	backlist = NULL;
	
	for (facet = in->faces ; facet ; facet = next)
	{
		next = facet->next;
		SplitFace (facet, split, &frontfrag, &backfrag);
		if (frontfrag)
		{
			frontfrag->next = frontlist;
			frontlist = frontfrag;
		}
		if (backfrag)
		{
			backfrag->next = backlist;
			backlist = backfrag;
		}
	}

// if nothing actually got split, just move the in plane
	
	if (frontlist == NULL)
	{
		*front = NULL;
		*back = in;
		in->faces = backlist;
		return;
	}

	if (backlist == NULL)
	{
		*front = in;
		*back = NULL;
		in->faces = frontlist;
		return;
	}
	

// stuff got split, so allocate one new plane and reuse in
	news = AllocSurface ();
	*news = *in;
	news->faces = backlist;
	*back = news;
	
	in->faces = frontlist;
	*front = in;
	
// recalc bboxes and flags
	CalcSurfaceInfo (news);
	CalcSurfaceInfo (in);	
}

/*
==================
DivideNodeBounds
==================
*/
void DivideNodeBounds (node_t *node, plane_t *split)
{
	VectorCopy (node->mins, node->children[0]->mins);
	VectorCopy (node->mins, node->children[1]->mins);
	VectorCopy (node->maxs, node->children[0]->maxs);
	VectorCopy (node->maxs, node->children[1]->maxs);

// OPTIMIZE: sloping cuts can give a better bbox than this...
	if (split->type > 2)
		return;

	node->children[0]->mins[split->type] =
	node->children[1]->maxs[split->type] = split->dist;
}

/*
==================
LinkConvexFaces

Determines the contents of the leaf and creates the final list of
original faces that have some fragment inside this leaf
==================
*/
void LinkConvexFaces (surface_t *planelist, node_t *leafnode)
{
	face_t		*f, *next;
	surface_t	*surf, *pnext;
	int			i, count;
	
	leafnode->faces = NULL;
	leafnode->contents = 0;
	leafnode->planenum = -1;

	count = 0;
	for ( surf = planelist ; surf ; surf = surf->next)
	{
		for (f = surf->faces ; f ; f=f->next)
		{
			count++;
			if (!leafnode->contents)
				leafnode->contents = f->contents[0];
			else if (leafnode->contents != f->contents[0])
				Error ("Mixed face contents in leafnode");
		}
	}

	if (!leafnode->contents)
		leafnode->contents = CONTENTS_SOLID;
		
	switch (leafnode->contents)
	{
	case CONTENTS_EMPTY:
		c_empty++;
		break;
	case CONTENTS_SOLID:
		c_solid++;
		break;
	case CONTENTS_WATER:
	case CONTENTS_SLIME:
	case CONTENTS_LAVA:
	case CONTENTS_SKY:
		c_water++;
		break;
	default:
		Error ("LinkConvexFaces: bad contents number");
	}

//
// write the list of faces, and free the originals
//
	leaffaces += count;
	leafnode->markfaces = malloc(sizeof(face_t *)*(count+1));
	i = 0;
	for ( surf = planelist ; surf ; surf = pnext)
	{
		pnext = surf->next;
		for (f = surf->faces ; f ; f=next)
		{
			next = f->next;
			leafnode->markfaces[i] = f->original;
			i++;
			FreeFace (f);
		}
		FreeSurface (surf);
	}
	leafnode->markfaces[i] = NULL;	// sentinal
}


/*
==================
LinkNodeFaces

Returns a duplicated list of all faces on surface
==================
*/
face_t *LinkNodeFaces (surface_t *surface)
{
	face_t	*f, *new, **prevptr;
	face_t	*list;
	
	list = NULL;
	
	
// subdivide
	prevptr = &surface->faces;
	while (1)
	{
		f = *prevptr;
		if (!f)
			break;
		SubdivideFace (f, prevptr);
		f = *prevptr;
		prevptr = &f->next;
	}

// copy
	for (f=surface->faces ; f ; f=f->next)
	{
		nodefaces++;
		new = AllocFace ();
		*new = *f;
		f->original = new;
		new->next = list;
		list = new;
	}

	return list;
}


/*
==================
PartitionSurfaces
==================
*/
void PartitionSurfaces (surface_t *surfaces, node_t *node)
{
	surface_t	*split, *p, *next;
	surface_t	*frontlist, *backlist;
	surface_t	*frontfrag, *backfrag;
	plane_t		*splitplane;
	
	split = SelectPartition (surfaces);
	if (!split)
	{	// this is a leaf node
		node->planenum = PLANENUM_LEAF;
		LinkConvexFaces (surfaces, node);
		return;
	}
		
	splitnodes++;
	node->faces = LinkNodeFaces (split);
	node->children[0] = AllocNode ();
	node->children[1] = AllocNode ();
	node->planenum = split->planenum;

	splitplane = &planes[split->planenum];
	
	DivideNodeBounds (node, splitplane);


//
// multiple surfaces, so split all the polysurfaces into front and back lists
//
	frontlist = NULL;
	backlist = NULL;
	
	for (p=surfaces ; p ; p=next)
	{
		next = p->next;
		DividePlane (p, splitplane, &frontfrag, &backfrag);
		if (frontfrag && backfrag)
		{
		// the plane was split, which may expose oportunities to merge
		// adjacent faces into a single face
//			MergePlaneFaces (frontfrag);
//			MergePlaneFaces (backfrag);
		}

		if (frontfrag)
		{
			if (!frontfrag->faces)
				Error ("surface with no faces");
			frontfrag->next = frontlist;
			frontlist = frontfrag;
		}
		if (backfrag)
		{
			if (!backfrag->faces)
				Error ("surface with no faces");
			backfrag->next = backlist;
			backlist = backfrag;
		}
	}

	PartitionSurfaces (frontlist, node->children[0]);
	PartitionSurfaces (backlist, node->children[1]);
}

/*
==================
DrawSurface
==================
*/
void DrawSurface (surface_t *surf)
{
	face_t	*f;
	
	for (f=surf->faces ; f ; f=f->next)
		Draw_DrawFace (f);
}

/*
==================
DrawSurfaceList
==================
*/
void DrawSurfaceList (surface_t *surf)
{	
	Draw_ClearWindow ();
	while (surf)
	{
		DrawSurface (surf);
		surf = surf->next;
	}
}

/*
==================
SolidBSP
==================
*/
node_t *SolidBSP (surface_t *surfhead, qboolean midsplit)
{
	int		i;
	node_t	*headnode;
	
	qprintf ("----- SolidBSP -----\n");

	headnode = AllocNode ();
	usemidsplit = midsplit;
	
//
// calculate a bounding box for the entire model
//
	for (i=0 ; i<3 ; i++)
	{
		headnode->mins[i] = brushset->mins[i] - SIDESPACE;
		headnode->maxs[i] = brushset->maxs[i] + SIDESPACE;
	}
	
//
// recursively partition everything
//
	Draw_ClearWindow ();
	splitnodes = 0;
	leaffaces = 0;
	nodefaces = 0;
	c_solid = c_empty = c_water = 0;

	PartitionSurfaces (surfhead, headnode);

	qprintf ("%5i split nodes\n", splitnodes);
	qprintf ("%5i solid leafs\n", c_solid);
	qprintf ("%5i empty leafs\n", c_empty);
	qprintf ("%5i water leafs\n", c_water);	
	qprintf ("%5i leaffaces\n",leaffaces);
	qprintf ("%5i nodefaces\n", nodefaces);
	
	return headnode;
}

