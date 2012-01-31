#include "qlumpy.h"

typedef struct
{
	short	ofs, length;
} row_t;

typedef struct
{
	int		width, height;
	int		widthbits, heightbits;
	unsigned char	data[4];
} qtex_t;

typedef struct
{
	int			width, height;
	byte		data[4];			// variably sized
} qpic_t;


#define SCRN(x,y)       (*(byteimage+(y)*byteimagewidth+x))


/*
==============
GrabRaw

filename RAW x y width height
==============
*/
void GrabRaw (void)
{
	int             x,y,xl,yl,xh,yh,w,h;
	byte            *screen_p;
	int             linedelta;

	GetToken (false);
	xl = atoi (token);
	GetToken (false);
	yl = atoi (token);
	GetToken (false);
	w = atoi (token);
	GetToken (false);
	h = atoi (token);

	xh = xl+w;
	yh = yl+h;

	screen_p = byteimage + yl*byteimagewidth + xl;
	linedelta = byteimagewidth - w;

	for (y=yl ; y<yh ; y++)
	{
		for (x=xl ; x<xh ; x++)
		{
			*lump_p++ = *screen_p;
			*screen_p++ = 0;
		}
		screen_p += linedelta;
	}
}



/*
==============
GrabPalette

filename PALETTE [startcolor endcolor]
==============
*/
void GrabPalette (void)
{
	int             start,end,length;

	if (TokenAvailable())
	{
		GetToken (false);
		start = atoi (token);
		GetToken (false);
		end = atoi (token);
	}
	else
	{
		start = 0;
		end = 255;
	}

	length = 3*(end-start+1);
	memcpy (lump_p, lbmpalette+start*3, length);
	lump_p += length;
}


/*
==============
GrabPic

filename qpic x y width height
==============
*/
void GrabPic (void)
{
	int             x,y,xl,yl,xh,yh;
	int             width;
	byte            transcolor;
	qpic_t 			*header;

	GetToken (false);
	xl = atoi (token);
	GetToken (false);
	yl = atoi (token);
	GetToken (false);
	xh = xl-1+atoi (token);
	GetToken (false);
	yh = yl-1+atoi (token);

	if (xh<xl || yh<yl || xl < 0 || yl<0 || xh>319 || yh>199)
		Error ("GrabPic: Bad size: %i, %i, %i, %i",xl,yl,xh,yh);

	transcolor = 255;


//
// fill in header
//
	header = (qpic_t *)lump_p;
	width = xh-xl+1;
	header->width = LittleLong(width);
	header->height = LittleLong(yh-yl+1);

//
// start grabbing posts
//
	lump_p = (byte *)header->data;

	for (y=yl ; y<= yh ; y++)
		for (x=xl ; x<=xh ; x++)
			*lump_p++ = SCRN(x,y);
}

/*
=============================================================================

COLORMAP GRABBING

=============================================================================
*/

/*
===============
BestColor
===============
*/
byte BestColor (int r, int g, int b, int start, int stop)
{
	int	i;
	int	dr, dg, db;
	int	bestdistortion, distortion;
	int	bestcolor;
	byte	*pal;

//
// let any color go to 0 as a last resort
//
	bestdistortion = ( (int)r*r + (int)g*g + (int)b*b )*2;
	bestcolor = 0;

	pal = lbmpalette + start*3;
	for (i=start ; i<= stop ; i++)
	{
		dr = r - (int)pal[0];
		dg = g - (int)pal[1];
		db = b - (int)pal[2];
		pal += 3;
		distortion = dr*dr + dg*dg + db*db;
		if (distortion < bestdistortion)
		{
			if (!distortion)
				return i;		// perfect match

			bestdistortion = distortion;
			bestcolor = i;
		}
	}

	return bestcolor;
}


/*
==============
GrabColormap

filename COLORMAP levels fullbrights
the first map is an identiy 0-255
the final map is all black except for the fullbrights
the remaining maps are evenly spread
fullbright colors start at the top of the palette.
==============
*/
void GrabColormap (void)
{
	int		levels, brights;
	int		l, c;
	float	frac, red, green, blue;
		
	GetToken (false);
	levels = atoi (token);
	GetToken (false);
	brights = atoi (token);

// identity lump
	for (l=0 ; l<256 ; l++)
		*lump_p++ = l;

// shaded levels
	for (l=1;l<levels;l++)
	{
		frac = 1.0 - (float)l/(levels-1);
		for (c=0 ; c<256-brights ; c++)
		{
			red = lbmpalette[c*3];
			green = lbmpalette[c*3+1];
			blue = lbmpalette[c*3+2];

			red = (int)(red*frac+0.5);
			green = (int)(green*frac+0.5);
			blue = (int)(blue*frac+0.5);
			
//
// note: 254 instead of 255 because 255 is the transparent color, and we
// don't want anything remapping to that
//
			*lump_p++ = BestColor(red,green,blue, 0, 254);
		}
		for ( ; c<256 ; c++)
			*lump_p++ = c;
	}
	
	*lump_p++ = brights;
}

