#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
    int retval = 0;
    
    if ( argc != 3 )
    {
        // Log and return error
        printf("Invalid number of params, expected: 3, received: %d", argc);
        retval = 1;
    }
    else
    {
        // open/create file and write the second arg to it
        retval = 0;
    }

    return retval;
}