//
// modelgen.c: generates a .mdl file from a base triangle file (.tri), a
// texture containing front and back skins (.lbm), and a series of frame
// triangle files (.tri). Result is stored in
// /raid/quake/models/<scriptname>.mdl.
//

#define INCLUDELIBS

#include <sys/stat.h>

#include "modelgen.h"

#define MAXVERTS		2048
#define MAXFRAMES		256
#define MAXSKINS		100


typedef struct {
	aliasframetype_t	type;		// single frame or group of frames
	void				*pdata;		// either a daliasframe_t or group info
	float				interval;	// only used for frames in groups
	int					numgroupframes;	// only used by group headers
	char				name[16];
} aliaspackage_t;

typedef struct {
	aliasskintype_t		type;		// single skin or group of skiins
	void				*pdata;		// either a daliasskinframe_t or group info
	float				interval;	// only used for skins in groups
	int					numgroupskins;	// only used by group headers
} aliasskinpackage_t;

typedef struct {
	int		numnormals;
	float	normals[20][3];
} vertexnormals;


typedef struct {
	vec3_t		v;
	int			lightnormalindex;
} trivert_t;

//============================================================================

trivert_t	verts[MAXFRAMES][MAXVERTS];
mdl_t	model;

char	file1[1024];
char	skinname[1024];
char	qbasename[1024];
float	scale, scale_up = 1.0;
vec3_t	mins, maxs;
vec3_t	framesmins, framesmaxs;
vec3_t		adjust;

aliaspackage_t	frames[MAXFRAMES];

aliasskinpackage_t	skins[MAXSKINS];

//
// base frame info
//
vec3_t		baseverts[MAXVERTS];
stvert_t	stverts[MAXVERTS];
dtriangle_t	triangles[MAXTRIANGLES];
int			degenerate[MAXTRIANGLES];


char		cdpartial[256];
char		cddir[256];

int			framecount, skincount;
qboolean		cdset;
int			degeneratetris;
int			firstframe = 1;
float		totsize, averagesize;

vertexnormals	vnorms[MAXVERTS];

#define NUMVERTEXNORMALS	162

float	avertexnormals[NUMVERTEXNORMALS][3] = {
#include "anorms.h"
};

trivertx_t	tarray[MAXVERTS];

char	outname[1024];


void ClearModel (void)
{
	memset (&model, 0, sizeof(model));
	model.synctype = ST_RAND;	// default
	framecount = skincount = 0;

	scale = 0;
	scale_up = 1.0;
	
	VectorCopy (vec3_origin, adjust);
	VectorCopy (vec3_origin, mins);
	VectorCopy (vec3_origin, maxs);
	VectorCopy (vec3_origin, framesmins);
	VectorCopy (vec3_origin, framesmaxs);

	degeneratetris = 0;
	cdset = false;
	firstframe = 1;
	totsize = 0.0;
}


/*
============
WriteFrame
============
*/
void WriteFrame (FILE *modelouthandle, int framenum)
{
	int				j, k;
	trivert_t		*pframe;
	daliasframe_t	aframe;
	float			v;

	pframe = verts[framenum];

	strcpy (aframe.name, frames[framenum].name);

	for (j=0 ; j<3 ; j++)
	{
		aframe.bboxmin.v[j] = 255;
		aframe.bboxmax.v[j] = 0;
	}

	for (j=0 ; j<model.numverts ; j++)
	{
	// all of these are byte values, so no need to deal with endianness
		tarray[j].lightnormalindex = pframe[j].lightnormalindex;

		if (tarray[j].lightnormalindex > NUMVERTEXNORMALS)
			Error ("invalid lightnormalindex %d\n",
					tarray[j].lightnormalindex);

		for (k=0 ; k<3 ; k++)
		{
		// scale to byte values & min/max check
			v = (pframe[j].v[k] - model.scale_origin[k]) / model.scale[k];

			tarray[j].v[k] = v;

			if (tarray[j].v[k] < aframe.bboxmin.v[k])
			{
				aframe.bboxmin.v[k] = tarray[j].v[k];
			}
			if (tarray[j].v[k] > aframe.bboxmax.v[k])
			{
				aframe.bboxmax.v[k] = tarray[j].v[k];
			}
			
			
		}
	}

	SafeWrite (modelouthandle, &aframe, sizeof (aframe));

	SafeWrite (modelouthandle, &tarray[0],
			   model.numverts * sizeof(tarray[0]));
}


