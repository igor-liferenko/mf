/* Wayland window interface for Metafont. */

#define	EXTERN extern
#include "../mfd.h"

#include <mfdisplay.h>

/* Return 1 if display opened successfully, else 0.  */

#define WIDTH 1280
#define HEIGHT 1024

int
mf_x11_initscreen (void)
{
  printf("\ninitscreen called\n");
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) {
    printf("initscreen - pid exists\n");
    system("kill `cat /tmp/mf-wayland.pid`");
    printf("killing\n");
    system("rm /tmp/mf-wayland.pid");
    printf("removing\n");
  }
  else printf("initscreen - pid does not exist\n");
  int n;
  FILE *fp=fopen("/tmp/mf-wayland.bin","w");
  for (n =0; n < WIDTH*HEIGHT; n++) { /* create blank file */
    fprintf(fp,"%c%c%c%c", 255, 255, 255, 0); // white
  }
  fclose(fp);
  return 1;
}
int first = 1;
void
mf_x11_updatescreen (void)
{
  printf("** updatestreen called\n");
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) {
    printf("updatescreen - pid exists\n");
    system("kill `cat /tmp/mf-wayland.pid`");
    printf("killing\n");
    system("rm /tmp/mf-wayland.pid");
    if (!first) {
      system("/usr/local/way/way &");
      while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
      printf("starting way\n");
    }
  }
  else printf("updatescreen - pid does not exist\n");
  if (first) {
    printf("first run\n");
    first = 0;
    system("/usr/local/way/way &");
    printf("starting way\n");
    while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
  } else printf("not first run\n");
}

void
mf_x11_blankrectangle(screencol left,
                      screencol right,
                      screenrow top,
                      screenrow bottom)
{

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
           if (init_color==0) fprintf(fp,"%c%c%c%c", 255, 255, 255, 0); // white
           else fprintf(fp,"%c%c%c%c", 0, 0, 0, 0); // black
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
  fclose(fp);
}
