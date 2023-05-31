See comments in tex/interrupt.ch

@x
@h
@y
#include <signal.h>
@h
@z

@x
int @!interrupt; /*should \MF\ pause for instructions?*/
@y
volatile
int @!interrupt; /*should \MF\ pause for instructions?*/
void catchint(int signum)
{
  interrupt = 1;
}
@z

@x
initialize(); /*set global variables to their starting values*/ 
@y
struct sigaction sa;
sa.sa_handler = catchint;
sigemptyset(&sa.sa_mask);
sa.sa_flags = SA_RESTART;
sigaction(SIGWINCH, &sa, NULL);
initialize(); /*set global variables to their starting values*/ 
@z
