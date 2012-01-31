// vis.c

#include "vis.h"

#define	MAX_THREADS		4

int			numportals;
int			portalleafs;

portal_t	*portals;
leaf_t		*leafs;

int			c_portaltest, c_portalpass, c_portalcheck;


qboolean		showgetleaf = true;

int		leafon;			// the next leaf to be given to a thread to process

#ifdef __alpha
pthread_mutex_t	*my_mutex;
#endif

byte	*vismap, *vismap_p, *vismap_end;	// past visfile
int		originalvismapsize;

byte	*uncompressed;			// [bitbytes*portalleafs]

int		bitbytes;				// (portalleafs+63)>>3
int		bitlongs;

#ifdef __alpha
int			numthreads = 4;
#else
int			numthreads = 1;
#endif

qboolean		fastvis;
qboolean		verbose;
int			testlevel = 2;

#if 0
void NormalizePlane (plane_t *dp)
{
	vec_t	ax, ay, az;
	
	if (dp->normal[0] == -1.0)
	{
		dp->normal[0] = 1.0;
		dp->dist = -dp->dist;
		return;
	}
	if (dp->normal[1] == -1.0)
	{
		dp->normal[1] = 1.0;
		dp->dist = -dp->dist;
		return;
	}
	if (dp->normal[2] == -1.0)
	{
		dp->normal[2] = 1.0;
		dp->dist = -dp->dist;
		return;
	}
	
	ax = fabs(dp->normal[0]);
	ay = fabs(dp->normal[1]);
	az = fabs(dp->normal[2]);
	
	if (ax >= ay && ax >= az)
	{
		if (dp->normal[0] < 0)
		{
			VectorSubtract (vec3_origin, dp->normal, dp->normal);
			dp->dist = -dp->dist;
		}
		return;
	}
	
	if (ay >= ax && ay >= az)
	{
		if (dp->normal[1] < 0)
		{
			VectorSubtract (vec3_origin, dp->normal, dp->normal);
			dp->dist = -dp->dist;
		}
		return;
	}
	
	if (dp->normal[2] < 0)
	{
		VectorSubtract (vec3_origin, dp->normal, dp->normal);
		dp->dist = -dp->dist;
	}
}
#endif

void PlaneFromWinding (winding_t *w, plane_t *plane)
{
	vec3_t		v1, v2;

// calc plane
	VectorSubtract (w->points[2], w->points[1], v1);
	VectorSubtract (w->points[0], w->points[1], v2);
	CrossProduct (v2, v1, plane->normal);
	VectorNormalize (plane->normal);
	plane->dist = DotProduct (w->points[0], plane->normal);
}

//=============================================================================

/*
==================
NewWinding
==================
*/
winding_t *NewWinding (int points)
{
	winding_t	*w;
	int			size;
	
	if (points > MAX_POINTS_ON_WINDING)
		Error ("NewWinding: %i points", points);
	
	size = (int)((winding_t *)0)->points[points];
	w = malloc (size);
	memset (w, 0, size);
	
	return w;
}


void FreeWinding (winding_t *w)
{
	if (!w->original)
		free (w);
}


void pw(winding_t *w)
{
	int		i;
	for (i=0 ; i<w->numpoints ; i++)
		printf ("(%5.1f, %5.1f, %5.1f)\n",w->points[i][0], w->points[i][1],w->points[i][2]);
}

void prl(leaf_t *l)
{
	int			i;
	portal_t	*p;
	plane_t		pl;
	
	for (i=0 ; i<l->numportals ; i++)
	{
		p = l->portals[i];
		pl = p->plane;
		printf ("portal %4i to leaf %4i : %7.1f : (%4.1f, %4.1f, %4.1f)\n",(int)(p-portals),p->leaf,pl.dist, pl.normal[0], pl.normal[1], pl.normal[2]);
	}
}

/*
==================
CopyWinding
==================
*/
winding_t	*CopyWinding (winding_t *w)
{
	int			size;
	winding_t	*c;
	
	size = (int)((winding_t *)0)->points[w->numpoints];
	c = malloc (size);
	memcpy (c, w, size);
	c->original = false;
	return c;
}


