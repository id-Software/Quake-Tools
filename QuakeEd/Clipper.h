
extern	id	clipper_i;

@interface Clipper : Object
{
	int			num;
	vec3_t		pos[3];
	plane_t		plane;
}

- (BOOL)hide;
- XYClick: (NXPoint)pt;
- (BOOL)XYDrag: (NXPoint *)pt;
- ZClick: (NXPoint)pt;
- carve;
- flipNormal;
- (BOOL)getFace: (face_t *)pl;

- cameraDrawSelf;
- XYDrawSelf;
- ZDrawSelf;

@end

