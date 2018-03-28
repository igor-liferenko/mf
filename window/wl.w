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
@d BLACK color(0,0,0)       /* 0x0 */         /* use black and white */
@d WHITE color(255,253,113) /* 0xffffffff */  /* and make it independent of byte order */

@c
#define	EXTERN extern /* needed for \.{mfd.h} */
#include "../mfd.h"

#ifdef WLWIN                  /* almost whole file */

#undef read
#include <sys/wait.h>
#include <sys/prctl.h>

#include <time.h>
#define mytime(x)   struct timespec tms; \
  if (timespec_get(&tms, TIME_UTC)) { \
    int64_t micros = tms.tv_sec * 1000000; \
    micros += tms.tv_nsec/1000; \
    if (tms.tv_nsec % 1000 >= 500) ++micros; \
    fprintf(stderr, "\n==" #x ":\t%"PRId64"\n", micros); \
  }


static uint32_t pixel;

static int fd;
static FILE *fp;
static pid_t cpid = 0;

#include <mfdisplay.h>

static int pipefd[2]; /* used to determine if the child has started and get on-top status */

int /* Return 1 if display opened successfully, else 0.  */
mf_wl_initscreen (void)
{
  /* mytime(initscreen); */ /* FIXME */
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
  fp = fdopen(fd, "w");
  for (int n = 0; n < screenwidth*screendepth; n++) { /* create blank file
                                                         (i.e., blank the screen) */
    pixel = WHITE;
    fwrite(&pixel, sizeof pixel, 1, fp);
  }
  fflush(fp); /* FIXME */

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
  fflush(fp);
  /* mytime(fflush); */ /* FIXME */
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
    fclose(fp);
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
  /* mytime(blankrect); */ /* FIXME */
  for (screenrow r = top; r < bottom; r++) {
    lseek(fd,screenwidth*r*4,SEEK_SET);
    lseek(fd,(left-1)*4,SEEK_CUR);
    for (screencol c = left; c < right; c++) {
      pixel = WHITE;
      fwrite(&pixel, sizeof pixel, 1, fp);
    }
    fflush(fp); /* FIXME (and why if we put it after outermost "for" instead, screen
      becomes broken when we run "mf cmr10"?) */
  }
}

void
mf_wl_paintrow(screenrow row,
                pixelcolor init_color,
                transspec tvect,
                screencol vector_size)
{
  /* mytime(paintrow); */ /* FIXME */
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
           fwrite(&pixel, sizeof pixel, 1, fp);
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
  fflush(fp); /* FIXME */
}

#else
int wl_dummy;
#endif /* WLWIN */
