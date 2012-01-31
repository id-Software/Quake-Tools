
extern	id	preferences_i;

extern	float		lightaxis[3];

// these are personal preferences saved in NeXT defaults, not project
// parameters saved in the quake.qe_project file

@interface Preferences:Object
{
	id		bspSound_i;			// actual sound object

// internal state
	char	projectpath[1024];
	char	bspSound[1024];
	
	BOOL	brushOffset;
	BOOL	showBSP;

	float	xlight;
	float	ylight;
	float	zlight;				// 0.0 - 1.0
	
	int		startwad;			// 0 - 2
	
// UI targets
	id	startproject_i;			// TextField	

	id	bspSoundField_i;		// TextField of bspSound	

	id	brushOffset_i;			// Brush Offset checkbox
	id	showBSP_i;				// Show BSP Output checkbox
	
	id	startwad_i;				// which wad to load at startup

	id	xlight_i;				// X-side lighting
	id	ylight_i;				// Y-side lighting
	id	zlight_i;				// Z-side lighting	
}

- readDefaults;

//
// validate and set methods called by UI or defaults
//
- setProjectPath:(char *)path;
- setBspSoundPath:(char *)path;	// set the path of the soundfile externally
- setShowBSP:(int)state;		// set the state of ShowBSP
- setBrushOffset:(int)state;	// set the state of BrushOffset
- setStartWad:(int)value;		// set start wad (0-2)
- setXlight:(float)value;		// set Xlight value for CameraView
- setYlight:(float)value;		// set Ylight value for CameraView
- setZlight:(float)value;		// set Zlight value for CameraView

//
// UI targets
//
- setBspSound:sender;			// use OpenPanel to select sound
- setCurrentProject:sender;		// make current roject the default
- UIChanged: sender;			// target for all checks and fields

//
// methods used by other objects to retreive defaults
//
- playBspSound;

- (char *)getProjectPath;
- (int)getBrushOffset;			// get the state
- (int)getShowBSP;				// get the state

- (float)getXlight;				// get Xlight value
- (float)getYlight;				// get Ylight value
- (float)getZlight;				// get Zlight value

- (int)getStartWad;


@end
