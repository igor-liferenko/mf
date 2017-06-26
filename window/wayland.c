/* Wayland window interface for Metafont. */

#define	EXTERN extern
#include "../mfd.h"

#include <mfdisplay.h>
#include <signal.h>
/* Return 1 if display opened successfully, else 0.  */

#define WIDTH 1024
#define HEIGHT 768

#define color(R,G,B) R << 16 | G << 8 | B
  /* color is set in XRGB format (X byte is not used for anything) */

uint32_t pixel;

int fd;
pid_t pid = 0;

int this_updatescreen_is_tied_to_initscreen = 0;

int
mf_x11_initscreen (void)
{
  this_updatescreen_is_tied_to_initscreen = 1;
  //printf("\ninitscreen called\n");

  /*
   Create a new, unique file of the given size. The file is mmap()'ed
   the given size at offset zero in child.
   The file does not have a permanent backing store.
  */
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
    unlink(name); /* delete automatically */
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
  if (this_updatescreen_is_tied_to_initscreen) {
    this_updatescreen_is_tied_to_initscreen = 0;
    return;
  }
  //printf("\nupdatescreen descriptor = %d\n",fd);

  /*
     In this function must be done two things:

     1) update an opened window with new data from file ("damage" functions seem to
        be appropriate for this in wayland) - I do not know how to do this yet
     2) bring the graphics window to the top - I do not know how to do this yet

     So, I use a dirty hack to kill the window and open it again.
     This does 1) and 2) at once. Here it is used the fact that a wayland window is automatically
     brought to top when it is opened anew (we can do this, because the data is not stored in
     the window - it is stored in a separate file buffer, which is not touched by killing the
     graphics window). And here it is not used the facility to redraw
     only the necessary
     parts of the window - instead the whole window is redrawed each time, but this does not
     influence the end result.

     Besides, the window is killed in this function in Xt driver also.
  */

  if (pid) kill(pid, SIGINT);

  signal(SIGCHLD, SIG_IGN); /* do not wait child */
  if ((pid = fork()) < 0)
    fprintf(stderr,"Error with Fork()\n");
  else if (pid == 0) {
    char d[10];
    snprintf(d,10,"%d",fd);
    //printf("parent descriptor = %s\x0a",d);
    execl("/usr/local/way/way", "/usr/local/way/way", d, NULL);
  }
}

void
mf_x11_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{
  //printf("\nblank descriptor = %d\n",fd);
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
  //printf("\npaintrow descriptor = %d\n", fd);
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
