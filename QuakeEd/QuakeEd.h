
extern	id	quakeed_i;

extern	BOOL	filter_light, filter_path, filter_entities;
extern	BOOL	filter_clip_brushes, filter_water_brushes, filter_world;

extern	UserPath	*upath;

extern	id	g_cmd_out_i;

double I_FloatTime (void);

void NopSound (void);

void qprintf (char *fmt, ...);		// prints text to cmd_out_i

@interface QuakeEd : Window
{
	BOOL	dirty;
	char	filename[1024];		// full path with .map extension

// UI objects
	id		brushcount_i;
	id		entitycount_i;
	id		regionbutton_i;

	id		show_coordinates_i;
	id		show_names_i;

	id		filter_light_i;
	id		filter_path_i;
	id		filter_entities_i;
	id		filter_clip_i;
	id		filter_water_i;
	id		filter_world_i;
	
	id		cmd_in_i;		// text fields
	id		cmd_out_i;	
	
	id		xy_drawmode_i;	// passed over to xyview after init
}

- setDefaultFilename;
- (char *)currentFilename;

- updateAll;		// when a model has been changed
- updateCamera;		// when the camera has moved
- updateXY;
- updateZ;

- updateAll:sender;

- newinstance;		// force next flushwindow to clear all instance drawing
- redrawInstance;	// erase and redraw all instance now

- appDidInit:sender;
- appWillTerminate:sender;

- openProject:sender;

- textCommand: sender;

- applyRegion: sender;

- (BOOL)dirty;

- clear: sender;
- centerCamera: sender;
- centerZChecker: sender;

- changeXYLookUp: sender;

- setBrushRegion: sender;
- setXYRegion: sender;

- open: sender;
- save: sender;
- saveAs: sender;

- doOpen: (char *)fname;

- saveBSP:(char *)cmdline dialog:(BOOL)wt;

- BSP_Full: sender;
- BSP_FastVis: sender;
- BSP_NoVis: sender;
- BSP_relight: sender;
- BSP_stop: sender;
- BSP_entities: sender;

//
// UI querie for other objects
//
- (BOOL)showCoordinates;
- (BOOL)showNames;

@end

