@x
@h
@y
#include <sys/types.h>
#include <termios.h>
#include <signal.h>
#define wait_window \
  if (cpid != -1) { \
    struct termios tcattr; \
    tcgetattr(STDIN_FILENO, &tcattr); \
    tcattr.c_lflag &= ~(ECHO | ICANON); \
    tcsetattr(STDIN_FILENO, TCSANOW, &tcattr); \
    printf("Waiting...\r"); fflush(stdout); getchar(); kill(cpid, SIGTERM); \
    tcattr.c_lflag |= ECHO | ICANON; \
    tcsetattr(STDIN_FILENO, TCSANOW, &tcattr); \
  }
@h
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
@z

@x
@p bool init_screen(void)
{@+return false;
} 
@y
@p bool init_screen(void);
@z

@x
void update_screen(void) /*will be called only if |init_screen| returns |true|*/
{
#ifdef @!INIT
wlog_ln("Calling UPDATESCREEN");
#endif
 /*for testing only*/
}
@y
void update_screen(void);
@z

@x
@<Glob...@>=
@y
@<Glob...@>=
extern int screen_width, screen_depth;
extern pid_t cpid;
@z

@x
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
  screen_row @!top_row, screen_row @!bot_row)
{@+screen_row @!r;
screen_col @!c;
@/
#ifdef @!INIT
wlog_cr; /*this will be done only after |init_screen==true|*/
wlog_ln("Calling BLANKRECTANGLE(%d,%d,%d,%d)", left_col,
  right_col, top_row, bot_row);
#endif
} 
@y
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
  screen_row @!top_row, screen_row @!bot_row);
@z

@x
@p void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
  screen_col @!n)
{@+int @!k; /*an index into |a|*/
screen_col @!c; /*an index into |screen_pixel|*/
@/
#ifdef @!INIT
wlog("Calling PAINTROW(%d,%d;", r, b);
   /*this is done only after |init_screen==true|*/
for (k=0; k<=n; k++)
  {@+wlog("%d", a[k]);if (k!=n) wlog(",");
  }
wlog_ln(")");
#endif
} 
@y
@p void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
  screen_col @!n);
@z
