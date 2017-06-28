\let\lheader\rheader
\datethis

@s uint32_t int
@s template normal
@f EXTERN extern

@ We need to run these two processes in parallel, so the method is to use fork() and exec(),
because the child programm cannot terminate - it is a general rule for all wayland
applications - they work in endless loop. As a side effect, these two processes are automatically
connected with each other.

@c
/* Wayland window interface for Metafont. */

/* TODO: check return value from write() calls */

#define	EXTERN extern /* FIXME: do we need this? */
#include "../mfd.h"

#ifdef X11WIN                  /* almost whole file */

#undef read /* to avoid compilation error */
#include <signal.h>

#define WIDTH 1024
#define HEIGHT 768
  /* must agree with metafont source and child source (FIXME: pass it (and size) as argument to
     child?) */

#define color(R,G,B) R << 16 | G << 8 | B
  /* color is set in XRGB format (X byte is not used for anything) */

static uint32_t pixel;

static int fd;
static pid_t pid = 0;

#include <mfdisplay.h>

static int this_updatescreen_is_tied_to_initscreen = 0; /* workaround metafont's misbehavior */

int /* Return 1 if display opened successfully, else 0.  */
mf_x11_initscreen (void)
{
  const char template[] = "/wayland-shared-XXXXXX";
  const char *path;
  char *name;
  path = getenv("XDG_RUNTIME_DIR");
  if (path == NULL) return 0;
  name = malloc(strlen(path) + sizeof template);
  if (name == NULL) return 0;
  strcat(strcpy(name, path), template);
  fd = mkstemp(name);
  if (fd >=0)
    unlink(name); /* delete automatically when metafont exits */
  free(name);
  if (fd < 0) return 0;

  for (int n = 0; n < WIDTH*HEIGHT; n++) { /* create blank file */
    pixel = color(rand()%255,rand()%255,rand()%255); /* FIXME: check precedence */
    write(fd, &pixel, sizeof pixel);
      /* it is not said anywhere that output device must have a background of a defined color - all
         coloring operations must be done by MF explicitly, so
         we deliberately set the output device background to some random color;
         moreover, theoretically it is possible for some types of output devices to have some
         drawing on it from some other program which might have used it previously - so again,
         no pre-suppositions about background color of the output device must be made */
  }
  this_updatescreen_is_tied_to_initscreen = 1;
  return 1;
}

void
mf_x11_updatescreen (void)
{
  int fdpipe[2];

  if (this_updatescreen_is_tied_to_initscreen) {
    this_updatescreen_is_tied_to_initscreen = 0;
    return;
  }

  if (pid) kill(pid, SIGINT); /* a trick to automatically bring window to front on updatescreen
                (useful for interactive usage via "showit;", but also is triggered by "endchar;" */

  signal(SIGCHLD, SIG_IGN); /* do not block until the child exits; this must be done
                               before |fork| */
  if (pipe(fdpipe) != 0) /* used to determine if the child has started; must be done
                            before |fork| */
    fprintf(stderr, "Failed to create pipe.\x0a");
  else if ((pid = fork()) != -1) {
    @<Start child program@>@;
    @<Wait until child program is started@>@;
  }
  else {
    fprintf(stderr, "Failed to create child process.\x0a");
    close(fdpipe[0]);
    close(fdpipe[1]); /* we cannot create them in initscreen not to close them at all, because
                         |fdpipe[1]| needs to be closed in |@<Wait until child...@>| */
  }
}

@ @<Start child program@>=
if (pid == 0) {
    signal(SIGCHLD, SIG_DFL); /* restore to default */
    char d[10], dpipe[10]; /* FIXME: see git lg radioclk.w how to remove this extra gap */
    snprintf(d, 10, "%d", fd);
    snprintf(dpipe, 10, "%d", fdpipe[1]);
    execl("/usr/local/way/way", "/usr/local/way/way", d, dpipe, NULL);
}

@ We automatically get pid of child process, which is used to
control it.

@<Wait until child program is started@>=
if (pid > 0) {
    close(fdpipe[1]); /* if we do not close it, |read| below will block forever
                         FIXME: why? */
    char dummy; /* FIXME: see git lg radioclk.w how to remove this extra gap */
    read(fdpipe[0], &dummy, 1); /* blocks until |fdpipe[1]| is written to or closed in
                                   child; blocks forever if |fdpipe[1]| is not closed above
                                   FIXME: why? */

/* TODO: get return value from |read| and deliberately call |exit| in child without closing
the file explicitly and check the return value - if it will be zero, it will mean that a file
descriptor is automatically closed on exit;
and so, in general case, return value must be chacked and if it is zero, treat it not
as a ready-signal, but as an
abnormal condition that child died prematurely (in our case zero condition is OK, because
the child is unlikely to die without receiving SIGINT); and then in child use |write|
instead of |close|. And in such case, can we be sure that parent
will receive the data if |write| in client happens earlier than |read| in parent?

And I have a thought about that FIXME: maybe |read| blocks until {\it all\/} descriptors are
closed. And when you do this TODO, check if it will become possible to use |write| instead
of |close| in child and then you may remove all |close| calls from this file and
use |pipe| in initscreen instead of in updatescreen to simplify logic */

    close(fdpipe[0]); /* close it too, because |fdpipe[1]| was closed (i.e., we cannot create them
                         in initscreen not to close them at all) */
}

@ @c
void
mf_x11_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{
  for (screenrow r = top; r < bottom; r++) {
    lseek(fd,WIDTH*r*4,SEEK_SET);
    lseek(fd,(left-1)*4,SEEK_CUR);
    for (screencol c = left; c < right; c++) {
      pixel = color(255,253,113); /* "white" */
      write(fd, &pixel, sizeof pixel);
    }
  }
}

void
mf_x11_paintrow(screenrow row,
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
             pixel = color(255, 253, 113); /* "white" */
           else
             pixel = color(0,0,0); /* black */
           write(fd, &pixel, sizeof pixel);
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
}

#else
int x11_dummy;
#endif /* X11WIN */
