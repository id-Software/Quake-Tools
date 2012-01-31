#ifndef __MATHLIB__
#define __MATHLIB__

#include "cmdlib.h"

// mathlib.h

typedef float vec_t;
typedef vec_t vec3_t[3];

extern vec3_t vec3_origin;

boolean VectorCompare (vec3_t v1, vec3_t v2);

#define DotProduct(x,y) (x[0]*y[0]+x[1]*y[1]+x[2]*y[2])
#define VectorSubtract(a,b,c) {c[0]=a[0]-b[0];c[1]=a[1]-b[1];c[2]=a[2]-b[2];}
#define VectorAdd(a,b,c) {c[0]=a[0]+b[0];c[1]=a[1]+b[1];c[2]=a[2]+b[2];}
#define VectorCopy(a,b) {b[0]=a[0];b[1]=a[1];b[2]=a[2];}

vec_t _DotProduct (vec3_t v1, vec3_t v2);
void _VectorSubtract (vec3_t va, vec3_t vb, vec3_t out);
void _VectorAdd (vec3_t va, vec3_t vb, vec3_t out);
void _VectorCopy (vec3_t in, vec3_t out);

void CrossProduct (vec3_t v1, vec3_t v2, vec3_t cross);
void VectorNormalize (vec3_t v);
void VectorScale (vec3_t v, vec_t scale, vec3_t out);
double VectorLength(vec3_t v);
void VectorMA (vec3_t va, double scale, vec3_t vb, vec3_t vc);

#endif