/*
==================
ClipWinding

Clips the winding to the plane, returning the new winding on the positive side
Frees the input winding.
If keepon is true, an exactly on-plane winding will be saved, otherwise
it will be clipped away.
==================
*/
winding_t *ClipWinding (winding_t *in, plane_t *split, qboolean keepon)
{
	vec_t	dists[MAX_POINTS_ON_WINDING];
	int		sides[MAX_POINTS_ON_WINDING];
	int		counts[3];
	vec_t	dot;
	int		i, j;
	vec_t	*p1, *p2;
	vec3_t	mid;
	winding_t	*neww;
	int		maxpts;
	
	counts[0] = counts[1] = counts[2] = 0;

// determine sides for each point
	for (i=0 ; i<in->numpoints ; i++)
	{
		dot = DotProduct (in->points[i], split->normal);
		dot -= split->dist;
		dists[i] = dot;
		if (dot > ON_EPSILON)
			sides[i] = SIDE_FRONT;
		else if (dot < -ON_EPSILON)
			sides[i] = SIDE_BACK;
		else
		{
			sides[i] = SIDE_ON;
		}
		counts[sides[i]]++;
	}
	sides[i] = sides[0];
	dists[i] = dists[0];
	
	if (keepon && !counts[0] && !counts[1])
		return in;
		
	if (!counts[0])
	{
		FreeWinding (in);
		return NULL;
	}
	if (!counts[1])
		return in;
	
	maxpts = in->numpoints+4;	// can't use counts[0]+2 because
								// of fp grouping errors
	neww = NewWinding (maxpts);
		
	for (i=0 ; i<in->numpoints ; i++)
	{
		p1 = in->points[i];
		
		if (sides[i] == SIDE_ON)
		{
			VectorCopy (p1, neww->points[neww->numpoints]);
			neww->numpoints++;
			continue;
		}
	
		if (sides[i] == SIDE_FRONT)
		{
			VectorCopy (p1, neww->points[neww->numpoints]);
			neww->numpoints++;
		}
		
		if (sides[i+1] == SIDE_ON || sides[i+1] == sides[i])
			continue;
			
	// generate a split point
		p2 = in->points[(i+1)%in->numpoints];
		
		dot = dists[i] / (dists[i]-dists[i+1]);
		for (j=0 ; j<3 ; j++)
		{	// avoid round off error when possible
			if (split->normal[j] == 1)
				mid[j] = split->dist;
			else if (split->normal[j] == -1)
				mid[j] = -split->dist;
			else
				mid[j] = p1[j] + dot*(p2[j]-p1[j]);
		}
			
		VectorCopy (mid, neww->points[neww->numpoints]);
		neww->numpoints++;
	}
	
	if (neww->numpoints > maxpts)
		Error ("ClipWinding: points exceeded estimate");
		
// free the original winding
	FreeWinding (in);
	
	return neww;
}


//=============================================================================

/*
=============
GetNextPortal

Returns the next portal for a thread to work on
Returns the portals from the least complex, so the later ones can reuse
the earlier information.
=============
*/
portal_t *GetNextPortal (void)
{
	int		j;
	portal_t	*p, *tp;
	int		min;
	
	LOCK;

	min = 99999;
	p = NULL;
	
	for (j=0, tp = portals ; j<numportals*2 ; j++, tp++)
	{
		if (tp->nummightsee < min && tp->status == stat_none)
		{
			min = tp->nummightsee;
			p = tp;
		}
	}

	
	if (p)
		p->status = stat_working;

	UNLOCK;

	return p;
}

