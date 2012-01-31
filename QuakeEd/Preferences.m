
#import "qedefs.h"

id	preferences_i;

#define	DEFOWNER	"QuakeEd2"

float		lightaxis[3] = {1, 0.6, 0.75};

@implementation Preferences

- init
{
	[super init];
	preferences_i = self;
	return self;
}

int _atoi (char *c)
{
	if (!c)
		return 0;
	return atoi(c);
}

int _atof (char *c)
{
	if (!c)
		return 0;
	return atof(c);
}

void WriteNumericDefault (char *name, float value)
{
	char	str[128];
	
	sprintf (str,"%f", value);
	NXWriteDefault (DEFOWNER, name, str);
}
void WriteStringDefault (char *name, char *value)
{
	NXWriteDefault (DEFOWNER, name, value);
}

//
//	Read in at start of program
//
- readDefaults
{
	char *string;
	float	value;
	
	string = (char *)NXGetDefaultValue(DEFOWNER,"ProjectPath");
	[self setProjectPath: string];
	
	string = (char *)NXGetDefaultValue(DEFOWNER,"BspSoundPath");
	[self setBspSoundPath:string];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"ShowBSPOutput"));
	[self setShowBSP:value];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"OffsetBrushCopy"));
	[self setBrushOffset:value];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"StartWad"));
	[self setStartWad:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Xlight"));
	[self setXlight:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Ylight"));
	[self setYlight:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Zlight"));
	[self setZlight:value];

	return self;
}


- setProjectPath:(char *)path
{
	if (!path)
		path = "";
	strcpy (projectpath, path);
	[startproject_i setStringValue: path];
	WriteStringDefault ("ProjectPath", path);
	return self;
}

- setCurrentProject:sender
{
	[startproject_i setStringValue: [project_i currentProjectFile]];
	[self UIChanged: self];
	return self;
}

- (char *)getProjectPath
{
	return projectpath;
}


//
//===============================================
//	BSP sound stuff
//===============================================
//
//	Set the BSP sound using an OpenPanel
//
- setBspSound:sender
{
	id	panel;
	char	*types[]={"snd",NULL};
	int	rtn;
	char	**filename;
	char	path[1024], file[64];
	
	panel = [OpenPanel new];

	ExtractFilePath (bspSound, path);
	ExtractFileBase (bspSound, file);
	
	rtn = [panel 
			runModalForDirectory:path 
			file: file
			types: types];

	if (rtn)
	{
		filename = (char **)[panel filenames];
		strcpy(bspSound,[panel directory]);
		strcat(bspSound,"/");
		strcat(bspSound,filename[0]);
		[self setBspSoundPath:bspSound];
		[self playBspSound];
	}

	return self;
}


//
//	Play the BSP sound
//
- playBspSound
{
	[bspSound_i play];	
	return self;
}


//
//	Set the bspSound path
//
- setBspSoundPath:(char *)path
{
	if (!path)
		path = "";
	strcpy(bspSound,path);

	if (bspSound_i)
		[bspSound_i free];
	bspSound_i = [[Sound alloc] initFromSoundfile:bspSound];
	if (!bspSound_i)
	{
		strcpy (bspSound, "/NextLibrary/Sounds/Funk.snd");
		bspSound_i = [[Sound alloc] initFromSoundfile:bspSound];
	}

	[bspSoundField_i setStringValue:bspSound];
	
	WriteStringDefault ("BspSoundPath", bspSound);
	
	return self;
}

//===============================================
//	Show BSP Output management
//===============================================

//
//	Set the state
//
- setShowBSP:(int)state
{
	showBSP = state;
	[showBSP_i setIntValue:state];
	WriteNumericDefault ("ShowBSPOutput", showBSP);

	return self;
}

//
//	Get the state
//
- (int)getShowBSP
{
	return showBSP;
}


//===============================================
//	"Offset Brush ..." management
//===============================================

//
//	Set the state
//
- setBrushOffset:(int)state
{
	brushOffset = state;
	[brushOffset_i setIntValue:state];
	WriteNumericDefault ("OffsetBrushCopy", state);
	return self;
}

//
//	Get the state
//
- (int)getBrushOffset
{
	return brushOffset;
}

//===============================================
//	StartWad
//===============================================

- setStartWad:(int)value		// set start wad (0-2)
{
	startwad = value;
	if (startwad<0 || startwad>2)
		startwad = 0;
	
	[startwad_i selectCellAt:startwad : 0];

	WriteNumericDefault ("StartWad", value);
	return self;
}

- (int)getStartWad
{
	return startwad;
}


//===============================================
//	X,Y,Z light values
//===============================================
//
//	Set the state
//
- setXlight:(float)value
{
	xlight = value;
	if (xlight < 0.25 || xlight > 1)
		xlight = 0.6;
	lightaxis[1] = xlight;
	[xlight_i setFloatValue:xlight];
	WriteNumericDefault ("Xlight", xlight);
	return self;
}
- setYlight:(float)value
{
	ylight = value;
	if (ylight < 0.25 || ylight > 1)
		ylight = 0.75;
	lightaxis[2] = ylight;
	[ylight_i setFloatValue:ylight];
	WriteNumericDefault ("Ylight", ylight);
	return self;
}
- setZlight:(float)value
{
	zlight = value;
	if (zlight < 0.25 || zlight > 1)
		zlight = 1;
	lightaxis[0] = zlight;
	[zlight_i setFloatValue:zlight];
	WriteNumericDefault ("Zlight", zlight);
	return self;
}

//
//	Get the state
//
- (float)getXlight
{
	return [xlight_i floatValue];
}
- (float)getYlight
{
	return [ylight_i floatValue];
}
- (float)getZlight
{
	return [zlight_i floatValue];
}



/*
============
UIChanged

Grab all the current UI state
============
*/
-UIChanged: sender
{
	qprintf ("defaults updated");
	
	[self setProjectPath: (char *)[startproject_i stringValue]];
	[self setBspSoundPath: (char *)[bspSoundField_i stringValue]];
	[self setShowBSP: [showBSP_i intValue]];
	[self setBrushOffset: [brushOffset_i intValue]];
	[self setStartWad: [startwad_i selectedRow]];
	[self setXlight: [xlight_i floatValue]];
	[self setYlight: [ylight_i floatValue]];
	[self setZlight: [zlight_i floatValue]];

	[map_i makeGlobalPerform: @selector(flushTextures)];
	[quakeed_i updateAll];
		
	return self;
}


@end
