/* Wayland window interface for Metafont. */

#define	EXTERN extern
#include "../mfd.h"

#include <mfdisplay.h>

/* Return 1 if display opened successfully, else 0.  */

#define WIDTH 1024
#define HEIGHT 768

int
mf_x11_initscreen (void)
{
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) { /* pid file exists */
    //printf("\nkilling on initscreen");
    system("kill -2 `cat /tmp/mf-wayland.pid`");
    while (access("/tmp/mf-wayland.pid", F_OK) != -1); /* wait until it is fully stopped */
  }
  int n;
  FILE *fp=fopen("/tmp/mf-wayland.bin","w");
  for (n =0; n < WIDTH*HEIGHT; n++) { /* create blank file */
    fprintf(fp,"%c%c%c%c", 113, 253, 255, 0); // white (B,G,R,X)
  }
  fclose(fp);
  return 1;
}

int first = 1; /* whether "showit" is used the first time in this "mf" run */
/* there is a difference between when "showit" is called for the first time and
   when it is called subsequently - because only necessary stuff needs to be drawn
   on the first run, whereas the whole width of the image must be redrawn on changed
   region on subsequent runs, because stuff may already exist there from previous "showit" run */

void
mf_x11_updatescreen (void)
{
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
     influence the resulting image.

Also it is not clear how to give a signal to wayland window from metafont (now pid file is used
to kill the process, but when I will find out how to solve issues 1) and 2) above, some
other mechanism will be needed to control an opened wayland window which is run by a process,
separate from metafont itself - it cannot be part of metafont, because graphics window needs
endless loop).

     Besides, the window is killed in this function in Xt driver also.
     An interesting fact: in Xt driver, window is closed when metafont
     exits on "bye" - through which mechanism this feature is implemented?
     When I will understand this and implement this, then keyboard support may be removed
     from way.w (i.e., revert commit 9784a23f18de802a5923f11fea74a4d8089174c2) and the kill() in
     mf_x11_initscreen() may be removed.
     gives different results depending on whether the first showit is used or not
  */

  if (access("/tmp/mf-wayland.pid", F_OK) != -1) { /* pid file exists */
    //printf("\nkilling on updatescreen, %s",first?"new":"existing");
    system("kill -2 `cat /tmp/mf-wayland.pid`");
    while (access("/tmp/mf-wayland.pid", F_OK) != -1); /* wait until it is fully stopped */
    system("/usr/local/way/way &");
    while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
  }
  if (first) {
    first = 0;
    system("/usr/local/way/way &");
    while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
  }
}

void
mf_x11_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{
  FILE *fp=fopen("/tmp/mf-wayland.bin","rb+");
  for (screenrow r = top; r < bottom; r++) {
    fseek(fp,WIDTH*r*4,SEEK_SET);
    fseek(fp,(left-1)*4,SEEK_CUR);
    for (screencol c = left; c < right; c++)
      fprintf(fp,"%c%c%c%c", 113, 253, 255, 0); // white
  }
  fclose(fp);
}

void
mf_x11_paintrow(screenrow row,
                pixelcolor init_color,
                transspec tvect,
                screencol vector_size)
{
  int col;
  FILE *fp=fopen("/tmp/mf-wayland.bin","rb+");

  fseek(fp,WIDTH*row*4,SEEK_SET);
  fseek(fp,(*tvect-1)*4,SEEK_CUR);
  screencol k = 0;
  screencol c = *tvect;
  do {
      k++;
      do {
           if (init_color==0) fprintf(fp,"%c%c%c%c", 113, 253, 255, 0); // white
           else fprintf(fp,"%c%c%c%c", 0, 0, 0, 0); // black
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
  fclose(fp);
}
