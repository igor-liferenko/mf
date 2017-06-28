\let\lheader\rheader
\datethis

@ We need to run these two processes in parallel, so the method is to use fork() and exec(),
because the child programm cannot terminate - it is a general rule for all wayland
applications - they work in endless loop. As a side effect, these two processes are automatically
connected with each other.

@c
/* Wayland window interface for Metafont. */

/* TODO: check return value from write() calls */

#define	EXTERN extern
#include "../mfd.h"

#ifdef X11WIN                  /* almost whole file */

#undef read /* to avoid compilation error */
#include <signal.h>

#define WIDTH 1024
#define HEIGHT 768
  /* must agree with metafont source and child source (FIXME: pass it (and size) as argument to
     child? */

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
  this_updatescreen_is_tied_to_initscreen = 1;

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
    pixel = color(rand()%255,rand()%255,rand()%255);
    write(fd, &pixel, sizeof pixel);
      /* it is not said anywhere that output device must have a background of a defined color - all
         coloring operations must be done by MF explicitly, so
         we deliberately set the output device background to some random color;
         moreover, theoretically it is possible for some types of output devices to have some
         drawing on it from some other program which might have used it previously - so again,
         no pre-suppositions about background color of the output device must be made */
  }
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
    close(fdpipe[0]);
    close(fdpipe[1]);
    fprintf(stderr, "Failed to create child process.\x0a");
  }
}

@ @<Start child program@>=
if (pid == 0) {
    signal(SIGCHLD, SIG_DFL); /* restore to default */
    char d[10];
    snprintf(d, 10, "%d", fd);
    char dpipe[10];
    snprintf(dpipe, 10, "%d", fdpipe[1]);
    execl("/usr/local/way/way", "/usr/local/way/way", d, dpipe, NULL);
}

@ We automatically get pid of child process, which is used to
control it.

@<Wait until child program is started@>=
if (pid > 0) {
    close(fdpipe[1]); /* if we do not close it, |read| below will block forever
                         FIXME: why? */
    char dummy;
    read(fdpipe[0], &dummy, 1); /* blocks until |fdpipe[1]| is written to or closed in
                                   child; blocks forever if |fdpipe[1]| is not closed above
                                   FIXME: why? */
    close(fdpipe[0]); /* close it too, because |fdpipe[1]| was closed (i.e., we cannot create them
                         in initscreen not to close explicitly) */
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
