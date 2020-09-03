FIXTHIS: see tex/interrupt.ch

@x
@h
@y
#include <signal.h>
@h
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof((*f))) if (ferror((*f).f)) {fprintf(stderr, "!!!!!\n"); fflush(stderr);}
if (bypass_eoln) if (!eof((*f))) get((*f));
@z

@x
  while (!eoln((*f)))
@y
  if (ferror((*f).f)) {
    clearerr((*f).f);
    return true;
  }
  while (!eoln((*f)))
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
