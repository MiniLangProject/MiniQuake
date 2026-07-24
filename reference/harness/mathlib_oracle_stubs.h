#ifndef MINIQUAKE_MATHLIB_ORACLE_STUBS_H
#define MINIQUAKE_MATHLIB_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];
typedef int fixed16_t;

typedef struct mplane_s
{
    vec3_t normal;
    float dist;
    byte type;
    byte signbits;
    byte pad[2];
} mplane_t;

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define PITCH 0
#define YAW 1
#define ROLL 2

#define DotProduct(x,y) \
    ((x)[0]*(y)[0] + (x)[1]*(y)[1] + (x)[2]*(y)[2])
#define VectorSubtract(a,b,c) \
    {(c)[0]=(a)[0]-(b)[0];(c)[1]=(a)[1]-(b)[1];(c)[2]=(a)[2]-(b)[2];}
#define VectorAdd(a,b,c) \
    {(c)[0]=(a)[0]+(b)[0];(c)[1]=(a)[1]+(b)[1];(c)[2]=(a)[2]+(b)[2];}
#define VectorCopy(a,b) \
    {(b)[0]=(a)[0];(b)[1]=(a)[1];(b)[2]=(a)[2];}

void *memcpy(void *destination, const void *source, unsigned __int64 count);
void *memset(void *destination, int value, unsigned __int64 count);
double fabs(double value);
double sin(double value);
double cos(double value);
double sqrt(double value);
double floor(double value);

void VectorMA(vec3_t veca, float scale, vec3_t vecb, vec3_t vecc);
vec_t _DotProduct(vec3_t v1, vec3_t v2);
void _VectorSubtract(vec3_t veca, vec3_t vecb, vec3_t out);
void _VectorAdd(vec3_t veca, vec3_t vecb, vec3_t out);
void _VectorCopy(vec3_t in, vec3_t out);
int VectorCompare(vec3_t v1, vec3_t v2);
vec_t Length(vec3_t v);
void CrossProduct(vec3_t v1, vec3_t v2, vec3_t cross);
float VectorNormalize(vec3_t v);
void VectorInverse(vec3_t v);
void VectorScale(vec3_t in, vec_t scale, vec3_t out);
int Q_log2(int val);
void R_ConcatRotations(float in1[3][3], float in2[3][3], float out[3][3]);
void R_ConcatTransforms(float in1[3][4], float in2[3][4], float out[3][4]);
void FloorDivMod(double numer, double denom, int *quotient, int *rem);
fixed16_t Invert24To16(fixed16_t val);
int GreatestCommonDivisor(int i1, int i2);
void AngleVectors(vec3_t angles, vec3_t forward, vec3_t right, vec3_t up);
int BoxOnPlaneSide(vec3_t emins, vec3_t emaxs, mplane_t *plane);
float anglemod(float a);
void ProjectPointOnPlane(vec3_t dst, const vec3_t p, const vec3_t normal);
void PerpendicularVector(vec3_t dst, const vec3_t src);
void RotatePointAroundVector(
    vec3_t dst, const vec3_t dir, const vec3_t point, float degrees);
void BOPS_Error(void);

#endif
