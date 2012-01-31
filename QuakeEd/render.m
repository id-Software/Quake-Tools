
#import "qedefs.h"


//define	NOLIGHT

vec3_t		r_origin, r_matrix[3];

int			t_width, t_height;
unsigned	*t_data;
int			t_widthmask, t_heightmask, t_widthshift;
float		t_widthadd, t_heightadd;

int			r_width, r_height;
float		*r_zbuffer;
unsigned	*r_picbuffer;

vec5_t		rightside, leftside, rightstep,leftstep;

face_t		*r_face;

BOOL		r_drawflat;

pixel32_t	r_flatcolor;

int	sy[20];

/*
====================
REN_ClearBuffers
====================
*/
void REN_ClearBuffers (void)
{
	int		size;
		
	size = r_width * r_height*4;

	memset (r_zbuffer, 0, size);
	memset (r_picbuffer, 0, size);	
}


/*
====================
REN_SetTexture
====================
*/

void REN_SetTexture (face_t *face)
{
	int		i;
	int		t_heightshift;
	qtexture_t	*q;

	if (!face->qtexture)
		face->qtexture = TEX_ForName (face->texture.texture);	// try to load
	q = face->qtexture;
	
	t_width = q->width;
	t_height = q->height;
	t_data = q->data;
	r_flatcolor = q->flatcolor;

	r_flatcolor.chan[0] *= r_face->light;
	r_flatcolor.chan[1] *= r_face->light;
	r_flatcolor.chan[2] *= r_face->light;
	
	t_widthadd = t_width*1024;
	t_heightadd = t_height*1024;
	
	t_widthmask = t_width-1;
	t_heightmask = t_height-1;
	
	t_widthshift = 0;
	i = t_width;
	while (i >= 2)
	{
		t_widthshift++;
		i>>=1;
	}
	
	t_heightshift = 0;
	i = t_width;
	while (i >= 2)
	{
		t_heightshift++;
		i>>=1;
	}
	
	if ( (1<<t_widthshift) != t_width || (1<<t_heightshift) != t_height)
		t_widthshift = t_heightshift = 0;	// non power of two
}

/*
==================
REN_DrawSpan
==================
*/
void REN_DrawSpan (int y)
{
	int			x, count;
	int			ofs;
	int			tx, ty;
	int			x1, x2;
	float		ufrac, vfrac, zfrac, lightfrac, ustep, vstep, zstep;
	pixel32_t	*in, *out;
	float		scale;
		
	if (y<0 || y >= r_height)
		return;
		
	x1 = (leftside[0]);
	x2 = (rightside[0]);

	count = x2 - x1;
	if (count < 0)
		return;
	
	zfrac = leftside[2];
	ufrac = leftside[3];
	vfrac = leftside[4];
	lightfrac = r_face->light;
	
	if (!count)
		scale = 1;
	else
		scale = 1.0/count;
		
	zstep = (rightside[2] - zfrac)*scale;
	ustep = (rightside[3] - ufrac)*scale;
	vstep = (rightside[4] - vfrac)*scale;
	
	if (x1 < 0)
	{
		ufrac -= x1*ustep;
		vfrac -= x1*vstep;
		zfrac -= x1*zstep;
		x1 = 0;
	}
	
	if (x2 > r_width)
		x2 = r_width;

	ofs = y*r_width+x1;
	
// this should be specialized for 1.0 / 0.5 / 0.75 light levels
	for (x=x1 ; x < x2 ; x++)
	{
		if (r_zbuffer[ofs] <= zfrac)
		{
			scale = 1/zfrac;

			r_zbuffer[ofs] = zfrac;

			if (t_widthshift)
			{
				tx = (int)((ufrac*scale)) & t_widthmask;
				ty = (int)((vfrac*scale)) & t_heightmask;
				in = (pixel32_t *)&t_data [(ty<<t_widthshift)+tx];
			}
			else
			{
				tx = (int)((ufrac*scale)+t_widthadd) % t_width;
				ty = (int)((vfrac*scale)+t_heightadd) % t_height;
				in = (pixel32_t *)&t_data [ty*t_width+tx];
			}
				
			out = (pixel32_t *)&r_picbuffer[ofs];
#ifdef NOLIGHT
			*out = *in;
#else
			out->chan[0] = in->chan[0]*lightfrac;
			out->chan[1] = in->chan[1]*lightfrac;
			out->chan[2] = in->chan[2]*lightfrac;
			out->chan[3] = 0xff;
#endif
		}
		ufrac += ustep;
		vfrac += vstep;
		zfrac += zstep;
		ofs++;
	}

}

