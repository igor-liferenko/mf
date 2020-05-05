\let\lheader\rheader
\datethis
\noinx

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.

We need to run {\logo METAFONT} and Wayland in parallel, so the method is to use |fork| and |exec|,
because the wayland program cannot terminate---it is a general rule for all Wayland
applications---they work in endless loop. As we are using |fork|, {\logo METAFONT} process
automatically has the pid of Wayland process, which is used to send signals to it.

Data is communicated to child wayland process via shared memory.

@c
@<Header files@>@;
@<Type definitions@>@;
@<Global variables@>@;

@c
static int fd;
extern int screen_width, screen_depth;
static void *shm_data;

typedef uint32_t pixel_t; /* color is set in XRGB format (X byte is not used for anything) */
#define BLACK 0x000000
#define WHITE 0xffffff

bool init_screen(void)
{
  @<Create pipe for communication with the child@>@;

  fd = syscall(SYS_memfd_create, "shm", 0);
  if (fd == -1) return false;
  int shm_size = screen_width * screen_depth * sizeof (pixel_t);
  if (ftruncate(fd, shm_size) == -1) {
    close(fd);
    return false;
  }
  shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, fd, 0);
  if (shm_data == MAP_FAILED) {
    close(fd);
    return false;
  }

  pixel_t *pixel = shm_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = WHITE;

  return true;
}

@ @<Global...@>=
static int pipefd[2]; /* used to determine if the child has started, to get on-top status
  and for synchronization */

@ We do not need to close write end of pipe in parent, because child cannot exit by itself
(thus |read| in |update_screen| will never block). So, we need to create pipe only once,
even though child may be forked multiple times.

I specifically do not implement exit via keybind in child, because I decided that screen
must be always there, once it is created. The only case when it can disappear without
signal from {\logo METAFONT} is that it could be inadvertently closed in Gnome
Activities menu by mouse. But this case is excluded, because it happens that this graphics
window cannot be closed from Activities menu.

@<Create pipe...@>=
if (pipe(pipefd) == -1)
  return false;

@ We automatically get pid of child process in parent from |fork|.
We use it to send signals to child.

@<Global...@>=
pid_t cpid = -1;

@ On update, if window exists, {\logo METAFONT}
sends |SIGUSR1|. On receiving this signal, child
checks if it is in foreground. If no, it writes |'0'| to pipe.
If child is in foreground, it marks for update and on subsequent
callback it updates the screen and writes |'1'| to pipe.
If parent reads |'0'|, it makes graphics window to pop-up by restarting child.

@c
void update_screen(void)
{
  uint8_t byte = '0';
  if (cpid != -1) {
    kill(cpid, SIGUSR1);
    read(pipefd[0], &byte, 1);
  }
  if (byte == '0') {
    @<Stop child program if it is already running@>@;
    @<Start child program@>@;
    @<Wait until child program is initialized@>@;
  }
}

@ @<Stop child...@>=
if (cpid != -1) {
  kill(cpid, SIGTERM);
  waitpid(cpid, NULL, 0);
}

@ File descriptor for in-memory file is tied to child's standard input via |dup2| before |execl|.
So, child process just uses descriptor 0 to attach to the shared memory.

@<Start child program@>=
cpid = fork();
if (cpid == 0) {
  close(pipefd[0]); /* cleanup */
  dup2(fd, STDIN_FILENO);
  close(fd);
  dup2(pipefd[1], STDOUT_FILENO);
  close(pipefd[1]);
  signal(SIGINT, SIG_IGN); /* ignore |SIGINT| in child --- only {\logo METAFONT} must
    act on CTRL+C */
  execl("/home/user/mf/window/wayland", "wayland", (char *) NULL);
  write(STDOUT_FILENO, "x", 1);
  exit(EXIT_FAILURE);
}

@ @<Wait until child program is initialized@>=
if (cpid != -1) {
  uint8_t byte; @+
  read(pipefd[0], &byte, 1); /* blocks until |STDOUT_FILENO| is written to in child */
  if (byte == 'x') {
    waitpid(cpid, NULL, 0);
    cpid = -1;
  }
}

@ These are from \.{mf.w}.

@<Type definitions@>=
typedef uint8_t pixel_color;
typedef uint16_t screen_row;
typedef uint16_t screen_col;

@ @c
void blank_rectangle(screen_col left_col, screen_col right_col,
  screen_row top_row, screen_row bot_row)
{
  pixel_t *pixel;
  for (screen_row r = top_row; r <= bot_row; r++) {
    pixel = shm_data;
    pixel += screen_width*r + left_col;
    for (screen_col c = left_col; c <= right_col; c++)
      *pixel++ = WHITE;
  }
}

@ @c
void paint_row(screen_row r, pixel_color b, screen_col *a, screen_col n)
{
  pixel_t *pixel = shm_data;
  pixel += screen_width*r + a[0];
  int k = 0;
  screen_col c = a[0];
  do {
      k++;
      do {
           if (b == 0)
             *pixel++ = WHITE;
           else
             *pixel++ = BLACK;
           c++;
      } while (c != a[k]);
      b = !b;
  } while (k != n);
}

@ @<Header files@>=
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <unistd.h>
