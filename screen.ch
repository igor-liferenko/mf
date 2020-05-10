@x
@h
@y
#include "screen.h"
#include "wayland.c"
@h
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
@z

@x
@p bool init_screen(void)
@y
@(/dev/null@>= bool init_screen(void)
@z

@x
@<Types...@>=
@y
@(screen.h@>=
int screen_width, screen_depth;
@z

@x
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
@y
@(/dev/null@>= void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
@z

@x
@p void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
@y
@(/dev/null@>= void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
@z

@x
initialize(); /*set global variables to their starting values*/
@y
if (sscanf(getenv("SCREEN_WIDTH"), "%d", &screen_width) != 1) exit(0);
if (sscanf(getenv("SCREEN_DEPTH"), "%d", &screen_depth) != 1) exit(0);
initialize(); /*set global variables to their starting values*/
@z