/*
============
WriteGroupBBox
============
*/
void WriteGroupBBox (FILE *modelouthandle, int numframes, int curframe)
{
	int				i, j, k;
	daliasgroup_t	dagroup;
	trivert_t		*pframe;


	dagroup.numframes = LittleLong (numframes);

	for (i=0 ; i<3 ; i++)
	{
		dagroup.bboxmin.v[i] = 255;
		dagroup.bboxmax.v[i] = 0;
	}

	for (i=0 ; i<numframes ; i++)
	{
		pframe = (trivert_t *)frames[curframe].pdata;

		for (j=0 ; j<model.numverts ; j++)
		{
			for (k=0 ; k<3 ; k++)
			{
			// scale to byte values & min/max check
				tarray[j].v[k] = (pframe[j].v[k] - model.scale_origin[k]) /
									model.scale[k];
				if (tarray[j].v[k] < dagroup.bboxmin.v[k])
					dagroup.bboxmin.v[k] = tarray[j].v[k];
				if (tarray[j].v[k] > dagroup.bboxmax.v[k])
					dagroup.bboxmax.v[k] = tarray[j].v[k];
			}
		}

		curframe++;
	}

	SafeWrite (modelouthandle, &dagroup, sizeof(dagroup));
}


/*
============
WriteModel
============
*/
void WriteModelFile (FILE *modelouthandle)
{
	int		i, curframe, curskin;
	float	dist[3];
	mdl_t	modeltemp;

// Calculate the bounding box for this model
	for (i=0 ; i<3 ; i++)
	{
		printf ("framesmins[%d]: %f, framesmaxs[%d]: %f\n",
				i, framesmins[i], i, framesmaxs[i]);
		if (fabs (framesmins[i]) > fabs (framesmaxs[i]))
			dist[i] = framesmins[i];
		else
			dist[i] = framesmaxs[i];

		model.scale[i] = (framesmaxs[i] - framesmins[i]) / 255.9;
		model.scale_origin[i] = framesmins[i];
	}

	model.boundingradius = sqrt(dist[0] * dist[0] +
								dist[1] * dist[1] +
								dist[2] * dist[2]);

//
// write out the model header
//
	modeltemp.ident = LittleLong (IDPOLYHEADER);
	modeltemp.version = LittleLong (ALIAS_VERSION);
	modeltemp.boundingradius = LittleFloat (model.boundingradius);

	for (i=0 ; i<3 ; i++)
	{
		modeltemp.scale[i] = LittleFloat (model.scale[i]);
		modeltemp.scale_origin[i] = LittleFloat (model.scale_origin[i]);
		modeltemp.eyeposition[i] = LittleFloat (model.eyeposition[i] +
				adjust[i]);
	}

	modeltemp.flags = LittleLong (model.flags);
	modeltemp.numskins = LittleLong (model.numskins);
	modeltemp.skinwidth = LittleLong (model.skinwidth);
	modeltemp.skinheight = LittleLong (model.skinheight);
	modeltemp.numverts = LittleLong (model.numverts);
	modeltemp.numtris = LittleLong (model.numtris - degeneratetris);
	modeltemp.numframes = LittleLong (model.numframes);
	modeltemp.synctype = LittleFloat (model.synctype);
	averagesize = totsize / model.numtris;
	modeltemp.size = LittleFloat (averagesize);

	SafeWrite (modelouthandle, &modeltemp, sizeof(model));

//
// write out the skins
//
	curskin = 0;

	for (i=0 ; i<model.numskins ; i++)
	{
		SafeWrite (modelouthandle, &skins[curskin].type,
				   sizeof(skins[curskin].type));

		SafeWrite (modelouthandle, skins[curskin].pdata,
				   model.skinwidth * model.skinheight);

		curskin++;
	}

//
// write out the base model (the s & t coordinates for the vertices)
//
	for (i=0 ; i<model.numverts ; i++)
	{
		if (stverts[i].onseam == 3)
		{
			stverts[i].onseam = LittleLong (ALIAS_ONSEAM);
		}
		else
		{
			stverts[i].onseam = LittleLong (0);
		}

		stverts[i].s = LittleLong (stverts[i].s);
		stverts[i].t = LittleLong (stverts[i].t);
	}

	SafeWrite (modelouthandle, stverts, model.numverts * sizeof(stverts[0]));

//
// write out the triangles
//
	for (i=0 ; i<model.numtris ; i++)
	{
		int			j;
		dtriangle_t	tri;

		if (!degenerate[i])
		{
			tri.facesfront = LittleLong (triangles[i].facesfront);

			for (j=0 ; j<3 ; j++)
			{
				tri.vertindex[j] = LittleLong (triangles[i].vertindex[j]);
			}

			SafeWrite (modelouthandle,
					   &tri,
					   sizeof(tri));
		}
	}

//
// write out the frames
//
	curframe = 0;

	for (i=0 ; i<model.numframes ; i++)
	{
		SafeWrite (modelouthandle, &frames[curframe].type,
				   sizeof(frames[curframe].type));

		if (frames[curframe].type == ALIAS_SINGLE)
		{
		//
		// single (non-grouped) frame
		//
			WriteFrame (modelouthandle, curframe);
			curframe++;
		}
		else
		{
			int					j, numframes, groupframe;
			float				totinterval;

			groupframe = curframe;
			curframe++;
			numframes = frames[groupframe].numgroupframes;

		//
		// set and write the group header
		//
			WriteGroupBBox (modelouthandle, numframes, curframe);

		//
		// write the interval array
		//
			totinterval = 0.0;

			for (j=0 ; j<numframes ; j++)
			{
				daliasinterval_t	temp;

				totinterval += frames[groupframe+1+j].interval;
				temp.interval = LittleFloat (totinterval);

				SafeWrite (modelouthandle, &temp, sizeof(temp));
			}

			for (j=0 ; j<numframes ; j++)
			{
				WriteFrame (modelouthandle, curframe);
				curframe++;
			}
		}
	}
}


