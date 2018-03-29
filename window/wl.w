\let\lheader\rheader
\datethis

@f EXTERN extern

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.
I wrote this interface because both X11 interfaces have a problem that it is not possible
to switch between terminal and the graphics window using Super+Tab in GNOME 3.

We need to run {\logo METAFONT} and Wayland in parallel, so the method is to use |fork| and |exec|,
because the child programm cannot terminate---it is a general rule for all Wayland
applications---they work in endless loop. As we are using |fork|, {\logo METAFONT} process
automatically has the pid of Wayland process, which is used to send signals to it.

FIXME: order of colors is changed for some reason when \\{wl\_surface\_damage} is used,
so on first screen initial background and figure colors are different from subsequent
screens; don't know why it happens, but if black and white colors are used, this change
does not manifest itself
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
#include <linux/memfd.h>
#include <sys/mman.h>

static inline int memfd_create(const char *name, unsigned int flags) {
    return syscall(__NR_memfd_create, name, flags);
} /* no glibc wrappers exist for memfd_create(2), so provide our own */

typedef uint32_t pixel_t;

static int fd;
void *shm_data;
static pid_t cpid = 0;

#include <mfdisplay.h>

static int pipefd[2]; /* used to determine if the child has started and get on-top status */

int /* Return 1 if display opened successfully, else 0.  */
mf_wl_initscreen (void)
{
  if (pipe(pipefd) == -1)
    return 0;

  int shm_size = screenwidth * screendepth * sizeof (pixel_t);
  fd = memfd_create("shm", 0);
  if (ftruncate(fd, shm_size) == -1) {
    close(fd);
    return 0;
  }
  shm_data = mmap(NULL, shm_size, PROT_WRITE, MAP_SHARED, fd, 0);
  if (shm_data == MAP_FAILED) {
    close(fd);
    return 0;
  }

  pixel_t *pixel = shm_data;
  for (int n = 0; n < screenwidth*screendepth; n++)
    *pixel++ = WHITE;

  return 1;
}

@ We automatically get pid of child process in parent from |fork|.
We use it to send signals to child.

Parent sends |SIGUSR1|. On receiving this signal, child
checks if it is in foreground. If yes, it writes 1 to pipe,
and if it is in background, it writes 0.
If parent reads 0, it makes graphics window to pop-up by restarting child
(we can do this, because the data is not stored in
the window --- it is stored in a separate file buffer).

The same pipe is used which is used to determine if child has started.

Using \.{strace} I found out that child sits on \\{poll} syscall, 
which is restartable by using \.{SA_RESTART} in |SIGUSR1| signal handler.

@c
void
mf_wl_updatescreen (void)
{
  msync(shm_data, (size_t)(screenwidth*screendepth)*sizeof(pixel_t), MS_SYNC);
  char dummy = 0;
  if (cpid) {
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
if (cpid) {
  kill(cpid, SIGINT);
  wait(NULL);
}

@ |prctl| is Linux-specific. The proper way would be to send |SIGINT| to child
from {\logo METAFONT} right before exiting (it is not evident to me how
to do it). But Wayland itself is Linux-specific
anyway, so it's OK.

@<Start child program@>=
cpid = fork();
if (cpid == 0) {
    char arg1[5];
    char arg2[5];
    snprintf(arg1, 5, "%d", screenwidth);
    snprintf(arg2, 5, "%d", screendepth);
    dup2(fd, STDIN_FILENO);
    close(fd);
    dup2(pipefd[1], STDOUT_FILENO);
    close(pipefd[1]);
    if (prctl(PR_SET_PDEATHSIG, SIGINT) != -1 && /* automatically close window when
                                                    {\logo METAFONT} exits */
      getppid() != 1) /* make sure that {\logo METAFONT} did not exit just before |prctl| call */
      execl("/usr/local/bin/wayland", "wayland", arg1, arg2, (char *) NULL);
    @<Abort starting child program@>;
}

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

@ @c
void
mf_wl_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{
  pixel_t *pixel;
  for (screenrow r = top; r <= bottom; r++) {
    pixel = shm_data;
    pixel += screenwidth*r;
    pixel += left;
    for (screencol c = left; c <= right; c++) {
      *pixel++ = WHITE;
    }
  }
}

void
mf_wl_paintrow(screenrow row,
                pixelcolor init_color,
                transspec tvect,
                screencol vector_size)
{
  pixel_t *pixel = shm_data;
  pixel += screenwidth*row;
  pixel += *tvect-1;
  screencol k = 0;
  screencol c = *tvect;
  do {
      k++;
      do {
           if (init_color==0)
             *pixel++ = WHITE;
           else
             *pixel++ = BLACK;
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
}

#else
int wl_dummy;
#endif /* WLWIN */