/*
==============
GrabColormap2

experimental -- not used by quake

filename COLORMAP2 range levels fullbrights
fullbright colors start at the top of the palette.
Range can be greater than 1 to allow overbright color tables.

the first map is all 0
the last (levels-1) map is at range
==============
*/
void GrabColormap2 (void)
{
	int		levels, brights;
	int		l, c;
	float	frac, red, green, blue;
	float	range;
	
	GetToken (false);
	range = atof (token);
	GetToken (false);
	levels = atoi (token);
	GetToken (false);
	brights = atoi (token);

// shaded levels
	for (l=0;l<levels;l++)
	{
		frac = range - range*(float)l/(levels-1);
		for (c=0 ; c<256-brights ; c++)
		{
			red = lbmpalette[c*3];
			green = lbmpalette[c*3+1];
			blue = lbmpalette[c*3+2];

			red = (int)(red*frac+0.5);
			green = (int)(green*frac+0.5);
			blue = (int)(blue*frac+0.5);
			
//
// note: 254 instead of 255 because 255 is the transparent color, and we
// don't want anything remapping to that
//
			*lump_p++ = BestColor(red,green,blue, 0, 254);
		}

		// fullbrights allways stay the same
		for ( ; c<256 ; c++)
			*lump_p++ = c;
	}
	
	*lump_p++ = brights;
}

/*
=============================================================================

MIPTEX GRABBING

=============================================================================
*/

typedef struct
{
	char		name[16];
	unsigned	width, height;
	unsigned	offsets[4];		// four mip maps stored
} miptex_t;

byte	pixdata[256];

int		d_red, d_green, d_blue;

/*
=============
AveragePixels
=============
*/
byte AveragePixels (int count)
{
	int		r,g,b;
	int		i;
	int		vis;
	int		pix;
	int		dr, dg, db;
	int		bestdistortion, distortion;
	int		bestcolor;
	byte	*pal;
	int		fullbright;
	int		e;
	
	vis = 0;
	r = g = b = 0;
	fullbright = 0;
	for (i=0 ; i<count ; i++)
	{
		pix = pixdata[i];
		if (pix == 255)
			fullbright = 2;
		else if (pix >= 240)
		{
return pix;
			if (!fullbright)
			{
				fullbright = true;
				r = 0;
				g = 0;
				b = 0;
			}
		}
		else
		{
			if (fullbright)
				continue;
		}
		
		r += lbmpalette[pix*3];
		g += lbmpalette[pix*3+1];
		b += lbmpalette[pix*3+2];
		vis++;
	}
	
	if (fullbright == 2)
		return 255;
		
	r /= vis;
	g /= vis;
	b /= vis;
	
	if (!fullbright)
	{
		r += d_red;
		g += d_green;
		b += d_blue;
	}
	
//
// find the best color
//
	bestdistortion = r*r + g*g + b*b;
	bestcolor = 0;
	if (fullbright)
	{
		i = 240;
		e = 255;
	}
	else
	{
		i = 0;
		e = 240;
	}
	
	for ( ; i< e ; i++)
	{
		pix = i;	//pixdata[i];

		pal = lbmpalette + pix*3;

		dr = r - (int)pal[0];
		dg = g - (int)pal[1];
		db = b - (int)pal[2];

		distortion = dr*dr + dg*dg + db*db;
		if (distortion < bestdistortion)
		{
			if (!distortion)
			{
				d_red = d_green = d_blue = 0;	// no distortion yet
				return pix;		// perfect match
			}

			bestdistortion = distortion;
			bestcolor = pix;
		}
	}

	if (!fullbright)
	{	// error diffusion
		pal = lbmpalette + bestcolor*3;
		d_red = r - (int)pal[0];
		d_green = g - (int)pal[1];
		d_blue = b - (int)pal[2];
	}

	return bestcolor;
}


/*
==============
GrabMip

filename MIP x y width height
must be multiples of sixteen
==============
*/
void GrabMip (void)
{
	int             x,y,xl,yl,xh,yh,w,h;
	byte            *screen_p, *source;
	int             linedelta;
	miptex_t		*qtex;
	int				miplevel, mipstep;
	int				xx, yy, pix;
	int				count;
	
	GetToken (false);
	xl = atoi (token);
	GetToken (false);
	yl = atoi (token);
	GetToken (false);
	w = atoi (token);
	GetToken (false);
	h = atoi (token);

	if ( (w & 15) || (h & 15) )
		Error ("line %i: miptex sizes must be multiples of 16", scriptline);

	xh = xl+w;
	yh = yl+h;

	qtex = (miptex_t *)lump_p;
	qtex->width = LittleLong(w);
	qtex->height = LittleLong(h);
	strcpy (qtex->name, lumpname); 
	
	lump_p = (byte *)&qtex->offsets[4];
	
	screen_p = byteimage + yl*byteimagewidth + xl;
	linedelta = byteimagewidth - w;

	source = lump_p;
	qtex->offsets[0] = LittleLong(lump_p - (byte *)qtex);

	for (y=yl ; y<yh ; y++)
	{
		for (x=xl ; x<xh ; x++)
		{
			pix = *screen_p;
			*screen_p++ = 0;
			if (pix == 255)
				pix = 0;
			*lump_p++ = pix;
		}
		screen_p += linedelta;
	}
	
//
// subsample for greater mip levels
//
	d_red = d_green = d_blue = 0;	// no distortion yet

	for (miplevel = 1 ; miplevel<4 ; miplevel++)
	{
		qtex->offsets[miplevel] = LittleLong(lump_p - (byte *)qtex);
		
		mipstep = 1<<miplevel;
		for (y=0 ; y<h ; y+=mipstep)
		{

			for (x = 0 ; x<w ; x+= mipstep)
			{
				count = 0;
				for (yy=0 ; yy<mipstep ; yy++)
					for (xx=0 ; xx<mipstep ; xx++)
					{
						pixdata[count] = source[ (y+yy)*w + x + xx ];
						count++;
					}
				*lump_p++ = AveragePixels (count);
			}	
		}
	}


}