/*
===============
WriteModel
===============
*/
void WriteModel (void)
{
	FILE		*modelouthandle;
//
// write the model output file
//
	if (!framecount)
	{
		printf ("no frames grabbed, no file generated\n");
		return;
	}
	
	if (!skincount)
		Error ("frames with no skins\n");

	StripExtension (outname);
	strcat (outname, ".mdl");
	
	printf ("---------------------\n");
	printf ("writing %s:\n", outname);
	modelouthandle = SafeOpenWrite (outname);

	WriteModelFile (modelouthandle);
	
	printf ("%4d frame(s)\n", model.numframes);
	printf ("%4d ungrouped frame(s), including group headers\n", framecount);
	printf ("%4d skin(s)\n", model.numskins);
	printf ("%4d degenerate triangles(s) removed\n", degeneratetris);
	printf ("%4d triangles emitted\n", model.numtris - degeneratetris);
	printf ("pixels per triangle %f\n", averagesize);

	printf ("file size: %d\n", (int)ftell (modelouthandle) );
	printf ("---------------------\n");
	
	fclose (modelouthandle);
	
	ClearModel ();
}


/*
============
SetSkinValues

Called for the base frame
============
*/
void SetSkinValues (void)
{
	int			i;
	float		v;
	int			width, height, iwidth, iheight, skinwidth;
	float		basex, basey;

	for (i=0 ; i<3 ; i++)
	{
		mins[i] = 9999999;
		maxs[i] = -9999999;
	}
	
	for (i=0 ; i<model.numverts ; i++)
	{
		int		j;

		stverts[i].onseam = 0;

		for (j=0 ; j<3 ; j++)
		{
			v = baseverts[i][j];
			if (v < mins[j])
				mins[j] = v;
			if (v > maxs[j])
				maxs[j] = v;
		}
	}
	
	for (i=0 ; i<3 ; i++)
	{
		mins[i] = floor(mins[i]);
		maxs[i] = ceil(maxs[i]);
	}
	
	width = maxs[0] - mins[0];
	height = maxs[2] - mins[2];

	printf ("width: %i  height: %i\n",width, height);

	scale = 8;
	if (width*scale >= 150)
		scale = 150.0 / width;	
	if (height*scale >= 190)
		scale = 190.0 / height;
	iwidth = ceil(width*scale) + 4;
	iheight = ceil(height*scale) + 4;
	
	printf ("scale: %f\n",scale);
	printf ("iwidth: %i  iheight: %i\n",iwidth, iheight);
	
//
// determine which side of each triangle to map the texture to
//
	for (i=0 ; i<model.numtris ; i++)
	{
		int		j;
		vec3_t	vtemp1, vtemp2, normal;

		VectorSubtract (baseverts[triangles[i].vertindex[0]],
						baseverts[triangles[i].vertindex[1]],
						vtemp1);
		VectorSubtract (baseverts[triangles[i].vertindex[2]],
						baseverts[triangles[i].vertindex[1]],
						vtemp2);
		CrossProduct (vtemp1, vtemp2, normal);

		if (normal[1] > 0)
		{
			basex = iwidth + 2;
			triangles[i].facesfront = 0;
		}
		else
		{
			basex = 2;
			triangles[i].facesfront = 1;
		}
		basey = 2;
		
		for (j=0 ; j<3 ; j++)
		{
			float		*pbasevert;
			stvert_t	*pstvert;

			pbasevert = baseverts[triangles[i].vertindex[j]];
			pstvert = &stverts[triangles[i].vertindex[j]];

			if (triangles[i].facesfront)
			{
				pstvert->onseam |= 1;
			}
			else
			{
				pstvert->onseam |= 2;
			}

			if ((triangles[i].facesfront) || ((pstvert->onseam & 1) == 0))
			{
			// we want the front s value for seam vertices
				pstvert->s = Q_rint((pbasevert[0] - mins[0]) * scale + basex);
				pstvert->t = Q_rint((maxs[2] - pbasevert[2]) * scale + basey);
			}
		}
	}

// make the width a multiple of 4; some hardware requires this, and it ensures
// dword alignment for each scan
	skinwidth = iwidth*2;
	model.skinwidth = (skinwidth + 3) & ~3;
	model.skinheight = iheight;

	printf ("skin width: %i (unpadded width %i)  skin height: %i\n",
			model.skinwidth, skinwidth, model.skinheight);
}


