We need to run metafont and wayland processes in parallel,
because a Wayland application runs in an endless loop.
Screen data is stored in memory, which is shared among the processes.

@x
@h
@y
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
@h
@z

@x
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/
@y
int screen_width, screen_depth;
@z

@x
@p bool init_screen(void)
{@+return false;
} 
@y
@p
int screen_fd;
void *screen_data;
bool init_screen(void)
{
  if (!getenv("SCREEN_SIZE")) return false;

  /* allocate memory and associate file descriptor with it */
  screen_fd = syscall(SYS_memfd_create, "metafont", 0);
  if (screen_fd == -1) return false;
  int screen_size = screen_width * screen_depth * 4;
  if (ftruncate(screen_fd, screen_size) == -1) {
    close(screen_fd);
    return false;
  }

  /* get address of memory, referred to by the file descriptor */
  screen_data = mmap(NULL, screen_size, PROT_WRITE, MAP_SHARED, screen_fd, 0);
  if (screen_data == MAP_FAILED) {
    close(screen_fd);
    return false;
  }

  /* initialize the memory */
  int *pixel = screen_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = 0xffffff;

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
/* Here |SIGUSR1| is sent to wayland process.
On receiving this signal
wayland process updates the screen (if it is in
foreground) and writes the result to pipe.
Killing and starting wayland process is used as a
means of bringing it to foreground. */

#define read_end fd[0]
#define write_end fd[1]

void update_screen(void)
{
  static pid_t screen_pid = -1;
  static int fd[2];

  char byte = '0';
  if (screen_pid != -1) {
    kill(screen_pid, SIGUSR1);
    read(read_end, &byte, 1);
  }
  if (byte == '0') {
    /* stop wayland process if it is already running */
    if (screen_pid != -1) {
      kill(screen_pid, SIGTERM);
      waitpid(screen_pid, NULL, 0);
      close(read_end);
    }

    /* start wayland process */
    assert(pipe(fd) != -1);
    assert((screen_pid = fork()) != -1);
    if (screen_pid == 0) {
      dup2(screen_fd, STDIN_FILENO);
      dup2(write_end, STDOUT_FILENO);
      signal(SIGINT, SIG_IGN);
      prctl(PR_SET_PDEATHSIG, SIGTERM);
      execl("/home/user/mf-wayland/hello-wayland", "hello-wayland", (char *) NULL);
      exit(0);
    }
    close(write_end);

    /* wait until wayland process is initialized */
    assert(read(read_end, &byte, 1));
  }
}
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
  screen_row @!top_row, screen_row @!bot_row)
{
  int *pixel;
  for (screen_row r = top_row; r < bot_row; r++) {
    pixel = screen_data;
    pixel += screen_width*r + left_col;
    for (screen_col c = left_col; c < right_col; c++)
      *pixel++ = 0xffffff;
  }
}
@z

@x
@p void paint_row(screen_row @!r, pixel_color @!b,@!screen_col *@!a,
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
@p void paint_row(screen_row r, pixel_color b, screen_col *a, screen_col n)
{
  int *pixel = screen_data;
  pixel += screen_width*r + a[0];
  int k = 0;
  screen_col c = a[0];
  do {
    k++;
    do {
      *pixel++ = b ? 0x000000 : 0xffffff;
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
initialize(); /*set global variables to their starting values*/
@y
if (getenv("SCREEN_SIZE")) sscanf(getenv("SCREEN_SIZE"), "%dx%d", &screen_width, &screen_depth);
assert(row_transition = (screen_col *) malloc((screen_width + 1) * sizeof (screen_col)));
initialize(); /*set global variables to their starting values*/
@z
