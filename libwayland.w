\noinx

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.

We need to run \.{mf} and wayland process in parallel,
because the wayland process must run in an endless loop --- it is a general rule for all Wayland
applications.

Data is communicated to child wayland process via memory.

@c
@<Header files@>@;

static int shm_fd;
static void *shm_data;

bool init_screen(void)
{
  @/@t\4@> /* allocate memory and associate file descriptor with it */
  shm_fd = syscall(SYS_memfd_create, "shm", 0);
  if (shm_fd == -1) return false;
  int shm_size = screen_width * screen_depth * 4;
  if (ftruncate(shm_fd, shm_size) == -1) {
    close(shm_fd);
    return false;
  }

  @/@t\4@> /* get address of memory, referred to by the file descriptor */
  shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, shm_fd, 0);
  if (shm_data == MAP_FAILED) {
    close(shm_fd);
    return false;
  }

  @/@t\4@> /* initialize the memory */
  int *pixel = shm_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = 0xffffff;

  return true;
}

@ @c
void blank_rectangle(screen_col left_col, screen_col right_col,
  screen_row top_row, screen_row bot_row)
{
  int *pixel;
  for (screen_row r = top_row; r <= bot_row; r++) {
    pixel = shm_data;
    pixel += screen_width*r + left_col;
    for (screen_col c = left_col; c <= right_col; c++)
      *pixel++ = 0xffffff;
  }
}

@ @c
void paint_row(screen_row r, pixel_color b, screen_col *a, screen_col n)
{
  int *pixel = shm_data;
  pixel += screen_width*r + a[0];
  int k = 0;
  screen_col c = a[0];
  do {
      k++;
      do {
           if (b == 0)
             *pixel++ = 0xffffff;
           else
             *pixel++ = 0x000000;
           c++;
      } while (c != a[k]);
      b = !b;
  } while (k != n);
}

@ On update, if window exists, {\logo METAFONT}
sends |SIGUSR1|. On receiving this signal, child
checks if it is in foreground. If no, it writes |'0'| to pipe.
If child is in foreground, it marks for update and on subsequent
callback it updates the screen and writes |'1'| to pipe.
If parent reads |'0'|, it makes graphics window to pop-up by restarting child.

@d in fd[0]
@d out fd[1]

@c
void update_screen(void)
{
  static pid_t pid = -1;
  static int fd[2];

  char byte = '0';
  if (pid != -1) {
    kill(pid, SIGUSR1);
    read(in, &byte, 1);
  }
  if (byte == '0') {
    @<Stop child program if it is already running@>@;
    @<Start child program@>@;
    @<Wait until child program is initialized@>@;
  }
}

@ @<Stop child...@>=
if (pid != -1) {
  kill(pid, SIGTERM);
  waitpid(pid, NULL, 0);
  close(in);
}

@ @<Start child program@>=
if (pipe(fd) == -1) return;
pid = fork();
if (pid == 0) {
  dup2(shm_fd, STDIN_FILENO);
  dup2(out, STDOUT_FILENO);
  signal(SIGINT, SIG_IGN);
  prctl(PR_SET_PDEATHSIG, SIGTERM);
  execl("/home/user/mf/wayland", "wayland", (char *) NULL);
  _exit(0);
}
close(out);

@ @<Wait until child program is initialized@>=
if (pid != -1) {
  char byte = 'x';
  read(in, &byte, 1);
  if (byte == 'x') {
    waitpid(pid, NULL, 0);
    pid = -1;
    close(in);
  }
}
else close(in);

@ @<Header files@>=
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <unistd.h>
#include "screen.h"