/*
=================
Cmd_Base
=================
*/
void Cmd_Base (void)
{
	triangle_t	*ptri;
	int			i, j, k;
	int		time1;

	GetToken (false);
	strcpy (qbasename, token);

	sprintf (file1, "%s/%s.tri", cdpartial, token);
	ExpandPathAndArchive (file1);

	sprintf (file1, "%s/%s.tri", cddir, token);
	time1 = FileTime (file1);
	if (time1 == -1)
		Error ("%s doesn't exist", file1);

//
// load the base triangles
//
	LoadTriangleList (file1, &ptri, &model.numtris);
	printf("NUMBER OF TRIANGLES (including degenerate triangles): %d\n",
			model.numtris);

//
// run through all the base triangles, storing each unique vertex in the
// base vertex list and setting the indirect triangles to point to the base
// vertices
//
	for (i=0 ; i<model.numtris ; i++)
	{
		if (VectorCompare (ptri[i].verts[0], ptri[i].verts[1]) ||
			VectorCompare (ptri[i].verts[1], ptri[i].verts[2]) ||
			VectorCompare (ptri[i].verts[2], ptri[i].verts[0]))
		{
			degeneratetris++;
			degenerate[i] = 1;
		}
		else
		{
			degenerate[i] = 0;
		}

		for (j=0 ; j<3 ; j++)
		{
			for (k=0 ; k<model.numverts ; k++)
				if (VectorCompare (ptri[i].verts[j], baseverts[k]))
					break;	// this vertex is already in the base vertex list

			if (k == model.numverts)
			{
			//
			// new vertex
			//
				VectorCopy (ptri[i].verts[j], baseverts[model.numverts]);
				model.numverts++;
			}

			triangles[i].vertindex[j] = k;
		}
	}

	printf ("NUMBER OF VERTEXES: %i\n", model.numverts);

//
// calculate s & t for each vertex, and set the skin width and height
//
	SetSkinValues ();
}


