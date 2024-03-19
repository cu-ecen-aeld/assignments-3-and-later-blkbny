#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    thread_func_args->thread_complete_success = false;

    // Step 1: sleep for wait_to_obtain_ms 
    usleep(thread_func_args->wait_to_obtain_ms*1000);
    // Step 2: lock mutex
    int status = pthread_mutex_lock(thread_func_args->mutex);
    if (status != 0)
    {
        ERROR_LOG("Unable to Lock Mutex. status: %d", status);
    }
    else
    {
        // Step 3: wait for wait_to_release_ms
        usleep(thread_func_args->thread_complete_success*1000);
        // Step 4: unlock mutex
        status = pthread_mutex_unlock(thread_func_args->mutex);
        if (status != 0)
        {
            ERROR_LOG("Unable to unlock Mutex. status: %d", status);
        }
        else
        {
            thread_func_args->thread_complete_success = true;
        }
    }
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    bool retVal = true;

    struct thread_data* params = malloc(sizeof(struct thread_data));
    params->mutex = mutex;
    params->wait_to_obtain_ms = wait_to_obtain_ms;
    params->wait_to_release_ms = wait_to_release_ms;
    params->thread_complete_success = false;
    
    int status = pthread_create(thread, NULL, threadfunc, params);
    if (status!=0)
    {
        ERROR_LOG( "Thread unable to be created. status: %d", status);
        retVal = false;

    }

    return retVal;
}

