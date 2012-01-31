
// Map is a list of Entity objects

extern	id	map_i;

@interface Map : List
{
	id		currentEntity;
	id		oldselection;	// temp when loading a new map
	float	minz, maxz;
}

- newMap;

- writeStats;

- readMapFile: (char *)fname;
- writeMapFile: (char *)fname useRegion: (BOOL)reg;

- entityConnect: (vec3_t)p1 : (vec3_t)p2;

- selectRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)ef;
- grabRay: (vec3_t)p1 : (vec3_t)p2;
- setTextureRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)allsides;
- getTextureRay: (vec3_t)p1 : (vec3_t)p2;

- currentEntity;
- setCurrentEntity: ent;

- (float)currentMinZ;
- setCurrentMinZ: (float)m;
- (float)currentMaxZ;
- setCurrentMaxZ: (float)m;

- (int)numSelected;
- selectedBrush;			// returns the first selected brush

//
// operations on current selection
//
- makeSelectedPerform: (SEL)sel;
- makeUnselectedPerform: (SEL)sel;
- makeAllPerform: (SEL)sel;
- makeGlobalPerform: (SEL)sel;	// in and out of region

- cloneSelection: sender;

- makeEntity: sender;

- subtractSelection: sender;

- selectCompletelyInside: sender;
- selectPartiallyInside: sender;

- tallBrush: sender;
- shortBrush: sender;

- rotate_x: sender;
- rotate_y: sender;
- rotate_z: sender;

- flip_x: sender;
- flip_y: sender;
- flip_z: sender;

- selectCompleteEntity: sender;

@end
