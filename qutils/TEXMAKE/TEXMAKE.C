#include "cmdlib.h"
#include "mathlib.h"
#include "lbmlib.h"
#include "trilib.h"


triangle_t	*faces;
int		numfaces;

byte	pic[64000];
byte	*palette;

int		width, height;
int		iwidth, iheight;

float	scale;

char	texname[20];


/*
================
BoundFaces
================
*/
vec3_t	mins, maxs;

void BoundFaces (void)
{
	int		i,j,k;
	triangle_t	*pol;
	float	v;

	for (i=0 ; i<numfaces ; i++)
	{
		pol = &faces[i];
		for (j=0 ; j<3 ; j++)
			for (k=0 ; k<3 ; k++)
			{
				v = pol->verts[j][k];
				if (v<mins[k])
					mins[k] = v;
				if (v>maxs[k])
					maxs[k] = v;
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
}


/*
============
DrawLine

Draw a fat line
============
*/
void DrawLine (int x1, int y1, int x2, int y2)
{
	int		dx, dy;
	int		adx, ady;
	int		count;
	float	xfrac, yfrac, xstep, ystep;
	unsigned		sx, sy;
	float		u, v;
	
	dx = x2 - x1;
	dy = y2 - y1;
	adx = abs(dx);
	ady = abs(dy);
	
	count = adx > ady ? adx : ady;
	count ++;
	
	if (count > 300)
		return;		// don't ever hang up on bad data
		
	xfrac = x1;
	yfrac = y1;
	
	xstep = (float)dx / count;
	ystep = (float)dy / count;
	
	do
	{
		for (u=-0.1 ; u<=0.9 ; u+=0.999)
			for (v=-0.1 ; v<=0.9 ; v+=0.999)
			{
				sx = xfrac+u;
				sy = yfrac+v;
				if (sx < 320 && sy < 200)
					pic[sy*320+sx] = 255;
			}
			
		xfrac += xstep;
		yfrac += ystep;
		count--;
	} while (count > 0);
}


/*
============
AddFace
============
*/
void AddFace (triangle_t *f)
{
	vec3_t		v1, v2, normal;
	int		basex, basey;
	int			i, j;
	int		coords[3][2];

//
// determine which side to map the teture to
//
	VectorSubtract (f->verts[0], f->verts[1], v1);
	VectorSubtract (f->verts[2], f->verts[1], v2);
	CrossProduct (v1, v2, normal);
	
	if (normal[1] > 0)
		basex = iwidth + 2;
	else
		basex = 2;
	basey = 2;

	for (i=0 ; i<3 ; i++)
	{
		coords[i][0] = Q_rint((f->verts[i][0] - mins[0])*scale + basex);
		coords[i][1] = Q_rint( (maxs[2] - f->verts[i][2])*scale + basey);
	}
	
//
// draw lines
//
	for (i=0 ; i<3 ; i++)
	{
		j = (i+1)%3;
		DrawLine (coords[i][0], coords[i][1],
		coords[j][0], coords[j][1]);
	}
}


/*
============
CalcPalette
============
*/
void CalcPalette (void)
{
	byte *picture;
	LoadLBM (ExpandPath("id1/gfx/gamepal.lbm"), &picture, &palette);
}



/*
============
main
============
*/
void main (int argc, char **argv)
{
	int		i;
	char	filename[1024];
				
	if (argc == 1)
		Error ("texmake polfile[.idpol]\nGenerates polfile.lbm and polfile_t.idpol\n");
	
//
// read the polfile
//	
	strcpy (filename, argv[1]);
	DefaultExtension (filename, ".tri");
	SetQdirFromPath (filename);
	LoadTriangleList (filename, &faces, &numfaces);
	printf ("numfaces: %i\n",numfaces);
	
//
// generate the texture coordinates
//
	BoundFaces ();
	
//
// generate the lbm
//
	for (i=0 ; i<numfaces ; i++)
		AddFace (&faces[i]);
		
//
// save the lbm
//
	strcpy (filename, argv[1]);
	StripExtension (filename);
	strcat (filename, ".lbm");

	printf ("output file: %s\n",filename);
	CalcPalette ();
	WriteLBMfile (filename, pic, 320, 200, palette);	
}
