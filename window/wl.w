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
because the child programm cannot terminate---it is a general rule for all Wayland
applications---they work in endless loop. As we are using |fork|, {\logo METAFONT} process
automatically has the pid of Wayland process, which is used to send signals to it.

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
  if (pipe(pipefd) == -1)
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
  if (fd != -1)
    unlink(name); /* will be deleted automatically when {\logo METAFONT} exits */
  free(name);
  if (fd == -1) return 0;

  for (int n = 0; n < screenwidth*screendepth; n++) { /* create blank file
                                                         (i.e., blank the screen) */

      /* it is not said anywhere that output device must have a background of a defined color - all
         coloring operations must be done by MF explicitly, so
         we deliberately set the output device background to some random color;
         moreover, theoretically it is possible for some types of output devices to have some
         drawing on it from some other program which might have used it previously - so again,
         no pre-suppositions about background color of the output device must be made */
//    pixel = color(rand()%255,rand()%255,rand()%255);
TODO: this_updatescreen_is_tied_to_initscreen may be connected with this

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
  @<Work around METAFONT's misbehavior@>@;

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
from {\logo METAFONT} right before exiting (it is not evident to me how
to do it). But Wayland itself is Linux-specific
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
      execl("/usr/local/bin/way", "way", (char *) NULL);
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
    lseek(fd,screenwidth*r*4,SEEK_SET);
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
  lseek(fd,screenwidth*row*4,SEEK_SET);
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

@ Using semicolon after "showit" causes an
extra call to |blankrectangle| and |updatescreen| functions from
online display driver.

\smallskip

\.{\$ mf '\\showit'}

\noindent outputs:

\.{initscreen called}\par
\.{blankrectangle called}\par
\.{updatescreen called}

\bigskip

\.{\$ mf '\\showit;'}

\noindent outputs:

\.{initscreen called}\par
\.{blankrectangle called}\par
\.{updatescreen called}\par
\.{blankrectangle called}\par
\.{updatescreen called}

\bigskip

In the second output we see redundant calls to |blankrectangle| and |updatescreen|.

Except these duplicate calls being useless, they also cause undesirable
small initial blinking effect in Wayland online display driver.

These duplicate calls are strange and cause a question for
what they are needed.

This is an overview of the workaround:
\medskip
\begingroup
\obeyspaces
\obeylines
\catcode`_11
\catcode`{11
\catcode`}11
\tt
+int this_updatescreen_is_tied_to_initscreen = 0;
 int
 mf_x11_initscreen (void)
 {
+  this_updatescreen_is_tied_to_initscreen = 1;

 void
 mf_x11_updatescreen (void)
 {
+  if (this_updatescreen_is_tied_to_initscreen) {
+    this_updatescreen_is_tied_to_initscreen = 0;
+    return;
+  }
\endgroup

@<Work around METAFONT's misbehavior@>=
if (this_updatescreen_is_tied_to_initscreen) {
  this_updatescreen_is_tied_to_initscreen = 0;
  return;
}
