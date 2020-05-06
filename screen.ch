NOTE: freopen() is used to ensure that fgetc() does not return immediately (happens on Ctrl+D)
@x
@h
@y
#include <sys/types.h>
#include <termios.h>
#include <signal.h>
#include <stdlib.h>
#define wait_window \
  if (cpid != -1) { \
    printf("Waiting...\r"); fflush(stdout); \
    system("stty -F /dev/tty -echo -icanon"); \
    freopen("/dev/tty", "r", stdin); fgetc(stdin); \
    system("stty -F /dev/tty echo icanon"); \
    kill(cpid, SIGTERM); \
  }
@h
#include "screen.h"
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
@z

@x
@p bool init_screen(void)
@y
@(screen.h@>= bool init_screen(void)
@z

@x
@<Types...@>=
@y
@(screen.h@>=
extern pid_t cpid;
extern int screen_width, screen_depth;
@z

@x
@<Glob...@>=
@y
@<Glob...@>=
int screen_width, screen_depth;
@z

@x
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
@y
@(screen.h@>= void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
@z

@x
@p void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
@y
@(screen.h@>= void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
@z

@x
initialize(); /*set global variables to their starting values*/
@y
if (sscanf(getenv("SCREEN_WIDTH"), "%d", &screen_width) != 1) exit(0);
if (sscanf(getenv("SCREEN_DEPTH"), "%d", &screen_depth) != 1) exit(0);
initialize(); /*set global variables to their starting values*/
@z