/*
===============
Cmd_Skin
===============
*/
void Cmd_Skin (void)
{
	byte	*ppal;
	byte	*pskinbitmap;
	byte	*ptemp1, *ptemp2;
	int		i;
	int		time1;

	GetToken (false);	
	strcpy (skinname, token);

	sprintf (file1, "%s/%s.lbm", cdpartial, token);
	ExpandPathAndArchive (file1);

	sprintf (file1, "%s/%s.lbm", cddir, token);
	time1 = FileTime (file1);
	if (time1 == -1)
		Error ("%s not found", file1);
	
	if (TokenAvailable ())
	{
		GetToken (false);
		skins[skincount].interval = atof (token);
		if (skins[skincount].interval <= 0.0)
			Error ("Non-positive interval");
	}
	else
	{
		skins[skincount].interval = 0.1;
	}
	
//
// load in the skin .lbm file
//
	LoadLBM (file1, &pskinbitmap, &ppal);

//
// now copy the part of the texture we care about, since LBMs are always
// loaded as 320x200 bitmaps
//
	skins[skincount].pdata =
			malloc (model.skinwidth * model.skinheight);

	if (!skins[skincount].pdata)
		Error ("couldn't get memory for skin texture");

	ptemp1 = skins[skincount].pdata;
	ptemp2 = pskinbitmap;

	for (i=0 ; i<model.skinheight ; i++)
	{
		memcpy (ptemp1, ptemp2, model.skinwidth);
		ptemp1 += model.skinwidth;
		ptemp2 += 320;
	}

	skincount++;

	if (skincount > MAXSKINS)
		Error ("Too many skins; increase MAXSKINS");
}


/*
===============
GrabFrame
===============
*/
void GrabFrame (char *frame, int isgroup)
{
	triangle_t		*ptri;
	int				i, j;
	trivert_t		*ptrivert;
	int				numtris;
	int		time1;

	sprintf (file1, "%s/%s.tri", cdpartial, frame);
	ExpandPathAndArchive (file1);

	sprintf (file1, "%s/%s.tri",cddir, frame);
	time1 = FileTime (file1);
	if (time1 == -1)
		Error ("%s does not exist",file1);

	printf ("grabbing %s\n", file1);
	frames[framecount].interval = 0.1;
	strcpy (frames[framecount].name, frame);

//
// load the frame
//
	LoadTriangleList (file1, &ptri, &numtris);

	if (numtris != model.numtris)
		Error ("number of triangles doesn't match\n");

// set the intervals
	if (isgroup && TokenAvailable ())
	{
		GetToken (false);
		frames[framecount].interval = atof (token);
		if (frames[framecount].interval <= 0.0)
			Error ("Non-positive interval %s %f", token,
					frames[framecount].interval);
	}
	else
	{
		frames[framecount].interval = 0.1;
	}
	
//
// allocate storage for the frame's vertices
//
	ptrivert = verts[framecount];

	frames[framecount].pdata = ptrivert;
	frames[framecount].type = ALIAS_SINGLE;

	for (i=0 ; i<model.numverts ; i++)
	{
		vnorms[i].numnormals = 0;
	}

//
// store the frame's vertices in the same order as the base. This assumes the
// triangles and vertices in this frame are in exactly the same order as in the
// base
//
	for (i=0 ; i<numtris ; i++)
	{
		vec3_t	vtemp1, vtemp2, normal;
		float	ftemp;

		if (degenerate[i])
			continue;

		if (firstframe)
		{
			VectorSubtract (ptri[i].verts[0], ptri[i].verts[1], vtemp1);
			VectorSubtract (ptri[i].verts[2], ptri[i].verts[1], vtemp2);
			VectorScale (vtemp1, scale_up, vtemp1);
			VectorScale (vtemp2, scale_up, vtemp2);
			CrossProduct (vtemp1, vtemp2, normal);

			totsize += sqrt (normal[0] * normal[0] +
							 normal[1] * normal[1] +
							 normal[2] * normal[2]) / 2.0;
		}

		VectorSubtract (ptri[i].verts[0], ptri[i].verts[1], vtemp1);
		VectorSubtract (ptri[i].verts[2], ptri[i].verts[1], vtemp2);
		CrossProduct (vtemp1, vtemp2, normal);

		VectorNormalize (normal);

	// rotate the normal so the model faces down the positive x axis
		ftemp = normal[0];
		normal[0] = -normal[1];
		normal[1] = ftemp;

		for (j=0 ; j<3 ; j++)
		{
			int		k;
			int		vertindex;

			vertindex = triangles[i].vertindex[j];

		// rotate the vertices so the model faces down the positive x axis
		// also adjust the vertices to the desired origin
			ptrivert[vertindex].v[0] = ((-ptri[i].verts[j][1]) * scale_up) +
										adjust[0];
			ptrivert[vertindex].v[1] = (ptri[i].verts[j][0] * scale_up) +
										adjust[1];
			ptrivert[vertindex].v[2] = (ptri[i].verts[j][2] * scale_up) +
										adjust[2];

			for (k=0 ; k<3 ; k++)
			{
				if (ptrivert[vertindex].v[k] < framesmins[k])
					framesmins[k] = ptrivert[vertindex].v[k];

				if (ptrivert[vertindex].v[k] > framesmaxs[k])
					framesmaxs[k] = ptrivert[vertindex].v[k];
			}

			VectorCopy (normal,
						vnorms[vertindex].
						normals[vnorms[vertindex].numnormals]);

			vnorms[vertindex].numnormals++;
		}
	}

//
// calculate the vertex normals, match them to the template list, and store the
// index of the best match
//
	for (i=0 ; i<model.numverts ; i++)
	{
		int		j;
		vec3_t	v;
		float	maxdot;
		int		maxdotindex;

		if (vnorms[i].numnormals > 0)
		{
			for (j=0 ; j<3 ; j++)
			{
				int		k;
	
				v[j] = 0;
				
				for (k=0 ; k<vnorms[i].numnormals ; k++)
				{
					v[j] += vnorms[i].normals[k][j];
				}
	
				v[j] /= vnorms[i].numnormals;
			}
		}
		else
		{
			Error ("Vertex with no non-degenerate triangles attached");
		}

		VectorNormalize (v);

		maxdot = -999999.0;
		maxdotindex = -1;

		for (j=0 ; j<NUMVERTEXNORMALS ; j++)
		{
			float	dot;

			dot = DotProduct (v, avertexnormals[j]);
			if (dot > maxdot)
			{
				maxdot = dot;
				maxdotindex = j;
			}
		}

		ptrivert[i].lightnormalindex = maxdotindex;
	}

	framecount++;

	if (framecount >= MAXFRAMES)
		Error ("Too many frames; increase MAXFRAMES");

	free (ptri);
	firstframe = 0;
}

