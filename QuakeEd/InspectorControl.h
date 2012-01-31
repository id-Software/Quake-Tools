
#import <appkit/appkit.h>

#define MINIWINICON	"DoomEdIcon"

typedef enum
{
	i_project,
	i_textures,
	i_things,
	i_prefs,
	i_settings,
	i_output,
	i_help,
	i_end
} insp_e;

extern	id		inspcontrol_i;

@interface InspectorControl:Object
{
	id	inspectorView_i;	// inspector view
	id	inspectorSubview_i;	// inspector view's current subview (gets replaced)

	id	contentList;		// List of contentviews (corresponds to
							// insp_e enum order)
	id	windowList;			// List of Windows (corresponds to
							// insp_e enum order)

	id	obj_textures_i;		// TexturePalette object (for delegating)
	id	obj_genkeypair_i;	// GenKeyPair object

	id	popUpButton_i;		// PopUpList title button
	id	popUpMatrix_i;		// PopUpList matrix
	id	itemList;			// List of popUp buttons
		
	insp_e	currentInspectorType;	// keep track of current inspector
	//
	//	Add id's here for new inspectors
	//  **NOTE: Make sure PopUpList has correct TAG value that
	//  corresponds to the enums above!
	
	// Windows
	id	win_project_i;		// project
	id	win_textures_i;		// textures
	id	win_things_i;		// things
	id	win_prefs_i;		// preferences
	id	win_settings_i;		// project settings
	id	win_output_i;		// bsp output
	id	win_help_i;			// documentation
	
	// PopUpList objs
	id	itemProject_i;		// project
	id	itemTextures_i;		// textures
	id	itemThings_i;		// things
	id	itemPrefs_i;		// preferences
	id	itemSettings_i;		// project settings
	id	itemOutput_i;		// bsp output
	id	itemHelp_i;			// docs
}

- awakeFromNib;
- changeInspector:sender;
- changeInspectorTo:(insp_e)which;
- (insp_e)getCurrentInspector;

@end

@protocol InspectorControl
- windowResized;
@end
