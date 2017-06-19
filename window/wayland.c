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
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) {
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
int first = 1;
void
mf_x11_updatescreen (void)
{
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) {
    system("kill -2 `cat /tmp/mf-wayland.pid`");
    while (access("/tmp/mf-wayland.pid", F_OK) != -1); /* wait until it is fully stopped */
    if (!first) {
      system("/usr/local/way/way &");
      while (access("/tmp/mf-wayland.pid", F_OK) == -1); /* wait until it is fully started */
    }
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
