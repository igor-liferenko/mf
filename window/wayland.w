\let\lheader\rheader
\datethis

@s uint32_t int
@s pid_t int
@f EXTERN extern

\font\logo=manfnt

@* Wayland window interface for {\logo METAFONT}.
I wrote this interface because both X11 interfaces have a problem that it is not possible
to switch between terminal and the graphics window using Super+Tab in GNOME 3.

We need to run {\logo METAFONT} and Wayland in parallel, so the method is to use |fork| and |exec|,
because the child programm cannot terminate - it is a general rule for all Wayland
applications---they work in endless loop. As a side effect, these two processes are automatically
connected with each other, so we can send signals from {\logo METAFONT} to Wayland process.

@d color(R,G,B) (R << 16 | G << 8 | B)
  /* color is set in XRGB format (X byte is not used for anything) */
@d BLACK color(0,0,0)
@d WHITE color(255,253,113)

@c
#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

#ifdef WLWIN                  /* almost whole file */

#undef read /* to avoid compilation error */
#include <sys/wait.h>
#include <sys/prctl.h>

#define WIDTH 1024
#define HEIGHT 768
  /* must agree with {\logo METAFONT} source and child source (FIXME: pass it (and size) as
     argument to child?) */
  /* TODO: see in x11-Xlib.c and/or x11-Xt.c how width and height are read/set from/to .Xresources
     and find out how to use {\logo METAFONT}'s settings of width and height here */

static uint32_t pixel;

static int fd;
static pid_t cpid = 0;

#include <mfdisplay.h>

static int this_updatescreen_is_tied_to_initscreen = 0; /* workaround {\logo METAFONT}'s
                                                           misbehavior */
static int pipefd[2]; /* used to determine if the child has started */

int /* Return 1 if display opened successfully, else 0.  */
mf_wl_initscreen (void)
{
  if (pipe(pipefd) != 0)
    return 0;

  const char tmpl[] = "/wayland-shared-XXXXXX";
  const char *path;
  char *name;
  path = getenv("XDG_RUNTIME_DIR"); /* stored in volatile memory instead of a persistent storage
                                       device */
  if (path == NULL) return 0;
  name = malloc(strlen(path) + sizeof tmpl);
  if (name == NULL) return 0;
  strcat(strcpy(name, path), tmpl);
  fd = mkstemp(name);
  if (fd >=0)
    unlink(name); /* delete automatically when {\logo METAFONT} exits */
  free(name);
  if (fd < 0) return 0;

  for (int n = 0; n < WIDTH*HEIGHT; n++) { /* create blank file (i.e., blank the screen) */
    pixel = WHITE;
    write(fd, &pixel, sizeof pixel);
  }

  this_updatescreen_is_tied_to_initscreen = 1;
  return 1;
}

@ We automatically get pid of child process in parent from |fork|.
We use it to send signals to child.

@c
void
mf_wl_updatescreen (void)
{
  if (this_updatescreen_is_tied_to_initscreen) {
    this_updatescreen_is_tied_to_initscreen = 0;
    return;
  }

  @<Stop child program if it is already running@>@;
  @<Start child program@>@;
  @<Wait until child program is initialized@>@;
}

@ @<Stop child...@>=
if (cpid) {
  kill(cpid, SIGINT);
  wait(NULL);
}

@ |prctl| is Linux-specific. The proper way would be to send |SIGINT| to child
from {\logo METAFONT} right before exiting. But Wayland itself is Linux-specific
anyway, so it's OK.

@<Start child program@>=
cpid = fork();
if (cpid == 0) {
    dup2(fd, STDIN_FILENO);
    close(fd);
    dup2(pipefd[1], STDOUT_FILENO);
    close(pipefd[1]);
    if (prctl(PR_SET_PDEATHSIG, SIGINT) != -1 && /* automatically close window when
                                                    {\logo METAFONT} exits */
      getppid() != 1) /* make sure that {\logo METAFONT} did not exit just before |prctl| call */
      execl("/home/user/way/way", "way", (char *) NULL);
    @<Abort starting child program@>;
}

@ |execl| returns only if there is an error so we do not check return value.
|write| to parent so that it will not block forever.

@<Abort starting child program@>=
char dummy; @+
write(pipefd[1], &dummy, 1);
exit(EXIT_FAILURE);

@ @<Wait until child program is initialized@>=
if (cpid != -1) {
  char dummy; @+
  read(pipefd[0], &dummy, 1); /* blocks until |pipefd[1]| is written to in child */
}

@ @c
void
mf_wl_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{
  for (screenrow r = top; r < bottom; r++) {
    lseek(fd,WIDTH*r*4,SEEK_SET);
    lseek(fd,(left-1)*4,SEEK_CUR);
    for (screencol c = left; c < right; c++) {
      pixel = WHITE;
      write(fd, &pixel, sizeof pixel);
    }
  }
}

void
mf_wl_paintrow(screenrow row,
                pixelcolor init_color,
                transspec tvect,
                screencol vector_size)
{
  lseek(fd,WIDTH*row*4,SEEK_SET);
  lseek(fd,(*tvect-1)*4,SEEK_CUR);
  screencol k = 0;
  screencol c = *tvect;
  do {
      k++;
      do {
           if (init_color==0)
             pixel = WHITE;
           else
             pixel = BLACK;
           write(fd, &pixel, sizeof pixel);
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
}

#else
int wl_dummy;
#endif /* WLWIN */
