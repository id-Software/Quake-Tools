
#include "cmdlib.h"
#include "threads.h"

#ifdef __alpha
int		numthreads = 4;
pthread_mutex_t	*my_mutex;
#else
int		numthreads = 1;
#endif

void InitThreads (void)
{
#ifdef __alpha
	pthread_mutexattr_t	mattrib;

	my_mutex = malloc (sizeof(*my_mutex));
	if (pthread_mutexattr_create (&mattrib) == -1)
		Error ("pthread_mutex_attr_create failed");
	if (pthread_mutexattr_setkind_np (&mattrib, MUTEX_FAST_NP) == -1)
		Error ("pthread_mutexattr_setkind_np failed");
	if (pthread_mutex_init (my_mutex, mattrib) == -1)
		Error ("pthread_mutex_init failed");
#endif
}

/*
===============
RunThreadsOn
===============
*/
void RunThreadsOn ( threadfunc_t func )
{
#ifdef __alpha
	pthread_t	work_threads[256];
	pthread_addr_t	status;
	pthread_attr_t	attrib;
	int		i;
	
	if (numthreads == 1)
	{
		func (NULL);
		return;
	}
		
	if (pthread_attr_create (&attrib) == -1)
		Error ("pthread_attr_create failed");
	if (pthread_attr_setstacksize (&attrib, 0x100000) == -1)
		Error ("pthread_attr_setstacksize failed");
	
	for (i=0 ; i<numthreads ; i++)
	{
  		if (pthread_create(&work_threads[i], attrib
		, (pthread_startroutine_t)func, (pthread_addr_t)i) == -1)
			Error ("pthread_create failed");
	}
		
	for (i=0 ; i<numthreads ; i++)
	{
		if (pthread_join (work_threads[i], &status) == -1)
			Error ("pthread_join failed");
	}
#else
	func (NULL);
#endif
}