/*
==================
REN_DrawFlatSpan
==================
*/
void REN_DrawFlatSpan (int y)
{
	int			x, count;
	int			ofs;
	int			x1, x2;
	float		zfrac, zstep;
	pixel32_t	*out;
		
	if (y<0 || y >= r_height)
		return;
		
	x1 = (leftside[0]);
	x2 = (rightside[0]);

	count = x2 - x1;
	if (count < 0)
		return;
	
	zfrac = leftside[2];
	
	zstep = (rightside[2] - zfrac)/count;
	
	if (x1 < 0)
	{
		zfrac -= x1*zstep;
		x1 = 0;
	}
	
	if (x2 > r_width)
		x2 = r_width;

	ofs = y*r_width+x1;
	
// this should be specialized for 1.0 / 0.5 / 0.75 light levels
	for (x=x1 ; x < x2 ; x++)
	{
		if (r_zbuffer[ofs] <= zfrac)
		{
			r_zbuffer[ofs] = zfrac;
			out = (pixel32_t *)&r_picbuffer[ofs];
			*out = r_flatcolor.p;
		}
		zfrac += zstep;
		ofs++;
	}

}

/*
=====================
REN_RasterizeFace

=====================
*/
void REN_RasterizeFace (winding_t *w)
{
	int			y;
	int			i;
	int			top, bot;
	int			leftv, rightv;
	int			count;
	int 		numvertex;

//
// find top vertex
//
	numvertex = w->numpoints;
	top = 0x7fffffff;
	bot = 0x80000000;
	leftv = 0;
	
	for (i=0 ; i<numvertex ; i++)
	{
		w->points[i][3] *= w->points[i][2];
		w->points[i][4] *= w->points[i][2];

		sy[i] = (int)w->points[i][1];
		
		if (sy[i] < top)
		{
			top = sy[i];
			leftv = i;
		}
		if (sy[i] > bot)
			bot = sy[i];
	}
	rightv = leftv;	
	
	if (top < 0 || bot > r_height || top > bot)
		return;		// shouldn't have to have this...
		
//
// render a trapezoid
//
	y = top;
	
	while (y < bot)
	{
		if (y >= sy[leftv])
		{
			do
			{
				for (i=0 ; i<5 ; i++)
					leftside[i] = w->points[leftv][i];
				leftv--;
				if (leftv == -1)
					leftv = numvertex-1;
			} while (sy[leftv] <= y);
			count = sy[leftv]-y;
			for (i=0 ; i<5 ; i++)
				leftstep[i] = (w->points[leftv][i] - leftside[i])/count;
		}
		if (y >= sy[rightv])
		{
			do
			{
				for (i=0 ; i<5 ; i++)
					rightside[i] = w->points[rightv][i];
				rightv++;
				if (rightv == numvertex)
					rightv = 0;
			} while (sy[rightv] <= y);
			count = sy[rightv]-y;
			for (i=0 ; i<5 ; i++)
				rightstep[i] = (w->points[rightv][i] - rightside[i])/count;
		}
		
		if (r_drawflat)
			REN_DrawFlatSpan (y);
		else
			REN_DrawSpan (y);
		
		for (i=0 ; i<5 ; i++)
		{
			leftside[i] += leftstep[i];
			rightside[i] += rightstep[i];
		}
			
		y++;
	}
}

//=============================================================================

/*
==================
REN_DrawSpanLinear
==================
*/
void REN_DrawSpanLinear (int y)
{
	int			x, count;
	int			ofs;
	int			tx, ty;
	int			x1, x2;
	float		ufrac, vfrac, zfrac, ustep, vstep, zstep;
	pixel32_t	*in, *out;
	float		scale;
			
	if (y<0 || y >= r_height)
		return;
		
	x1 = (leftside[0]);
	x2 = (rightside[0]);

	count = x2 - x1;
	if (count < 0)
		return;
		
	zfrac = leftside[2];
	ufrac = leftside[3];
	vfrac = leftside[4];
	
	if (!count)
		scale = 1;
	else
		scale = 1.0/count;
		
	zstep = (rightside[2] - zfrac)*scale;
	ustep = (rightside[3] - ufrac)*scale;
	vstep = (rightside[4] - vfrac)*scale;

	
	if (x1 < 0)
	{
		ufrac -= x1*ustep;
		vfrac -= x1*vstep;
		zfrac -= x1*zstep;
		x1 = 0;
	}
	
	if (x2 > r_width)
		x2 = r_width;

	ofs = y*r_width+x1;
		
	for (x=x1 ; x < x2 ; x++)
	{
		if (r_zbuffer[ofs] <= zfrac)
		{
			r_zbuffer[ofs] = zfrac;

			if (t_widthshift)
			{
				tx = (int)ufrac & t_widthmask;
				ty = (int)vfrac & t_heightmask;
				in = (pixel32_t *)&t_data [(ty<<t_widthshift)+tx];
			}
			else
			{
				tx = (int)(ufrac+t_widthadd) % t_width;
				ty = (int)(vfrac+t_heightadd) % t_height;
				in = (pixel32_t *)&t_data [ty*t_width+tx];
			}
	
			out = (pixel32_t *)&r_picbuffer[ofs];
			*out = *in;
		}
		ufrac += ustep;
		vfrac += vstep;
		zfrac += zstep;
		ofs++;
	}

}

