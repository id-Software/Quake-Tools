
#import "qedefs.h"

// Add .h-files here for new inspectors
#import	"Things.h"
#import	"TexturePalette.h"
#import	"Preferences.h"

id		inspcontrol_i;

@implementation InspectorControl

- awakeFromNib
{
	inspcontrol_i = self;
		
	currentInspectorType = -1;

	contentList = [[List alloc] init];
	windowList = [[List alloc] init];
	itemList = [[List alloc] init];

	// ADD NEW INSPECTORS HERE...

	[windowList addObject:win_project_i];
	[contentList addObject:[win_project_i contentView]];
	[itemProject_i setKeyEquivalent:'1'];
	[itemList addObject:itemProject_i];

	[windowList addObject:win_textures_i];
	[contentList addObject:[win_textures_i contentView]];
	[itemTextures_i setKeyEquivalent:'2'];
	[itemList addObject:itemTextures_i];

	[windowList addObject:win_things_i];
	[contentList addObject:[win_things_i contentView]];
	[itemThings_i setKeyEquivalent:'3'];
	[itemList addObject:itemThings_i];
	
	[windowList addObject:win_prefs_i];
	[contentList addObject:[win_prefs_i contentView]];
	[itemPrefs_i setKeyEquivalent:'4'];
	[itemList addObject:itemPrefs_i];

	[windowList addObject:win_settings_i];
	[contentList addObject:[win_settings_i contentView]];
	[itemSettings_i setKeyEquivalent:'5'];
	[itemList addObject:itemSettings_i];

	[windowList addObject:win_output_i];
	[contentList addObject:[win_output_i contentView]];
	[itemOutput_i setKeyEquivalent:'6'];
	[itemList addObject:itemOutput_i];

	[windowList addObject:win_help_i];
	[contentList addObject:[win_help_i contentView]];
	[itemHelp_i setKeyEquivalent:'7'];
	[itemList addObject:itemHelp_i];

	// Setup inspector window with project subview first

	[inspectorView_i setAutoresizeSubviews:YES];

	inspectorSubview_i = [contentList objectAt:i_project];
	[inspectorView_i addSubview:inspectorSubview_i];

	currentInspectorType = -1;
	[self changeInspectorTo:i_project];

	return self;
}


//
//	Sent by the PopUpList in the Inspector
//	Each cell in the PopUpList must have the correct tag
//
- changeInspector:sender
{
	id	cell;

	cell = [sender selectedCell];
	[self changeInspectorTo:[cell tag]];
	return self;
}

//
//	Change to specific Inspector
//
- changeInspectorTo:(insp_e)which
{
	id		newView;
	NXRect	r;
	id		cell;
	NXRect	f;
	
	if (which == currentInspectorType)
		return self;
	
	currentInspectorType = which;
	newView = [contentList objectAt:which];
	
	cell = [itemList objectAt:which];	// set PopUpButton title
	[popUpButton_i setTitle:[cell title]];
	
	[inspectorView_i replaceSubview:inspectorSubview_i with:newView];
	[inspectorView_i getFrame:&r];
	inspectorSubview_i = newView;
	[inspectorSubview_i setAutosizing:NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];
	[inspectorSubview_i sizeTo:r.size.width - 4 :r.size.height - 4];
	
	[inspectorSubview_i lockFocus];
	[inspectorSubview_i getBounds:&f];
	PSsetgray(NX_LTGRAY);
	NXRectFill(&f);
	[inspectorSubview_i unlockFocus];
	[inspectorView_i display];
	
	return self;
}

- (insp_e)getCurrentInspector
{
	return currentInspectorType;
}


@end
