MF is aborted when ^C is pressed when MF is waiting for input

@x
@h
@y
#include <signal.h>
#include <unistd.h>
@h
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof((*f))) {
  get((*f));
  if (ferror((*f).f)) kill(getpid(), SIGABRT), pause();
}
@z

This should not be necessary.
@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[(*f).d];get((*f));
    if (ferror((*f).f)) {
      fprintf(stderr, "This can happen!\n"); fflush(stderr);
      kill(getpid(), SIGABRT), pause();
    }
    incr(last);
@z

@x
int @!interrupt; /*should \MF\ pause for instructions?*/
@y
volatile int @!interrupt;
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
sa.sa_flags = 0;
sigaction(SIGINT, &sa, NULL);
initialize(); /*set global variables to their starting values*/ 
@z
