\let\lheader\rheader
\datethis

@s uint32_t int
@f EXTERN extern

@* Wayland window interface for MetaFont.
We need to run these two processes in parallel, so the method is to use fork() and exec(),
because the child programm cannot terminate - it is a general rule for all wayland
applications - they work in endless loop. As a side effect, these two processes are automatically
connected with each other.

@c
/* TODO: check return value from write() calls */
/* TODO: merge way/way.w here via \.{@@(mf-win@@>=} */

#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

#ifdef WLWIN                  /* almost whole file */

#undef read /* to avoid compilation error */
#include <sys/wait.h>
#include <sys/prctl.h>

#define WIDTH 1024
#define HEIGHT 768
  /* must agree with metafont source and child source (FIXME: pass it (and size) as argument to
     child?) */
  /* TODO: see in x11-Xlib.c and/or x11-Xt.c how width and height are read/set from/to .Xresources
     and find out how to use metafont's settings of width and height here */
#define COLOR(R,G,B) R << 16 | G << 8 | B
  /* color is set in XRGB format (X byte is not used for anything) */
#define BLACK COLOR(0,0,0)
#define WHITE COLOR(255,253,113)

static uint32_t pixel;

static int fd;
static char fdstr[10]; /* to pass |fd| to child via argument list */
static pid_t cpid = 0;

#include <mfdisplay.h>

static int this_updatescreen_is_tied_to_initscreen = 0; /* workaround metafont's misbehavior */
static int pipefd[2];
static char pipefdstr[10]; /* to pass |pipefd[1]| to child via argument list */

int /* Return 1 if display opened successfully, else 0.  */
mf_wl_initscreen (void)
{
  if (pipe(pipefd) != 0) /* used to determine if the child has started */
    return 0;
  snprintf(pipefdstr, 10, "%d", pipefd[1]);

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
    unlink(name); /* delete automatically when metafont exits */
  free(name);
  if (fd < 0) return 0;
  snprintf(fdstr, 10, "%d", fd);

  for (int n = 0; n < WIDTH*HEIGHT; n++) { /* create blank file */
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

@ @<Start child program@>=
cpid = fork();
if (cpid == 0) {
    prctl(PR_SET_PDEATHSIG, SIGINT); /* automatically close window when metafont exits */
    execl("/usr/local/way/way", "way", pipefdstr, fdstr, (char *) NULL);
    @<Check for errors...@>;
}

@ |execl| returns only if there is an error so we do not check return value.
|write| to parent so that it will not block forever and terminate child.

@<Check for errors in |execl|@>=
char dummy;
write(pipefd[1], &dummy, 1);
exit(EXIT_FAILURE);

@ @<Wait until child program is initialized@>=
if (cpid != -1) {
  char dummy; /* FIXME: see git lg radioclk.w how to remove this extra gap */
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
  int col;

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
