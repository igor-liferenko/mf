Screen contents are displayed by a separate process.
Screen contents are in shared memory.

@x
@h
@y
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>
@h
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
int screen_width=768; /*number of pixels in each row of screen display*/
int screen_depth=1024; /*number of pixels in each column of screen display*/
int shm_fd;
void *shm_data;
char *screen_prog, *screen_name = "online-display";
@z

@x
@p bool init_screen(void)
{@+return false;
} 
@y
@p bool init_screen(void)
{
  if (!getenv("screen_size")) return false;

  assert((shm_fd = shm_open("/metafont", O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR)) != -1);
  assert(shm_unlink("/metafont") != -1);

  int shm_size = screen_width * screen_depth * sizeof (pixel_color);
  assert(ftruncate(shm_fd, shm_size) != -1);

  assert((shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, shm_fd, 0)) != MAP_FAILED);

  pixel_color *pixel = shm_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = white;

  return true;
}
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
void update_screen(void) /*will be called only if |init_screen| returns |true|*/
{
  static pid_t screen_pid = -1;

  if (screen_pid != -1) {
    kill(screen_pid, SIGTERM);
    waitpid(screen_pid, NULL, 0);
  }

  assert((screen_pid = fork()) != -1);
  if (screen_pid == 0) {
    dup2(shm_fd, STDIN_FILENO);
    signal(SIGINT, SIG_IGN);
    execl(screen_prog, screen_name, (char *) NULL);
    _exit(0);
  }
}
@z

@x
@d white	0 /*background pixels*/
@d black	1 /*visible pixels*/
@y
@d white	0x00ffffff /* XRGB format */
@d black	0x00000000 /* (X byte is not used) */
@z

@x
typedef uint8_t pixel_color; /*specifies one of the two pixel values*/
@y
typedef uint32_t pixel_color; /*specifies one of the two pixel values*/
@z

@x
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
  screen_row @!top_row, screen_row @!bot_row)
{@+int @!r;
int @!c;
#if 0
@+for (r=top_row; r<=bot_row-1; r++)
  for (c=left_col; c<=right_col-1; c++)
    screen_pixel[r,c]=white;@+
#endif
@/
#ifdef @!INIT
wlog_cr; /*this will be done only after |init_screen==true|*/ 
wlog_ln("Calling BLANKRECTANGLE(%d,%d,%d,%d)", left_col,
  right_col, top_row, bot_row);
#endif
} 
@y
@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
  screen_row @!top_row, screen_row @!bot_row)
{
  pixel_color *pixel;
  for (screen_row r = top_row; r < bot_row; r++) {
    pixel = shm_data;
    pixel += screen_width * r + left_col;
    for (screen_col c = left_col; c < right_col; c++)
      *pixel++ = white;
  }
}
@z

@x
@p void paint_row(screen_row @!r, pixel_color @!b,@!screen_col *@!a,
  screen_col @!n)
{@+int @!k; /*an index into |a|*/ 
screen_col @!c; /*an index into |screen_pixel|*/ 
#if 0
@+k=0;c=(*a)[0];
@/do@+{incr(k);
  @/do@+{screen_pixel[r,c]=b;incr(c);
  }@+ while (!(c==(*a)[k]));
  b=black-b; /*$|black|\swap|white|$*/
  }@+ while (!(k==n));@+
#endif
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
@p void paint_row(screen_row r, pixel_color b, screen_col *a, screen_col n)
{
  pixel_color *pixel = shm_data;
  pixel += screen_width * r + a[0];
  int k = 0;
  screen_col c = a[0];
  do {
    k++;
    do {
      *pixel++ = b;
      c++;
    } while (c != a[k]);
    b = black == b ? white : black;
  } while (k != n);
}
@z

@x
screen_col @!row_transition[screen_width+1];
@y
screen_col *row_transition;
@z

@x
initialize(); /*set global variables to their starting values*/
@y
initialize(); /*set global variables to their starting values*/
if (getenv("screen_size")) {
  sscanf(getenv("screen_size"), "%dx%d", &screen_width, &screen_depth);
  assert(row_transition = (screen_col *) malloc((screen_width + 1) * sizeof (screen_col)));
  assert(screen_prog = (char *) calloc(base_area_length + strlen(screen_name), sizeof (char)));
  strncpy(screen_prog, MF_base_default+1, base_area_length-1);
  strcpy(strrchr(screen_prog, '/') + 1, screen_name);
}
@z