/*
==============
LeafThread
==============
*/
#ifdef __alpha
pthread_addr_t LeafThread (pthread_addr_t thread)
#else
void *LeafThread (int thread)
#endif
{
	portal_t	*p;
		
//printf ("Begining LeafThread: %i\n",(int)thread);	
	do
	{
		p = GetNextPortal ();
		if (!p)
			break;
			
		PortalFlow (p);
		
		if (verbose)
			printf ("portal:%4i  mightsee:%4i  cansee:%4i\n", (int)(p - portals), p->nummightsee, p->numcansee);
	} while (1);

//printf ("Completed LeafThread: %i\n",(int)thread);	

	return NULL;
}

/*
===============
CompressRow

===============
*/
int CompressRow (byte *vis, byte *dest)
{
	int		j;
	int		rep;
	int		visrow;
	byte	*dest_p;
	
	dest_p = dest;
	visrow = (portalleafs + 7)>>3;
	
	for (j=0 ; j<visrow ; j++)
	{
		*dest_p++ = vis[j];
		if (vis[j])
			continue;

		rep = 1;
		for ( j++; j<visrow ; j++)
			if (vis[j] || rep == 255)
				break;
			else
				rep++;
		*dest_p++ = rep;
		j--;
	}
	
	return dest_p - dest;
}


/*
===============
LeafFlow

Builds the entire visibility list for a leaf
===============
*/
int		totalvis;

void LeafFlow (int leafnum)
{
	leaf_t		*leaf;
	byte		*outbuffer;
	byte		compressed[MAX_MAP_LEAFS/8];
	int			i, j;
	int			numvis;
	byte		*dest;
	portal_t	*p;
	
//
// flow through all portals, collecting visible bits
//
	outbuffer = uncompressed + leafnum*bitbytes;
	leaf = &leafs[leafnum];
	for (i=0 ; i<leaf->numportals ; i++)
	{
		p = leaf->portals[i];
		if (p->status != stat_done)
			Error ("portal not done");
		for (j=0 ; j<bitbytes ; j++)
			outbuffer[j] |= p->visbits[j];
	}

	if (outbuffer[leafnum>>3] & (1<<(leafnum&7)))
		Error ("Leaf portals saw into leaf");
		
	outbuffer[leafnum>>3] |= (1<<(leafnum&7));

	numvis = 0;
	for (i=0 ; i<portalleafs ; i++)
		if (outbuffer[i>>3] & (1<<(i&3)))
			numvis++;
			
//
// compress the bit string
//
	if (verbose)
		printf ("leaf %4i : %4i visible\n", leafnum, numvis);
	totalvis += numvis;

#if 0	
	i = (portalleafs+7)>>3;
	memcpy (compressed, outbuffer, i);
#else
	i = CompressRow (outbuffer, compressed);
#endif

	dest = vismap_p;
	vismap_p += i;
	
	if (vismap_p > vismap_end)
		Error ("Vismap expansion overflow");

	dleafs[leafnum+1].visofs = dest-vismap;	// leaf 0 is a common solid

	memcpy (dest, compressed, i);	
}


/*
==================
CalcPortalVis
==================
*/
void CalcPortalVis (void)
{
	int		i;

// fastvis just uses mightsee for a very loose bound
	if (fastvis)
	{
		for (i=0 ; i<numportals*2 ; i++)
		{
			portals[i].visbits = portals[i].mightsee;
			portals[i].status = stat_done;
		}
		return;
	}
	
	leafon = 0;
	
#ifdef __alpha
{
	pthread_t	work_threads[MAX_THREADS];
	pthread_addr_t	status;
	pthread_attr_t	attrib;
	pthread_mutexattr_t	mattrib;
	int		i;
	
	my_mutex = malloc (sizeof(*my_mutex));
	if (pthread_mutexattr_create (&mattrib) == -1)
		Error ("pthread_mutex_attr_create failed");
	if (pthread_mutexattr_setkind_np (&mattrib, MUTEX_FAST_NP) == -1)
		Error ("pthread_mutexattr_setkind_np failed");
	if (pthread_mutex_init (my_mutex, mattrib) == -1)
		Error ("pthread_mutex_init failed");

	if (pthread_attr_create (&attrib) == -1)
		Error ("pthread_attr_create failed");
	if (pthread_attr_setstacksize (&attrib, 0x100000) == -1)
		Error ("pthread_attr_setstacksize failed");
	
	for (i=0 ; i<numthreads ; i++)
	{
  		if (pthread_create(&work_threads[i], attrib
		, LeafThread, (pthread_addr_t)i) == -1)
			Error ("pthread_create failed");
	}
		
	for (i=0 ; i<numthreads ; i++)
	{
		if (pthread_join (work_threads[i], &status) == -1)
			Error ("pthread_join failed");
	}

	if (pthread_mutex_destroy (my_mutex) == -1)
			Error ("pthread_mutex_destroy failed");
}
#else
	LeafThread (0);
#endif

	if (verbose)
	{
		printf ("portalcheck: %i  portaltest: %i  portalpass: %i\n",c_portalcheck, c_portaltest, c_portalpass);
		printf ("c_vistest: %i  c_mighttest: %i\n",c_vistest, c_mighttest);
	}

}


