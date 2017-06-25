/* Wayland window interface for Metafont. */

#define	EXTERN extern
#include "../mfd.h"

#include <mfdisplay.h>
#include <signal.h>
/* Return 1 if display opened successfully, else 0.  */

#define WIDTH 1024
#define HEIGHT 768

int
os_create_anonymous_file(off_t size);

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
int fd;
int
mf_x11_initscreen (void)
{
  this_updatescreen_is_tied_to_initscreen = 1;
  //printf("\ninitscreen called\n");
  if (access("/tmp/mf-wayland.pid", F_OK) != -1) { /* pid file exists */
    printf("\nyou cannot have more than one online graphics display windows simultaneously until you find a way to do without .pid file\n");
    exit(0);
  }
  fd = os_create_anonymous_file(WIDTH*HEIGHT*4);
  for (int n=0; n < WIDTH*HEIGHT; n++) { /* create blank file */
    char pixel[4];
    pixel[0]=rand()%255;
    pixel[1]=rand()%255;
    pixel[2]=rand()%255;
    write(fd,pixel, 4);
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
  else {
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
      char pixel[4];
      pixel[0]=113;
      pixel[1]=253;
      pixel[2]=255;
        /* "white" */
      write(fd,pixel, 4);
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
           char pixel[4];
           if (init_color==0) {
             pixel[0]=113;
             pixel[1]=253;
             pixel[2]=255;
               /* "white" */
           }
           else {
             pixel[0]=0;
             pixel[1]=0;
             pixel[2]=0;
               /* black */
           }
           write(fd,pixel, 4);
           c++;
      } while (c!=*(tvect+k));
      init_color=!init_color;
  } while (k!=vector_size);
}

/* Shared memory.
We will use shared memory to communicate information between client and server.
Unix/Linux has two primary shared memory APIs: the older Sys V model, with calls such as
\\{shmget}, \\{shmat}, etc. This has generally fallen out of favour, with the current
preference being for memory mapped files and devices with |mmap|.

Wayland uses the file-backed shared memory model. There is no expectation that a disk file
is actually written to, but a file descriptor for a new open file is passed from the client
to the server. The file is just a temporary file created using a call such as |mkstemp|. Code
from Weston examples uses the directory |XDG_RUNTIME_DIR|. (XDG stands for the X Desktop Group
which is now freedesktop.org). That directory is typically \.{/run/user/<user-id>}. The Weston
examples also `anonymise' the file by unlinking its name after opening it.

*/
int
create_tmpfile(char *tmpname)
{
        int fd;

        fd = mkstemp(tmpname);
        if (fd >= 0)
                unlink(tmpname);

        return fd;
}

/*
 * Create a new, unique, anonymous file of the given size, and
 * return the file descriptor for it. The file descriptor is set
 * CLOEXEC. The file is immediately suitable for mmap()'ing
 * the given size at offset zero.
 *
 * The file should not have a permanent backing store like a disk,
 * but may have if XDG_RUNTIME_DIR is not properly implemented in OS.
 *
 * The file name is deleted from the file system.
 *
 * The file is suitable for buffer sharing between processes by
 * transmitting the file descriptor over Unix sockets using the
 * SCM_RIGHTS methods.
 */
int
os_create_anonymous_file(off_t size)
{
        static const char template[] = "/weston-shared-XXXXXX";
        const char *path;
        char *name;
        int fd;

        path = getenv("XDG_RUNTIME_DIR");
        if (!path) {
                errno = ENOENT;
                return -1;
        }

        name = malloc(strlen(path) + sizeof(template));
        if (!name)
                return -1;
        strcpy(name, path);
        strcat(name, template);

        fd = create_tmpfile(name);

        free(name);

        if (fd < 0)
                return -1;

        if (ftruncate(fd, size) < 0) {
                close(fd);
                return -1;
        }

        return fd;
}
