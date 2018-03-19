\let\lheader\rheader
\datethis

@s int32_t int
@s uint32_t int

\font\logo=manfnt

@ FIXME: how |mmap| is supposed to fit in example
from \hfil\break \.{https://jan.newmarch.name/Wayland/SharedMemory/} ?

@c
@<Header files@>;
typedef uint32_t pixel_t;
@<Global...@>;
void terminate(int signum)
{
  (void) signum;
  wl_display_disconnect(display);
  exit(0);
}
@<Keep-alive@>;
@<Get registry@>;

volatile int redraw = 0; /* TODO: redraw screen (see "damage" in wl.w) */

volatile int on_top = 0;

@ |on_top| counter increases by one each time graphics window is switched to/from
with Super+Tab; this can be checked using the same test as is described with
``kill -SIGUSR1'' in wl.w, but not using this kill and using Super+Tab to see \.{tail}'s
output

also, to check if |on_top| works correctly, add "printf(initscreen, paintrow,
blankrectangle, updatescreen: dummy in wl.w and run "mf test" (with the same low
resolution)

Instead of using |on_top| variable try to google "how to determine if
window is in foreground in wayland" - maybe there is an API

If you use signal handler to redraw window, decrease |on_top| in it, because
|wl_display_dispatch| will most likely be terminated, which will change
|on_top| although window focus was not changed

instead of setting |redraw| in signal handler, send SIGUSR2 from wl.w
in "else" after reading pipe in |mf_wl_updatescreen| and redraw in
signal handler



@c
void update(int signum)
{
  (void) signum;
  char dummy;
  if (on_top%2) {
    dummy = 0;
    redraw = 0;
  }
  else {
    dummy = 1;
    redraw = 1;
  }
  write(STDOUT_FILENO, &dummy, 1);
}

int main(int argc, char *argv[])
{
    @<Get screen resolution@>@;

    @<Install terminate signal handler@>;
    @<Install update signal handler@>;

    @<Setup wayland@>;
    @<Create surface@>;
    @<Create buffer@>;

    wl_surface_attach(surface, buffer, 0, 0);
    wl_surface_commit(surface);

    @<Notify parent@>;

    while (wl_display_dispatch(display) != -1) { /* this function blocks - it exits only
                                                    when window focus is changed */
        on_top++;
    }

    return EXIT_SUCCESS;
}

@ @<Get screen resolution@>=
int32_t screenwidth, screenheight;
if (argc != 3) exit(EXIT_FAILURE);
if (sscanf(argv[1], "%d", &screenwidth) != 1) exit(EXIT_FAILURE);
if (sscanf(argv[2], "%d", &screenheight) != 1) exit(EXIT_FAILURE);

@ @<Install terminate signal...@>= {
  struct sigaction sa;
  sa.sa_handler = terminate;
  sa.sa_flags = 0;
  sigemptyset(&sa.sa_mask);
  sigaction(SIGINT, &sa, NULL);
}

@ @<Install update signal...@>= {
  struct sigaction sa;
  sa.sa_handler = update;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  sigaction(SIGUSR1, &sa, NULL);
}

@ Allow {\logo METAFONT} to proceed.
This must be done when signal handler is installed {\it and\/} when wayland is fully initialized,
because |SIGINT| may be received in the middle of
wayland initializaiton, which will cause segfault error in libwayland-client.so in \.{dmesg}
output.

This must also be done before exiting in case of error to avoid {\logo METAFONT} being blocked
forever.

The behavior is as follows: if parent did not do |read| before this |write| happens,
this |write| does not block, instead it continues operation as if the data was read.
The parent, if it performs |read| later, will get the passed data in its integrity.
The reason is that the data is buffered, ready to be read when necessary
(see \.{pipe(7)} for more info).

@<Notify parent@>=
char dummy; @+
write(STDOUT_FILENO, &dummy, 1);

@ If we do not use this, we get "window is not responding" warning.
|shell_surface_listener| is activated with |wl_shell_surface_add_listener|
in another section.

@<Keep-alive@>=
void
handle_ping(void *data, struct wl_shell_surface *shell_surface,
							uint32_t serial)
{
    (void) data;
    wl_shell_surface_pong(shell_surface, serial);
}

void
handle_configure(void *data, struct wl_shell_surface *shell_surface,
		 uint32_t edges, int32_t width, int32_t height)
{
  (void) data;
  (void) shell_surface;
  (void) edges;
  (void) width;
  (void) height;
}

const struct wl_shell_surface_listener shell_surface_listener = {
	handle_ping,
	handle_configure,
	NULL
};

@ The |display| object is the most important. It represents the connection
to the display server and is
used for sending requests and receiving events. It is used in the code for
running the main loop.

@<Global variables@>=
struct wl_compositor *compositor;
struct wl_shell *shell;
struct wl_shm *shm;
struct wl_display *display;
struct wl_buffer *buffer;
struct wl_surface *surface;
struct wl_shell_surface *shell_surface;
struct wl_shm_pool *pool;

@ |wl_display_connect| connects to wayland server.

The server has control of a number of objects. In Wayland, these are quite
high-level, such as a DRM manager, a compositor, a text input manager and so on.
These objects are accessible through a {\sl registry}.

We begin the application by connecting to the display server and requesting a
collection of global objects from the server, filling in proxy variables representing them.

@<Setup wayland@>=
struct wl_registry *registry;
display = wl_display_connect(NULL);
if (display == NULL) {
    @<Notify parent@>;
    exit(1);
}

registry = wl_display_get_registry(display);
wl_registry_add_listener(registry, &registry_listener, NULL); /* see |@<Get registry@>|
                                                                 for explanation */
wl_display_dispatch(display);
wl_display_roundtrip(display);
if (compositor == NULL) {
        @<Notify parent@>;
	exit(1);
}

@ Binding is done via |wl_registry_add_listener| in another section.

@<Get registry@>=
void registry_global(void *data,
    struct wl_registry *registry, uint32_t id,
    const char *interface, uint32_t version)
{
    (void) data;
    (void) version;
    if (strcmp(interface, "wl_compositor") == 0)
        compositor = wl_registry_bind(registry, 
				      id, 
				      &wl_compositor_interface, 
				      1);
    else if (strcmp(interface, "wl_shell") == 0)
        shell = wl_registry_bind(registry, id,
                                 &wl_shell_interface, 1);
    else if (strcmp(interface, "wl_shm") == 0)
        shm = wl_registry_bind(registry, id,
                                 &wl_shm_interface, 1);
}

static const struct wl_registry_listener registry_listener = {
    registry_global,
    NULL
};

@ A main design philosophy of wayland is efficiency when dealing with graphics. Wayland
accomplishes that by sharing memory areas between the client applications and the display
server, so that no copies are involved. The essential element that is shared between client
and server is called a shared memory pool, which is simply a memory area mmapped in both
client and servers. Inside a memory pool, a set of images can be appended as buffer objects
and all will be shared both by client and server.

In this program we |mmap| our hardcoded image file. In a typical application, however, an
empty memory pool would be created, for example, by creating a shared memory object with
|shm_open|, then gradually filled with dynamically constructed image buffers representing
the widgets. While writing this program, the author had to decide if he would create an
empty memory pool and allocate buffers inside it, which is more usual and simpler to
understand, or if he would use a less intuitive example of creating a pre built memory
pool. He decided to go with the less intuitive example for an important reason: if you
read the whole program, you'll notice that there's no memory copy operation anywhere. The
image file is open once, and |mmap|ped once. No extra copy is required. This was done to
make clear that a wayland application can have maximal efficiency if carefully implemented.

@ The buffer object has the contents of a surface. Buffers are created inside of a
memory pool (they are memory pool slices), so that they are shared by the client and
the server. In our example, we do not create an empty buffer, instead we rely on the
fact that the memory pool was previously filled with data and just pass the image
dimensions as a parameter.

@ Objects representing visible elements are called surfaces. Surfaces are rectangular
areas, having position and size. Surface contents are filled by using buffer objects.
During the lifetime of a surface, a couple of buffers will be attached as the surface
contents and the server will be requested to redraw the surfaces. In this program, the
surface object is of type |wl_shell_surface|, which is used for creating top level windows.

@<Create surface@>=
surface = wl_compositor_create_surface(compositor);
if (surface == NULL) {
        @<Notify parent@>;
	exit(1);
}
shell_surface = wl_shell_get_shell_surface(shell, surface);
if (shell_surface == NULL) {
        @<Notify parent@>;
	exit(1);
}
wl_shell_surface_set_fullscreen(shell_surface,
  WL_SHELL_SURFACE_FULLSCREEN_METHOD_DEFAULT,0,NULL);
wl_shell_surface_add_listener(shell_surface,
  &shell_surface_listener, NULL); /* see |@<Keep-alive@>| for explanation of this */

@ To make the buffer visible we need to bind buffer data to a surface, that is, we
set the surface contents to the buffer data. The bind operation also commits the
surface to the server. In wayland there's an idea of surface ownership: either the client
owns the surface, so that it can be drawn (and the server keeps an old copy of it), or
the server owns the surface, when the client can't change it because the server is
drawing it on the screen. For transfering the ownership to the server, there's the
commit request and for sending the ownership back to the client, the server sends a
release event. In a generic application, the surface will be moved back and forth, but
in this program it's enough to commit only once, as part of the bind operation.

In the Wayland shared memory model, an area of shared memory is created using the
file descriptor for a file. This memory is then mapped into a Wayland structure
called a pool, which represents a block of data of some kind, linked to the
global Wayland shared memory object. This is then used to create a
Wayland buffer, which is used for most of the window operations later.

@<Create buffer@>=
pool = wl_shm_create_pool(shm, STDIN_FILENO, screenwidth*screenheight*(int32_t)sizeof(pixel_t));
buffer = wl_shm_pool_create_buffer(pool,
  0, screenwidth, screenheight,
  screenwidth*(int32_t)sizeof(pixel_t), WL_SHM_FORMAT_XRGB8888);
wl_shm_pool_destroy(pool);

@ @<Head...@>=
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <wayland-client.h>
#include <errno.h>
#include <signal.h>

@* Index.
