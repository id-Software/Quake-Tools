
#import <appkit/appkit.h>
#include <sys/stat.h>

#define BASEPATHKEY		"basepath"
#define	MAPNAMESKEY		"maps"
#define DESCKEY			"desc"
#define	WADSKEY			"wads"
#define	BSPFULLVIS		"bspfullvis"
#define	BSPFASTVIS		"bspfastvis"
#define	BSPNOVIS		"bspnovis"
#define	BSPRELIGHT		"bsprelight"
#define	BSPLEAKTEST		"bspleaktest"
#define	BSPENTITIES		"bspentities"

#define	SUBDIR_ENT		"progs"		// subdir names in heirarchy
#define	SUBDIR_MAPS		"maps"
#define SUBDIR_GFX		"gfx"

extern	id project_i;

@interface Project:Object
{
	id	projectInfo;		// dictionary storage of project info

	id	basepathinfo_i;		// outlet to base path info textfield
	id	mapbrowse_i;		// outlet to QuakeEd Maps browser
	id	currentmap_i;		// outlet to current map textfield
	id	mapList;			// list of map names (Storage)
	id	descList;			// list of map descriptions (Storage)
	id	wadList;			// list of wad names (Storage)
	
	id	pis_panel_i;		// outlet to Project Info Settings (PIS) panel

	id	pis_basepath_i;		// outlet to PIS->base path
	id	pis_wads_i;			// outlet to PIS->wad browser	
	id	pis_fullvis_i;		// outlet to PIS->full vis command
	id	pis_fastvis_i;		// outlet to PIS->fast vis command
	id	pis_novis_i;		// outlet to PIS->no vis command
	id	pis_relight_i;		// outlet to PIS->relight command
	id	pis_leaktest_i;		// outlet to PIS->leak test command

	id	BSPoutput_i;		// outlet to Text
	
	char	path_projectinfo[128];	// path of QE_Project file

	char	path_basepath[128];		// base path of heirarchy

	char	path_progdir[128];		// derived from basepath
	char	path_mapdirectory[128];	// derived from basepath
	char	path_finalmapdir[128];	// derived from basepath
	
	char	path_wad8[128];			// path of texture WAD for cmd-8 key
	char	path_wad9[128];			// path of texture WAD for cmd-9 key
	char	path_wad0[128];			// path of texture WAD for cmd-0 key

	char	string_fullvis[1024];	// cmd-line parm
	char	string_fastvis[1024];	// cmd-line parm
	char	string_novis[1024];		// cmd-line parm
	char	string_relight[1024];	// cmd-line parm
	char	string_leaktest[1024];	// cmd-line parm
	char	string_entities[1024];	// cmd-line parm

	int	showDescriptions;	// 1 = show map descs in browser

	time_t	lastModified;	// last time project file was modified
}

- initProject;
- initVars;

- (char *)currentProjectFile;

- setTextureWad: (char *)wf;

- addToOutput:(char *)string;
- clearBspOutput:sender;
- initProjSettings;
- changeChar:(char)f to:(char)t in:(id)obj;
- (int)searchForString:(char *)str in:(id)obj;

- parseProjectFile;		// read defaultsdatabase for project path
- openProjectFile:(char *)path;	// called by openProject and newProject
- openProject;
- clickedOnMap:sender;		// called if clicked on map in browser
- clickedOnWad:sender;		// called if clicked on wad in browser

//	methods to querie the project file

- (char *)getMapDirectory;
- (char *)getFinalMapDirectory;
- (char *)getProgDirectory;

- (char *)getWAD8;
- (char *)getWAD9;
- (char *)getWAD0;

- (char *)getFullVisCmd;
- (char *)getFastVisCmd;
- (char *)getNoVisCmd;
- (char *)getRelightCmd;
- (char *)getLeaktestCmd;
- (char *)getEntitiesCmd;

@end

void changeString(char cf,char ct,char *string);