/*
=====================
REN_RasterizeFaceLinear

=====================
*/
void REN_RasterizeFaceLinear (winding_t *w)
{
	int			y;
	int			i;
	int			top, bot;
	int			leftv, rightv;
	int			count;
	int			numvertex;
	
//
// find top vertex
//
	numvertex = w->numpoints;
	top = 0x7fffffff;
	bot = 0x80000000;

	leftv = 0;
	for (i=0 ; i<numvertex ; i++)
	{
		sy[i] = (int)w->points[i][1];
		
		if (sy[i] < top)
		{
			top = sy[i];
			leftv = i;
		}
		if (sy[i] > bot)
			bot = sy[i];
	}
	rightv = leftv;	
	
	if (top < 0 || bot > r_height || top > bot)
		return;		// shouldn't have to have this...
		
//
// render a trapezoid
//
	y = top;
	
	while (y < bot)
	{
		if (y >= sy[leftv])
		{
			do
			{
				for (i=0 ; i<5 ; i++)
					leftside[i] = w->points[leftv][i];
				leftv--;
				if (leftv == -1)
					leftv = numvertex-1;
			} while (sy[leftv] <= y);
			count = sy[leftv]-y;
			for (i=0 ; i<5 ; i++)
				leftstep[i] = (w->points[leftv][i] - leftside[i])/count;
		}
		if (y >= sy[rightv])
		{
			do
			{
				for (i=0 ; i<5 ; i++)
					rightside[i] = w->points[rightv][i];
				rightv++;
				if (rightv == numvertex)
					rightv = 0;
			} while (sy[rightv] <= y);
			count = sy[rightv]-y;
			for (i=0 ; i<5 ; i++)
				rightstep[i] = (w->points[rightv][i] - rightside[i])/count;
		}
		
		REN_DrawSpanLinear (y);
		
		for (i=0 ; i<5 ; i++)
		{
			leftside[i] += leftstep[i];
			rightside[i] += rightstep[i];
		}
			
		y++;
	}
}

//============================================================================

/*
==================
REN_BeginCamera
===================
*/
float	r_width_2, r_height_3;
plane_t	frustum[5];

void REN_BeginCamera (void)
{
	r_width_2 = (float)r_width / 2;
	r_height_3 = (float)r_height / 3;
	
	
// clip to right side
	frustum[0].normal[0] = -1;
	frustum[0].normal[1] = 0;
	frustum[0].normal[2] = 1;
	frustum[0].dist = 0;

// clip to left side
	frustum[1].normal[0] = 1;
	frustum[1].normal[1] = 0;
	frustum[1].normal[2] = 1;
	frustum[1].dist = 0;

// clip to top side
	frustum[2].normal[0] = 0;
	frustum[2].normal[1] = -1;
	frustum[2].normal[2] = r_height_3 / r_width_2;
	frustum[2].dist = 0;

// clip to bottom side
	frustum[3].normal[0] = 0;
	frustum[3].normal[1] = 1;
	frustum[3].normal[2] = 2*r_height_3 / r_width_2;	
	frustum[3].dist = 0;

// near Z
	frustum[4].normal[0] = 0;
	frustum[4].normal[1] = 0;
	frustum[4].normal[2] = 1;
	frustum[4].dist = 1;
}