/*
==================
CalcVis
==================
*/
void CalcVis (void)
{
	int		i;
	
	BasePortalVis ();
	
	CalcPortalVis ();

//
// assemble the leaf vis lists by oring and compressing the portal lists
//
	for (i=0 ; i<portalleafs ; i++)
		LeafFlow (i);
		
	printf ("average leafs visible: %i\n", totalvis / portalleafs);
}

/*
==============================================================================

PASSAGE CALCULATION (not used yet...)

==============================================================================
*/

int		count_sep;

qboolean PlaneCompare (plane_t *p1, plane_t *p2)
{
	int		i;

	if ( fabs(p1->dist - p2->dist) > 0.01)
		return false;

	for (i=0 ; i<3 ; i++)
		if ( fabs(p1->normal[i] - p2->normal[i] ) > 0.001)
			return false;

	return true;				
}

sep_t	*Findpassages (winding_t *source, winding_t *pass)
{
	int			i, j, k, l;
	plane_t		plane;
	vec3_t		v1, v2;
	float		d;
	double		length;
	int			counts[3];
	qboolean		fliptest;
	sep_t		*sep, *list;
	
	list = NULL;

// check all combinations	
	for (i=0 ; i<source->numpoints ; i++)
	{
		l = (i+1)%source->numpoints;
		VectorSubtract (source->points[l] , source->points[i], v1);

	// fing a vertex of pass that makes a plane that puts all of the
	// vertexes of pass on the front side and all of the vertexes of
	// source on the back side
		for (j=0 ; j<pass->numpoints ; j++)
		{
			VectorSubtract (pass->points[j], source->points[i], v2);

			plane.normal[0] = v1[1]*v2[2] - v1[2]*v2[1];
			plane.normal[1] = v1[2]*v2[0] - v1[0]*v2[2];
			plane.normal[2] = v1[0]*v2[1] - v1[1]*v2[0];
			
		// if points don't make a valid plane, skip it

			length = plane.normal[0] * plane.normal[0]
			+ plane.normal[1] * plane.normal[1]
			+ plane.normal[2] * plane.normal[2];
			
			if (length < ON_EPSILON)
				continue;

			length = 1/sqrt(length);
			
			plane.normal[0] *= length;
			plane.normal[1] *= length;
			plane.normal[2] *= length;

			plane.dist = DotProduct (pass->points[j], plane.normal);

		//
		// find out which side of the generated seperating plane has the
		// source portal
		//
			fliptest = false;
			for (k=0 ; k<source->numpoints ; k++)
			{
				if (k == i || k == l)
					continue;
				d = DotProduct (source->points[k], plane.normal) - plane.dist;
				if (d < -ON_EPSILON)
				{	// source is on the negative side, so we want all
					// pass and target on the positive side
					fliptest = false;
					break;
				}
				else if (d > ON_EPSILON)
				{	// source is on the positive side, so we want all
					// pass and target on the negative side
					fliptest = true;
					break;
				}
			}
			if (k == source->numpoints)
				continue;		// planar with source portal

		//
		// flip the normal if the source portal is backwards
		//
			if (fliptest)
			{
				VectorSubtract (vec3_origin, plane.normal, plane.normal);
				plane.dist = -plane.dist;
			}
			
		//
		// if all of the pass portal points are now on the positive side,
		// this is the seperating plane
		//
			counts[0] = counts[1] = counts[2] = 0;
			for (k=0 ; k<pass->numpoints ; k++)
			{
				if (k==j)
					continue;
				d = DotProduct (pass->points[k], plane.normal) - plane.dist;
				if (d < -ON_EPSILON)
					break;
				else if (d > ON_EPSILON)
					counts[0]++;
				else
					counts[2]++;
			}
			if (k != pass->numpoints)
				continue;	// points on negative side, not a seperating plane
				
			if (!counts[0])
				continue;	// planar with pass portal
		
		//
		// save this out
		//
			count_sep++;

			sep = malloc(sizeof(*sep));
			sep->next = list;
			list = sep;
			sep->plane = plane;
		}
	}
	
	return list;
}



