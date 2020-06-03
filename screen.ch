@x
@h
@y
typedef uint16_t screen_row;
typedef uint16_t screen_col;
typedef uint8_t pixel_color;
int screen_width, screen_depth;
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
@(/dev/null@>=
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
if (!getenv("SCREEN_SIZE") ||
    sscanf(getenv("SCREEN_SIZE"), "%dx%d", &screen_width, &screen_depth) != 2) putenv("NOWIN=1");
initialize(); /*set global variables to their starting values*/
@z