void REN_BeginXY (void)
{
	frustum[0].normal[0] = 1;
	frustum[0].normal[1] = 0;
	frustum[0].normal[2] = 0;
	frustum[0].dist = 0;
		
	frustum[1].normal[0] = -1;
	frustum[1].normal[1] = 0;
	frustum[1].normal[2] = 0;
	frustum[1].dist = -r_width;

	frustum[2].normal[0] = 0;
	frustum[2].normal[1] = 1;
	frustum[2].normal[2] = 0;
	frustum[2].dist = 0;

	frustum[3].normal[0] = 0;
	frustum[3].normal[1] = -1;
	frustum[3].normal[2] = 0;
	frustum[3].dist = -r_height;
}

/*
=====================
REN_DrawCameraFace
=====================
*/
void REN_DrawCameraFace (face_t *idpol)
{
	int		i;
	float		scale;	
	int			numvertex;
	winding_t	*w, *in;
	vec3_t		temp;
	
	if (!idpol->w)
		return;	// overconstrained plane
		
	r_face = idpol;

//
// back face cull
//
	if (DotProduct (r_origin, idpol->plane.normal) <= idpol->plane.dist)
		return;

//
// transform in 3D (FIXME: clip first, then transform)
//
	in = idpol->w;
	numvertex = in->numpoints;

	w = NewWinding (numvertex);
	w->numpoints = numvertex;
	for (i=0 ; i<numvertex ; i++)
	{
		VectorSubtract (in->points[i], r_origin, temp);
	
		w->points[i][0] = DotProduct(temp,r_matrix[0]);
		w->points[i][1] = DotProduct(temp,r_matrix[1]);
		w->points[i][2] = DotProduct(temp,r_matrix[2]);

		w->points[i][3] = in->points[i][3];
		w->points[i][4] = in->points[i][4];
	}
	
//
// 3D clip
//
	for (i=0 ; i<4 ; i++)
	{
		w = ClipWinding (w, &frustum[i]);
		if (!w)
			return;
	}
		
//
// project to 2D
//
	for (i=0 ; i<w->numpoints ; i++)
	{
		scale = r_width_2 / w->points[i][2];
		w->points[i][0] = r_width_2 + scale*w->points[i][0];
		w->points[i][1] = r_height_3 - scale*w->points[i][1];
		w->points[i][2] = scale;
	}
	
	
//
// draw it
//
	REN_SetTexture (idpol);
	
	REN_RasterizeFace (w);
	free (w);
}


/*
=====================
REN_DrawXYFace
=====================
*/
void REN_DrawXYFace (face_t *idpol)
{
	int			i, j, numvertex;
	winding_t	*w, *in;
	float		*dest, *source;
	float		temp;
	
	if (!idpol->w)
		return;	// overconstrained plane
	w = idpol->w;
		
	r_face = idpol;
	
//
// back (and side) face cull
//
	if (DotProduct (idpol->plane.normal, xy_viewnormal) > -VECTOR_EPSILON)
		return;

//
// transform
//
	in = idpol->w;
	numvertex = in->numpoints;

	w = NewWinding (numvertex);
	w->numpoints = numvertex;

	for (i=0 ; i<numvertex ; i++)
	{
	// using Z as a scale for the 2D projection
		w->points[i][0] = (in->points[i][0] - r_origin[0])*r_origin[2];
		w->points[i][1] = r_height - (in->points[i][1] - r_origin[1])*r_origin[2];
		w->points[i][2] = in->points[i][2] + 3000;
		w->points[i][3] = in->points[i][3];
		w->points[i][4] = in->points[i][4];
	}
	
//
// clip
//
	for (i=0 ; i<4 ; i++)
	{
		w = ClipWinding (w, &frustum[i]);
		if (!w)
			return;
	}
		
//
// project to 2D
//
	for (i=0 ; i<w->numpoints ; i++)
	{
		dest = w->points[i];
		if (dest[0] < 0)
			dest[0] = 0;
		if (dest[0] > r_width)
			dest[0] = r_width;
		if (dest[1] < 0)
			dest[1] = 0;
		if (dest[1] > r_height)
			dest[1] = r_height;
		if (xy_viewnormal[2] > 0)
			dest[2] = 4096-dest[2];
	}

	if (xy_viewnormal[2] > 0)
	{	// flip order when upside down
		for (i=0 ; i<w->numpoints/2 ; i++)
		{
			dest = w->points[i];
			source = w->points[w->numpoints-1-i];
			for (j=0 ; j<5 ; j++)
			{
				temp = dest[j];
				dest[j] = source[j];
				source[j] = temp;
			}
		}
	}
	
	REN_SetTexture (idpol);
	
	
//
// draw it
//
	REN_RasterizeFaceLinear (w);
	free (w);
}

