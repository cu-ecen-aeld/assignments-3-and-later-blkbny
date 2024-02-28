#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
    int retval = 0;
    FILE * fp;

    openlog(NULL, 0, LOG_USER);

    if ( argc != 3 )
    {
        // Log and return error
        syslog(LOG_ERR, "Invalid number of arguments: %d", argc);
        retval = 1;
    }
    else
    {
        // Log what we are writing where
        syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);

        // open/create file and write the second arg to it
        fp = fopen(argv[1], "w");
        if ( fp == NULL )
        {
            syslog(LOG_ERR, "Unable to open file.");
            retval = 1;
        }
        else
        {
            fputs(argv[2], fp);
            fclose(fp);
            retval = 0;
        }
    }

    closelog();
    return retval;
}