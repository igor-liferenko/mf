see TODO in tex/interrupt.ch

@x
@h
@y
#include <signal.h>
#include <unistd.h>
@h
#define enabled_color (STDOUT_FILENO, enabled_, strlen(enabled_))
#define default_color (STDOUT_FILENO, default_, strlen(default_))
@z

@x
int @!interrupt; /*should \MF\ pause for instructions?*/
@y
volatile int interrupt;
char *enabled_ = "", *default_ = "";
void catchint(int signum)
{
  interrupt = !interrupt;
  if (interrupt) write enabled_color;
  else write default_color;
}
struct sigaction sa;
@z

@x
  print_err("Interruption");
@y
  signal(SIGINT, SIG_IGN);
  write default_color;
  print_err("Interruption");
@z

@x
  interrupt=0;
@y
  interrupt=0;
  sigaction(SIGINT, &sa, NULL);
@z

@x
initialize(); /*set global variables to their starting values*/ 
@y
if (isatty(STDOUT_FILENO) && !(enabled_ = getenv("enabled_color"))) enabled_ = "";
if (isatty(STDOUT_FILENO) && !(default_ = getenv("default_color"))) default_ = "";
sa.sa_handler = catchint;
sigemptyset(&sa.sa_mask);
sa.sa_flags = SA_RESTART;
sigaction(SIGINT, &sa, NULL);
initialize(); /*set global variables to their starting values*/ 
@z