/*
============
CalcPassages
============
*/
void CalcPassages (void)
{
	int		i, j, k;
	int		count, count2;
	leaf_t	*l;
	portal_t	*p1, *p2;
	sep_t		*sep;
	passage_t		*passages;

	printf ("building passages...\n");

	count = count2 = 0;
	for (i=0 ; i<portalleafs ; i++)
	{
		l = &leafs[i];

		for (j=0 ; j<l->numportals ; j++)
		{
			p1 = l->portals[j];
			for (k=0 ; k<l->numportals ; k++)
			{
				if (k==j)
					continue;
					
				count++;
				p2 = l->portals[k];
			
			// definately can't see into a coplanar portal
				if (PlaneCompare (&p1->plane, &p2->plane) )
					continue;
					
				count2++;

				sep = Findpassages (p1->winding, p2->winding);
				if (!sep)
				{
//					Error ("No seperating planes found in portal pair");
					count_sep++;
					sep = malloc(sizeof(*sep));
					sep->next = NULL;
					sep->plane = p1->plane;
				}
				passages = malloc(sizeof(*passages));
				passages->planes = sep;
				passages->from = p1->leaf;
				passages->to = p2->leaf;
				passages->next = l->passages;
				l->passages = passages;
			}
		}
	}

	printf ("numpassages: %i (%i)\n", count2, count);
	printf ("total passages: %i\n", count_sep);
}

//=============================================================================

