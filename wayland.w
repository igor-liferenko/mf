\let\lheader\rheader
\noinx

\font\logo=manfnt

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
  if (getenv("SCREEN_SIZE") == NULL) return false;

  @#@t\8@> /* allocate memory and associate file descriptor with it */
  screen_fd = syscall(SYS_memfd_create, "metafont", 0);
  if (screen_fd == -1) return false;
  int screen_size = @!screen_width * @!screen_depth * 4;
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

@ @s uint16_t int

@c
typedef uint16_t screen_row; /* a row number on the screen */
typedef uint16_t screen_col; /* a column number on the screen */
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

@ @s uint8_t int

@c
typedef uint8_t pixel_color; /* specifies one of the two pixel values */
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
checks if it is in foreground.
If yes, it updates the screen and writes |'1'| to pipe.
If no or it is dead or it was not started yet, |byte| will be |'0'|.

@d read_end fd[0]
@d write_end fd[1]
@s pid_t int

@c
void update_screen(void)
{
  static pid_t pid = -1;
  static int fd[2];

  char byte = '0';
  if (pid != -1) {
    kill(pid, SIGUSR1);
    read(read_end, &byte, 1);
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
  close(read_end);
}

@ @<Start ...@>=
if (pipe(fd) == -1) kill(getpid(), SIGABRT), pause();
if ((pid = fork()) == -1) kill(getpid(), SIGABRT), pause();
if (pid == 0) {
  dup2(screen_fd, STDIN_FILENO);
  dup2(write_end, STDOUT_FILENO);
  signal(SIGINT, SIG_IGN);
  prctl(PR_SET_PDEATHSIG, SIGTERM);
  execl("/home/user/mf-wayland/hello-wayland", "hello-wayland", (char *) NULL);
  exit(0);
}
close(write_end);

@ @<Wait ...@>=
if (!read(read_end, &byte, 1)) kill(getpid(), SIGABRT), pause();

@ @<Header files@>=
#include <signal.h> /* |@!SIGABRT|, |@!SIGINT|, |@!SIGTERM|, |@!SIGUSR1|, |@!SIG_IGN|, |@!kill|,
  |@!signal| */
#include <stdbool.h> /* |@!false|, |@!true| */
#include <stdint.h> /* |@!uint8_t|, |@!uint16_t| */
#include <stdlib.h> /* |@!exit|, |@!getenv| */
#include <sys/mman.h> /* |@!MAP_FAILED|, |@!MAP_SHARED|, |@!PROT_WRITE|, |@!mmap| */
#include <sys/prctl.h> /* |@!PR_SET_PDEATHSIG|, |@!prctl| */
#include <sys/syscall.h> /* |@!SYS_memfd_create|, |@!syscall| */
#include <sys/wait.h> /* |@!waitpid| */
#include <unistd.h> /* |@!STDIN_FILENO|, |@!STDOUT_FILENO|, |@!close|,
  |@!dup2|, |@!execl|, |@!fork|, |@!ftruncate|, |@!getpid|, |@!pause|, |@!pipe|, |@!read| */
