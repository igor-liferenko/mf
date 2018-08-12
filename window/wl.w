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

FIXME: R and B in RGB components are swapped for some reason when \\{wl\_surface\_damage} is used,
so on first screen colors are different from subsequent
screens; don't know why it happens, but if black and white colors are used, this change
does not manifest itself; to see this, use |sleep(1);| at the beginning of
|mf_wl_updatescreen| and 0xff0000 and 0x0000ff for BLACK and WHITE here

@d BLACK 0x0
@d WHITE 0xffffff

@c
#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

@=#define WLWIN /* for mcpp */@>
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
  @<Create pipe for communication with the child@>@;

  @<Allocate shared memory@>@;
  @<Get address of allocated memory@>@;

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

@ Data is communicated to wayland process via memory.

@<Allocate shared memory@>=
int shm_size = screenwidth * screendepth * sizeof (pixel_t);
fd = syscall(SYS_memfd_create, "shm", 0); /* no glibc wrappers exist for |memfd_create| */
if (fd == -1) return 0;
if (ftruncate(fd, shm_size) == -1) {
  close(fd);
  return 0;
}

@ |mmap| maps buffers in physical memory into the application's (aka logical, virtual)
address space.

Since the days of the 80386, the Intel world has supported a technique called virtual
addressing. Coming from the Z80 and 68000 world, my first thought about this was: ``You
can allocate more memory than you have as physical RAM, as some addresses will be
associated with portions of your hard disk''.

To be more academic: Every address used by the program to access memory (no matter
whether data or program code) will be translated--either into a physical address in the
physical RAM or an exception, which is dealt with by the OS in order to give you the
memory you required. Sometimes, however, the access to that location in virtual memory
reveals that the program is out of order --- in this case, the OS should cause a ``real''
exception (usually \.{SIGSEGV}, signal 11).

The smallest unit of address translation is the page, which is 4 kB on Intel architectures.

The basic unit for virtual memory management is a page, which size is usually 4K, but it can be
up to 64K on same platforms. Whenever we work with virtual memory we work with two types
addresses: virtual address and physical address. All CPU access (including from kernel space)
uses virtual addresses that are translated by the MMU into physical address with the help of
page tables.

@<Get address of allocated memory@>=
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

@ |prctl| is used to automatically close window when {\logo METAFONT} exits.
|getppid| is used to make sure that {\logo METAFONT} did not exit just before |prctl| call.

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
  if (prctl(PR_SET_PDEATHSIG, SIGTERM) != -1 && getppid() != 1)
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

#else
int wl_dummy;
#endif /* WLWIN */