/*
============
LoadPortals
============
*/
void LoadPortals (char *name)
{
	int			i, j;
	portal_t	*p;
	leaf_t		*l;
	char		magic[80];
	FILE		*f;
	int			numpoints;
	winding_t	*w;
	int			leafnums[2];
	plane_t		plane;
	
	if (!strcmp(name,"-"))
		f = stdin;
	else
	{
		f = fopen(name, "r");
		if (!f)
		{
			printf ("LoadPortals: couldn't read %s\n",name);
			printf ("No vising performed.\n");
			exit (1);
		}
	}

	if (fscanf (f,"%79s\n%i\n%i\n",magic, &portalleafs, &numportals) != 3)
		Error ("LoadPortals: failed to read header");
	if (strcmp(magic,PORTALFILE))
		Error ("LoadPortals: not a portal file");

	printf ("%4i portalleafs\n", portalleafs);
	printf ("%4i numportals\n", numportals);

	bitbytes = ((portalleafs+63)&~63)>>3;
	bitlongs = bitbytes/sizeof(long);
	
// each file portal is split into two memory portals
	portals = malloc(2*numportals*sizeof(portal_t));
	memset (portals, 0, 2*numportals*sizeof(portal_t));
	
	leafs = malloc(portalleafs*sizeof(leaf_t));
	memset (leafs, 0, portalleafs*sizeof(leaf_t));

	originalvismapsize = portalleafs*((portalleafs+7)/8);

	vismap = vismap_p = dvisdata;
	vismap_end = vismap + MAX_MAP_VISIBILITY;
		
	for (i=0, p=portals ; i<numportals ; i++)
	{
		if (fscanf (f, "%i %i %i ", &numpoints, &leafnums[0], &leafnums[1])
			!= 3)
			Error ("LoadPortals: reading portal %i", i);
		if (numpoints > MAX_POINTS_ON_WINDING)
			Error ("LoadPortals: portal %i has too many points", i);
		if ( (unsigned)leafnums[0] > portalleafs
		|| (unsigned)leafnums[1] > portalleafs)
			Error ("LoadPortals: reading portal %i", i);
		
		w = p->winding = NewWinding (numpoints);
		w->original = true;
		w->numpoints = numpoints;
		
		for (j=0 ; j<numpoints ; j++)
		{
			double	v[3];
			int		k;

			// scanf into double, then assign to vec_t
			if (fscanf (f, "(%lf %lf %lf ) "
			, &v[0], &v[1], &v[2]) != 3)
				Error ("LoadPortals: reading portal %i", i);
			for (k=0 ; k<3 ; k++)
				w->points[j][k] = v[k];
		}
		fscanf (f, "\n");
		
	// calc plane
		PlaneFromWinding (w, &plane);

	// create forward portal
		l = &leafs[leafnums[0]];
		if (l->numportals == MAX_PORTALS_ON_LEAF)
			Error ("Leaf with too many portals");
		l->portals[l->numportals] = p;
		l->numportals++;
		
		p->winding = w;
		VectorSubtract (vec3_origin, plane.normal, p->plane.normal);
		p->plane.dist = -plane.dist;
		p->leaf = leafnums[1];
		p++;
		
	// create backwards portal
		l = &leafs[leafnums[1]];
		if (l->numportals == MAX_PORTALS_ON_LEAF)
			Error ("Leaf with too many portals");
		l->portals[l->numportals] = p;
		l->numportals++;
		
		p->winding = w;
		p->plane = plane;
		p->leaf = leafnums[0];
		p++;

	}
	
	fclose (f);
}


/*
===========
main
===========
*/
int main (int argc, char **argv)
{
	char	portalfile[1024];
	char		source[1024];
	int		i;
	double		start, end;
		
	printf ("---- vis ----\n");

	for (i=1 ; i<argc ; i++)
	{
		if (!strcmp(argv[i],"-threads"))
		{
			numthreads = atoi (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i], "-fast"))
		{
			printf ("fastvis = true\n");
			fastvis = true;
		}
		else if (!strcmp(argv[i], "-level"))
		{
			testlevel = atoi(argv[i+1]);
			printf ("testlevel = %i\n", testlevel);
			i++;
		}
		else if (!strcmp(argv[i], "-v"))
		{
			printf ("verbose = true\n");
			verbose = true;
		}
		else if (argv[i][0] == '-')
			Error ("Unknown option \"%s\"", argv[i]);
		else
			break;
	}

	if (i != argc - 1)
		Error ("usage: vis [-threads #] [-level 0-4] [-fast] [-v] bspfile");

	start = I_FloatTime ();
	
	strcpy (source, argv[i]);
	StripExtension (source);
	DefaultExtension (source, ".bsp");

	LoadBSPFile (source);
	
	strcpy (portalfile, argv[i]);
	StripExtension (portalfile);
	strcat (portalfile, ".prt");
	
	LoadPortals (portalfile);
	
	uncompressed = malloc(bitbytes*portalleafs);
	memset (uncompressed, 0, bitbytes*portalleafs);
	
//	CalcPassages ();

	CalcVis ();

	printf ("c_chains: %i\n",c_chains);
	
	visdatasize = vismap_p - dvisdata;	
	printf ("visdatasize:%i  compressed from %i\n", visdatasize, originalvismapsize);
	
	CalcAmbientSounds ();

	WriteBSPFile (source);	
	
//	unlink (portalfile);

	end = I_FloatTime ();
	printf ("%5.1f seconds elapsed\n", end-start);
	
	return 0;
}