/*
===============
Cmd_Frame	
===============
*/
void Cmd_Frame (int isgroup)
{
	while (TokenAvailable())
	{
		GetToken (false);
		GrabFrame (token, isgroup);

		if (!isgroup)
			model.numframes++;
	}
}

/*
===============
Cmd_SkinGroupStart	
===============
*/
void Cmd_SkinGroupStart (void)
{
	int			groupskin;

	groupskin = skincount++;
	if (skincount >= MAXFRAMES)
		Error ("Too many skins; increase MAXSKINS");

	skins[groupskin].type = ALIAS_SKIN_GROUP;
	skins[groupskin].numgroupskins = 0;

	while (1)
	{
		GetToken (true);
		if (endofscript)
			Error ("End of file during group");

		if (!strcmp (token, "$skin"))
		{
			Cmd_Skin ();
			skins[groupskin].numgroupskins++;
		}
		else if (!strcmp (token, "$skingroupend"))
		{
			break;
		}
		else
		{
			Error ("$skin or $skingroupend expected\n");
		}

	}

	if (skins[groupskin].numgroupskins == 0)
		Error ("Empty group\n");
}


/*
===============
Cmd_FrameGroupStart	
===============
*/
void Cmd_FrameGroupStart (void)
{
	int			groupframe;

	groupframe = framecount++;
	if (framecount >= MAXFRAMES)
		Error ("Too many frames; increase MAXFRAMES");

	frames[groupframe].type = ALIAS_GROUP;
	frames[groupframe].numgroupframes = 0;

	while (1)
	{
		GetToken (true);
		if (endofscript)
			Error ("End of file during group");

		if (!strcmp (token, "$frame"))
		{
			Cmd_Frame (1);
		}
		else if (!strcmp (token, "$framegroupend"))
		{
			break;
		}
		else
		{
			Error ("$frame or $framegroupend expected\n");
		}

	}

	frames[groupframe].numgroupframes += framecount - groupframe - 1;

	if (frames[groupframe].numgroupframes == 0)
		Error ("Empty group\n");
}


