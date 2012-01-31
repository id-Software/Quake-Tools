
#define DEFAULTLIGHTLEVEL	300

typedef struct epair_s
{
	struct epair_s	*next;
	char	key[MAX_KEY];
	char	value[MAX_VALUE];
} epair_t;

typedef struct entity_s
{
	char	classname[64];
	vec3_t	origin;
	float	angle;
	int		light;
	int		style;
	char	target[32];
	char	targetname[32];
	struct epair_s	*epairs;
	struct entity_s	*targetent;
} entity_t;

extern	entity_t	entities[MAX_MAP_ENTITIES];
extern	int			num_entities;

char 	*ValueForKey (entity_t *ent, char *key);
void 	SetKeyValue (entity_t *ent, char *key, char *value);
float	FloatForKey (entity_t *ent, char *key);
void 	GetVectorForKey (entity_t *ent, char *key, vec3_t vec);

void LoadEntities (void);
void WriteEntitiesToString (void);
