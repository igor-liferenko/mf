\let\lheader\rheader
\datethis

@f EXTERN extern

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.
I wrote this interface because both X11 interfaces have a problem that it is not possible
to switch between terminal and the graphics window using Super+Tab in GNOME 3.

We need to run {\logo METAFONT} and Wayland in parallel, so the method is to use |fork| and |exec|,
because the wayland program cannot terminate---it is a general rule for all Wayland
applications---they work in endless loop. As we are using |fork|, {\logo METAFONT} process
automatically has the pid of Wayland process, which is used to send signals to it.

FIXME: if you do not get answer here: https://stackoverflow.com/questions/49567475/,
do via shmat, passing identifier in argument list
@^FIXME@>

FIXME: R and B in RGB components are swapped for some reason when \\{wl\_surface\_damage} is used,
so on first screen colors are different from subsequent
screens; don't know why it happens, but if black and white colors are used, this change
does not manifest itself; to see this, use |sleep(1);| at the beginning of
|mf_wl_updatescreen| and 0xff0000 and 0x0000ff for BLACK and WHITE here
@^FIXME@>

@d BLACK 0x0
@d WHITE 0xffffff

@c
#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

#ifdef WLWIN                  /* almost whole file */

#undef read
#include <sys/wait.h>
#include <sys/prctl.h>
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
  @<Allocate shared memory@>@;
  @<Get address of allocated memory@>@;

  pixel_t *pixel = shm_data;
  for (int n = 0; n < screenwidth * screendepth; n++)
    *pixel++ = WHITE;

  return 1;
}

@ Data is communicated to wayland process via memory.

@<Allocate shared memory@>=
int shm_size = screenwidth * screendepth * sizeof (pixel_t);
fd = syscall(SYS_memfd_create, "shm", 0); /* no glibc wrappers exist for |memfd_create| */
if (fd == -1) return 0;
if (ftruncate(fd, shm_size) == -1) {
  close(fd);
  return 0;
}

@ @<Get address of allocated memory@>=
shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, fd, 0);
if (shm_data == MAP_FAILED) {
  close(fd);
  return 0;
}

@ We automatically get pid of child process in parent from |fork|.
We use it to send signals to child.

Parent sends |SIGUSR1|. On receiving this signal, child
checks if it is in foreground. If no, it writes 0 to pipe.
If child is in foreground, it marks for update and on subsequent
callback it updates the screen and writes 1 to pipe.
If parent reads 0, it makes graphics window to pop-up by restarting child.

Using \.{strace} I found out that child sits on \\{poll} syscall,
which is restartable by using \.{SA\_RESTART} in |SIGUSR1| signal handler.

@c
void mf_wl_updatescreen(void)
{
  char dummy = 0;
  if (cpid != -1) {
    kill(cpid, SIGUSR1);
    read(pipefd[0], &dummy, 1);
  }
  if (dummy == 0) {
    @<Stop child program if it is already running@>@;
    @<Start child program@>@;
    @<Wait until child program is initialized@>@;
  }
}

@ @<Stop child...@>=
if (cpid != -1) {
  close(pipefd[0]);
  kill(cpid, SIGINT);
  waitpid(cpid, NULL, 0);
}

@ |prctl| is used to automatically close window when {\logo METAFONT} exits.
|getppid| is used to make sure that {\logo METAFONT} did not exit just before |prctl| call.

@<Start child program@>=
if (pipe(pipefd) == -1) return;
cpid = fork();
if (cpid == 0) {
    char screen_width[5];
    char screen_depth[5];
    snprintf(screen_width, 5, "%d", screenwidth);
    snprintf(screen_depth, 5, "%d", screendepth);
    close(pipefd[0]);
    dup2(fd, STDIN_FILENO);
    close(fd);
    dup2(pipefd[1], STDOUT_FILENO);
    close(pipefd[1]);
    if (prctl(PR_SET_PDEATHSIG, SIGINT) != -1 && getppid() != 1)
      execl("/usr/local/bin/wayland", "wayland", screen_width, screen_depth, (char *) NULL);
    @<Abort starting child program@>;
}
close(pipefd[1]); /* EOF */

@ |execl| returns only if there is an error so we do not check return value.
|write| to parent so that it will not block forever.

@<Abort starting child program@>=
char dummy; @+
write(STDOUT_FILENO, &dummy, 1);
exit(EXIT_FAILURE);

@ @<Wait until child program is initialized@>=
if (cpid != -1) {
  char dummy; @+
  read(pipefd[0], &dummy, 1); /* blocks until |STDOUT_FILENO| is written to in child */
}
else
  close(pipefd[0]);

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

#else
int wl_dummy;
#endif /* WLWIN */
