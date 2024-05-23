Screen contents are displayed by a separate process.
Screen contents are in shared memory.

@x
@h
@y
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/wait.h>
@h
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
int screen_width=768; /*number of pixels in each row of screen display*/
int screen_depth=1024; /*number of pixels in each column of screen display*/
@z

@x
#define reset(file,name,mode)   @[(file).f=fopen(name+1,mode),\
                             (file).f!=NULL?get(file):0@]
#define rewrite(file,name,mode) @[(file).f=fopen(name+1,mode)@]
@y
#define reset(file,name,mode)   @[(file).f=fopen(name+1,mode"e"),\
                             (file).f!=NULL?get(file):0@]
#define rewrite(file,name,mode) @[(file).f=fopen(name+1,mode"e")@]
@z

@x
@p bool init_screen(void)
{@+return false;
} 
@y
@p
typedef int32_t pixel_t; /* color is set in XRGB format (X byte is not used for anything) */
int shm_fd;
void *screen_data;
bool init_screen(void)
{
  if (!getenv("screen_size")) return false;

  assert((shm_fd = shm_open("/metafont", O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR)) != -1);
  assert(shm_unlink("/metafont") != -1);

  int screen_size = screen_width * screen_depth * sizeof (pixel_t);
  assert(ftruncate(shm_fd, screen_size) != -1);

  assert((screen_data = mmap(NULL, screen_size, PROT_WRITE, MAP_SHARED, shm_fd, 0)) != MAP_FAILED);

  pixel_t *pixel = screen_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = -1; /* initialize the memory */

  system("pkill --parent 1 hello-wayland"); /* destroy orphaned online display(s) - see README */

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
    execl("/home/user/mf-wayland/hello-wayland", "hello-wayland", (char *) NULL);
    _exit(0);
  }
}
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
  pixel_t *pixel;
  for (screen_row r = top_row; r < bot_row; r++) {
    pixel = screen_data;
    pixel += screen_width*r + left_col;
    for (screen_col c = left_col; c < right_col; c++)
      *pixel++ = -1;
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
  pixel_t *pixel = screen_data;
  pixel += screen_width*r + a[0];
  int k = 0;
  screen_col c = a[0];
  do {
    k++;
    do {
      *pixel++ = b ? 0 : -1;
      c++;
    } while (c != a[k]);
    b = !b;
  } while (k != n);
}
@z

@x
screen_col @!row_transition[screen_width+1]; /*an array of |black|/|white| transitions*/
@y
screen_col *row_transition; /*an array of |black|/|white| transitions*/
@z

@x
@p int main(void) {@! /*|start_here|*/
@y
@p int main(void) {@! /*|start_here|*/
if (getenv("screen_size")) sscanf(getenv("screen_size"), "%dx%d", &screen_width, &screen_depth);
assert(row_transition = (screen_col *) malloc((screen_width + 1) * sizeof (screen_col)));
@z
