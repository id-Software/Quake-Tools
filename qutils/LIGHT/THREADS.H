
#ifdef __alpha
#include <pthread.h>
extern	pthread_mutex_t	*my_mutex;
#define	LOCK	pthread_mutex_lock (my_mutex)
#define	UNLOCK	pthread_mutex_unlock (my_mutex)
#else
#define	LOCK
#define	UNLOCK
#endif

extern	int		numthreads;

typedef void (threadfunc_t) (void *);

void InitThreads (void);
void RunThreadsOn ( threadfunc_t func );
