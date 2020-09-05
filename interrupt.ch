MF is aborted when ^C is pressed when MF is waiting for input

@x
@h
@y
#include <signal.h>
#include <unistd.h>
@h
@z

@x
   /*open a text file for input*/
{@+reset((*f), name_of_file,"r");return reset_OK((*f));
@y
   /*open a text file for input*/
{@+if (((*f).f=fopen(name_of_file+1,"r"))!=NULL) {
  get((*f));
  if (ferror((*f).f)) kill(getpid(), SIGABRT), pause();
}
return reset_OK((*f));
@z

@x
if (bypass_eoln) if (!eof((*f))) get((*f));
@y
if (bypass_eoln) if (!eof((*f))) {
  get((*f));
  if (ferror((*f).f)) kill(getpid(), SIGABRT), pause();
}
@z

@x
    buffer[last]=xord[(*f).d];get((*f));incr(last);
@y
    buffer[last]=xord[(*f).d];get((*f));
    if (ferror((*f).f)) kill(getpid(), SIGABRT), pause();
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