/*
=================
Cmd_Origin
=================
*/
void Cmd_Origin (void)
{

// rotate points into frame of reference so model points down the positive x
// axis
	GetToken (false);
	adjust[1] = -atof (token);

	GetToken (false);
	adjust[0] = atof (token);

	GetToken (false);
	adjust[2] = -atof (token);
}


/*
=================
Cmd_Eyeposition
=================
*/
void Cmd_Eyeposition (void)
{

// rotate points into frame of reference so model points down the positive x
// axis
	GetToken (false);
	model.eyeposition[1] = atof (token);

	GetToken (false);
	model.eyeposition[0] = -atof (token);

	GetToken (false);
	model.eyeposition[2] = atof (token);
}


/*
=================
Cmd_ScaleUp
=================
*/
void Cmd_ScaleUp (void)
{

	GetToken (false);
	scale_up = atof (token);
}

/*
=================
Cmd_Flags
=================
*/
void Cmd_Flags (void)
{
	GetToken (false);
	model.flags = atoi (token);
}


/*
=================
Cmd_Modelname
=================
*/
void Cmd_Modelname (void)
{
	WriteModel ();
	GetToken (false);
	strcpy (outname, token);
}


/*
===============
ParseScript
===============
*/
void ParseScript (void)
{
	while (1)
	{
		do
		{	// look for a line starting with a $ command
			GetToken (true);
			if (endofscript)
				return;
			if (token[0] == '$')
				break;				
			while (TokenAvailable())
				GetToken (false);
		} while (1);
	
		if (!strcmp (token, "$modelname"))
		{
			Cmd_Modelname ();
		}
		else if (!strcmp (token, "$base"))
		{
			Cmd_Base ();
		}
		else if (!strcmp (token, "$cd"))
		{
			if (cdset)
				Error ("Two $cd in one model");
			cdset = true;
			GetToken (false);
			strcpy (cdpartial, token);
			strcpy (cddir, ExpandPath(token));
		}
		else if (!strcmp (token, "$sync"))
		{
			model.synctype = ST_SYNC;
		}
		else if (!strcmp (token, "$origin"))
		{
			Cmd_Origin ();
		}
		else if (!strcmp (token, "$eyeposition"))
		{
			Cmd_Eyeposition ();
		}
		else if (!strcmp (token, "$scale"))
		{
			Cmd_ScaleUp ();
		}
		else if (!strcmp (token, "$flags"))
		{
			Cmd_Flags ();
		}
		else if (!strcmp (token, "$frame"))
		{
			Cmd_Frame (0);
		}
		else if (!strcmp (token, "$skin"))
		{
			Cmd_Skin ();
			model.numskins++;
		}		
		else if (!strcmp (token, "$framegroupstart"))
		{
			Cmd_FrameGroupStart ();
			model.numframes++;
		}
		else if (!strcmp (token, "$skingroupstart"))
		{
			Cmd_SkinGroupStart ();
			model.numskins++;
		}
		else
		{
			Error ("bad command %s\n", token);
		}

	}
}

/*
==============
main
==============
*/
int main (int argc, char **argv)
{
	int		i;
	char	path[1024];

	if (argc != 2 && argc != 4)
		Error ("usage: modelgen [-archive directory] file.qc");
		
	if (!strcmp(argv[1], "-archive"))
	{
		archive = true;
		strcpy (archivedir, argv[2]);
		printf ("Archiving source to: %s\n", archivedir);
		i = 3;
	}
	else
		i = 1;

//
// load the script
//
	strcpy (path, argv[i]);
	DefaultExtension (path, ".qc");
	SetQdirFromPath (path);
	LoadScriptFile (path);
	
//
// parse it
//
	memset (&model, 0, sizeof(model));

	for (i=0 ; i<3 ; i++)
	{
		framesmins[i] = 9999999;
		framesmaxs[i] = -9999999;
	}


	ClearModel ();
	strcpy (outname, argv[1]);

	ParseScript ();
	WriteModel ();
	
	return 0;
}

