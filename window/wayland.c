/* Wayland window interface for Metafont. */

#define	EXTERN extern
#include "../mfd.h"

#include <mfdisplay.h>
#include <signal.h>
/* Return 1 if display opened successfully, else 0.  */

#define WIDTH 1024
#define HEIGHT 768

/* Color is set in XRGB format (X byte is not used for anything), but the real order of bytes in the file is BGRX.

   TODO: use ntohl() and union to set bytes individually:
union pixel_t {
        unsigned char byte[4];
        uint32_t pixel;
};
union pixel_t pixel;
pixel.byte[0];
and use fprintf(fp,"%lu",pixel);
*/

int this_updatescreen_is_tied_to_initscreen = 0;

int
mf_x11_initscreen (void)
{
  this_updatescreen_is_tied_to_initscreen = 1;
  //printf("\ninitscreen called\n");
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) { /* pid file exists */
    printf("\nyou cannot have more than one online graphics display windows simultaneously until you find a way to do without .pid file\n");
    exit(0);
  }
  FILE *fp=fopen("/tmp/mf-wayland.bin","w");
  for (int n=0; n < WIDTH*HEIGHT; n++) /* create blank file */
    fprintf(fp,"%c%c%c%c", 0, 0, 0, 0);
      /* it is not said anywhere that output device must have a background of a defined color - all
         coloring operations must be done by MF explicitly, so
         we deliberately set the output device background to some non-"white" color;
         moreover, theoretically it is possible for some types of output devices to have some
         drawing on it from some other program which might have used it previously - so again,
         no pre-suppositions about background color of the output device must be made */
  fclose(fp);
  return 1;
}

void
mf_x11_updatescreen (void)
{
  if (this_updatescreen_is_tied_to_initscreen) {
    this_updatescreen_is_tied_to_initscreen = 0;
    return;
  }
  //printf("updatescreen called\n");

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

Also it is not clear how to give a signal to wayland window from metafont (now pid file is used
to kill the process, but when I will find out how to solve issues 1) and 2) above, some
other mechanism will be needed to control an opened wayland window which is run by a process,
separate from metafont itself - it cannot be part of metafont, because graphics window needs
endless loop).
This may be the solution:
https://stackoverflow.com/questions/36234703/
https://stackoverflow.com/questions/31097058/
And if it will work, remove code which concerns mf-wayland.pid from this file.

     Besides, the window is killed in this function in Xt driver also.
  */

  if (access("/tmp/mf-wayland.pid", F_OK) != -1) { /* pid file exists */
    //printf("\nkilling on updatescreen\n");
    system("kill -2 `cat /tmp/mf-wayland.pid`");
    while (access("/tmp/mf-wayland.pid", F_OK) != -1); /* wait until it is fully stopped */
  }
pid_t pid;
signal(SIGCHLD, SIG_IGN); /* https://stackoverflow.com/questions/9164316/ */
if((pid = fork()) < 0)
  fprintf(stderr,"Error with Fork()\n");
else if(pid > 0)
  while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
else
  execv("/usr/local/way/way",NULL);
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
      fprintf(fp,"%c%c%c%c", 113, 253, 255, 0); // "white"
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
           if (init_color==0) fprintf(fp,"%c%c%c%c", 113, 253, 255, 0); // "white"
           else fprintf(fp,"%c%c%c%c", 0, 0, 0, 0); // black
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
  fclose(fp);
}
