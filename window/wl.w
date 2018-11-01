\let\lheader\rheader
\datethis
\def\title{MF-WL}

@s EXTERN extern

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.
I wrote this interface because both X11 interfaces have a problem that it is not possible
to switch between terminal and the graphics window using Super+Tab in GNOME 3.

We need to run {\logo METAFONT} and Wayland in parallel, so the method is to use |fork| and |exec|,
because the wayland program cannot terminate---it is a general rule for all Wayland
applications---they work in endless loop. As we are using |fork|, {\logo METAFONT} process
automatically has the pid of Wayland process, which is used to send signals to it.

Color is set in XRGB format (X byte is not used for anything).

@d BLACK 0x000000
@d WHITE 0xffffff

@c
#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

#undef read
#include <sys/wait.h>
#include <sys/syscall.h>
#include <sys/mman.h>

typedef uint32_t pixel_t;

static int fd;
void *shm_data;
static pid_t cpid = -1;

#include <mfdisplay.h>

static int pipefd[2]; /* used to determine if the child has started, to get on-top status
  and for synchronization */

@ |mf_wl_initscreen| returns 1 if display opened successfully, else 0.

@c
int mf_wl_initscreen(void)
{
  @<Create pipe for communication with the child@>@;

  @<Create shared memory@>@;
  @<Get address of shared memory@>@;

  pixel_t *pixel = shm_data;
  for (int n = 0; n < screenwidth * screendepth; n++)
    *pixel++ = WHITE;

  return 1;
}

@ We do not need to close write end of pipe in parent, because child cannot exit by itself
(thus \\{read} in \\{updatescreen} will never block). So, we need to create pipe only once,
even though child may be forked multiple times.

I specifically do not implement exit via keybind in child, because I decided that screen
must be always there, once it is created. The only case when it can disappear without
signal from {\logo METAFONT} is that it could be inadvertently closed in Gnome
Activities menu by mouse. But this case is excluded, because it happens that this graphics
window cannot be closed from Activities menu.

@<Create pipe...@>=
if (pipe(pipefd) == -1)
  return 0;

@ Data is communicated to child wayland process via shared memory.
|memfd_create| creates a memory-only file and returns a descriptor
for it, which is tied to child's standard input via |dup2| before |execl|.
So, child process just uses descriptor 0 to attach to the shared memory.

@<Create shared memory@>=
fd = syscall(SYS_memfd_create, "shm", 0); /* no glibc wrappers exist for |memfd_create| */
if (fd == -1) return 0;
int shm_size = screenwidth * screendepth * sizeof (pixel_t);
if (ftruncate(fd, shm_size) == -1) { /* allocate memory */
  close(fd);
  return 0;
}

@ |mmap| gives a pointer to memory associated with the file.
|mmap| is also called in child process go get pointer to
the same memory. Each call to |mmap|
reserves a new region of virtual memory, but all those regions
access the same portion of physical memory.

@<Get address of shared memory@>=
shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, fd, 0);
if (shm_data == MAP_FAILED) {
  close(fd);
  return 0;
}

@ We automatically get pid of child process in parent from |fork|.
We use it to send signals to child.

Parent sends |SIGUSR1|. On receiving this signal, child
checks if it is in foreground. If no, it writes |'0'| to pipe.
If child is in foreground, it marks for update and on subsequent
callback it updates the screen and writes |'1'| to pipe.
If parent reads |'0'|, it makes graphics window to pop-up by restarting child.

@c
void mf_wl_updatescreen(void)
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

@ Graphics window is left running when {\logo METAFONT} exits.
Create a shell wrapper to kill it before starting {\logo METAFONT}.

@<Start child program@>=
cpid = fork();
if (cpid == 0) {
  char screen_width[5];
  char screen_depth[5];
  snprintf(screen_width, 5, "%d", screenwidth);
  snprintf(screen_depth, 5, "%d", screendepth);
  close(pipefd[0]); /* cleanup */
  dup2(fd, STDIN_FILENO);
  close(fd);
  dup2(pipefd[1], STDOUT_FILENO);
  close(pipefd[1]);
  signal(SIGINT, SIG_IGN); /* ignore |SIGINT| in child --- only {\logo METAFONT} must
    act on CTRL+C */
  execl("/var/local/bin/wayland", "wayland", screen_width, screen_depth, (char *) NULL);
  @<Abort starting child program@>;
}

@ |execl| returns only if there is an error so we do not check return value.
|write| to parent so that it will not block forever.

@<Abort starting child program@>=
write(STDOUT_FILENO, "", 1);
exit(EXIT_FAILURE);

@ @<Wait until child program is initialized@>=
if (cpid != -1) {
  uint8_t byte; @+
  read(pipefd[0], &byte, 1); /* blocks until |STDOUT_FILENO| is written to in child */
}

@ @c
void mf_wl_blankrectangle(screencol left,
                          screencol right,
                          screenrow top,
                          screenrow bottom)
{
  pixel_t *pixel;
  for (screenrow r = top; r <= bottom; r++) {
    pixel = shm_data;
    pixel += screenwidth*r + left;
    for (screencol c = left; c <= right; c++)
      *pixel++ = WHITE;
  }
}

void mf_wl_paintrow(screenrow row,
                    pixelcolor init_color,
                    transspec tvect,
                    screencol vector_size)
{
  pixel_t *pixel = shm_data;
  pixel += screenwidth*row + *tvect;
  screencol k = 0;
  screencol c = *tvect;
  do {
      k++;
      do {
           if (init_color == 0)
             *pixel++ = WHITE;
           else
             *pixel++ = BLACK;
           c++;
      } while (c != *(tvect+k));
      init_color = !init_color;
  } while (k != vector_size);
}
