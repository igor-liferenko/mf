\noinx

\font\logo=manfnt
@s pid_t int
@* Online graphics display for {\logo METAFONT}.

We need to run metafont and wayland processes in parallel,
because a Wayland application runs in an endless loop.

Screen data is stored in memory, which is shared among
the processes.

@c
@<Header files@>@;

int screen_fd;
void *screen_data;

bool init_screen(void)
{
  if (getenv("NOWIN")) return false;

  @#@t\8@> /* allocate memory and associate file descriptor with it */
  screen_fd = syscall(SYS_memfd_create, "metafont", 0);
  if (screen_fd == -1) return false;
  int screen_size = screen_width * screen_depth * 4;
  if (ftruncate(screen_fd, screen_size) == -1) {
    close(screen_fd);
    return false;
  }

  @#@t\8@> /* get address of memory, referred to by the file descriptor */
  screen_data = mmap(NULL, screen_size, PROT_WRITE, MAP_SHARED, screen_fd, 0);
  if (screen_data == MAP_FAILED) {
    close(screen_fd);
    return false;
  }

  @#@t\8@> /* initialize the memory */
  int *pixel = screen_data;
  for (int n = 0; n < screen_width * screen_depth; n++)
    *pixel++ = 0xffffff;

  return true;
}

@ @s screen_col int
@s screen_row int

@c
void blank_rectangle(screen_col left_col, screen_col right_col,
  screen_row top_row, screen_row bot_row)
{
  int *pixel;
  for (screen_row r = top_row; r < bot_row; r++) {
    pixel = screen_data;
    pixel += screen_width*r + left_col;
    for (screen_col c = left_col; c < right_col; c++)
      *pixel++ = 0xffffff;
  }
}

@ @s pixel_color int

@c
void paint_row(screen_row r, pixel_color b, screen_col *a, screen_col n)
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

@ On update, if window exists, metafont process
sends |SIGUSR1|. On receiving this signal, wayland process
checks if it is in foreground. If no, it writes |'0'| to pipe.
If wayland process is in foreground, it updates the screen and writes |'1'| to pipe.

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
    @<Stop wayland process if it is already running@>@;
    @<Start wayland process@>@;
    @<Wait until wayland process is initialized@>@;
  }
}

@ @<Stop ...@>=
if (pid != -1) {
  kill(pid, SIGTERM);
  waitpid(pid, NULL, 0);
  close(in);
}

@ @<Start ...@>=
if (pipe(fd) == -1) return;
pid = fork();
if (pid == 0) {
  dup2(screen_fd, STDIN_FILENO);
  dup2(out, STDOUT_FILENO);
  signal(SIGINT, SIG_IGN);
  prctl(PR_SET_PDEATHSIG, SIGTERM);
  execl("/home/user/mf-wayland/hello-wayland", "hello-wayland", (char *) NULL);
  _exit(0);
}
close(out);

@ @<Wait ...@>=
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
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <unistd.h>
