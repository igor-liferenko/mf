\let\lheader\rheader
\datethis

\font\logo=manfnt

% NOTE: the same principle is used here as in way/surface.c, but the shm_data is
% taken from STDIN_FILENO

@ @c
@<Header files@>;
typedef uint32_t pixel_t;
@<Global...@>;
@<Function prototypes@>@;
void terminate(int signum)
{
  (void) signum;
  wl_display_disconnect(display);
  exit(0);
}
@<Keep-alive@>;
@<On-top detection@>@;
@<Get registry@>;
@<Get notified when compositor can draw@>@;

volatile char on_top = 1;
volatile char mf_update = 0;

@ @c
void update(int signum)
{
  (void) signum;
  mf_update = 1;
  if (on_top == 0) {
    char dummy = on_top;
    write(STDOUT_FILENO, &dummy, 1);
  }
}
sigset_t update_signal;
int main(int argc, char *argv[])
{
    @<Get screen resolution@>@;
    sigemptyset(&update_signal);
    sigaddset(&update_signal, SIGUSR1);
    @<Install terminate signal handler@>;
    @<Install update signal handler@>;
    @<Setup wayland@>;
    @<Create surface@>;
    @<Create buffer@>;
    @<Attach buffer to surface@>@;
    @<Request ``compositor free'' notification@>@;
    @<Commit surface@>@;
    @<Notify parent@>;
    while (wl_display_dispatch(display) != -1) { /* this function blocks - it exits only
                                                    when window focus is changed */
    }
    return EXIT_SUCCESS;
}

@ @<Get screen resolution@>=
if (argc != 3) exit(EXIT_FAILURE);
if (sscanf(argv[1], "%d", &screenwidth) != 1) exit(EXIT_FAILURE);
if (sscanf(argv[2], "%d", &screendepth) != 1) exit(EXIT_FAILURE);

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
void *shm_data;
struct wl_surface *surface;
struct wl_shell_surface *shell_surface;
struct wl_shm_pool *pool;
int32_t screenwidth, screendepth;

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

@ Whenever something is added to the registry our program will be notified by wayland
running this callback.
This callback is assigned via |wl_registry_add_listener| in another section.

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
    @<Get seat from the registry@>@;
}

static const struct wl_registry_listener registry_listener = {
    registry_global,
    NULL
};

@ @<Get notified when compositor can draw@>=
const struct wl_callback_listener frame_listener = {
    redraw
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
#if 1==0
wl_shell_surface_set_title(shell_surface, "METAFONT"); /* FIXME: this does not work */
#endif
@^FIXME@>
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
int fd = os_create_anonymous_file(screenwidth*screendepth*(int32_t)sizeof(pixel_t));
if (fd < 0) {
  fprintf(stderr, "creating a buffer file failed: %m\n");
  exit(1);
}
shm_data = mmap(NULL, (size_t)(screenwidth*screendepth)*sizeof(pixel_t),
  PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
if (shm_data == MAP_FAILED) {
  fprintf(stderr, "mmap failed: %m\n");
  close(fd);
  exit(1);
}
@<Fill |shm_data|@>@;
pool = wl_shm_create_pool(shm, fd, screenwidth*screendepth*(int32_t)sizeof(pixel_t));
buffer = wl_shm_pool_create_buffer(pool,
  0, screenwidth, screendepth,
  screenwidth*(int32_t)sizeof(pixel_t), WL_SHM_FORMAT_XRGB8888);
wl_shm_pool_destroy(pool);

@ @<Attach buffer to surface@>=
wl_surface_attach(surface, buffer, 0, 0);

@ The commit operation tells the compositor it's time to atomically
perform all the surface operations you've been sending it.
Any surface requests prior to the commit have been buffered, and could have
been requested in any order (the compositor performs them in the appropriate order during
the commit).

@<Commit surface@>=
wl_surface_commit(surface);

@ The notification will only be posted for one frame unless requested again.
The object returned by this request will be destroyed by the compositor after
the callback is fired and as such the client must not attempt to use it after that point.

@<Request ``compositor free'' notification@>=
wl_callback_add_listener(wl_surface_frame(surface), &frame_listener, NULL);

@ Damage only after update.
@<Function prototypes@>=
void redraw(void *data, struct wl_callback *callback, uint32_t time);
@ @c
void redraw(void *data, struct wl_callback *callback, uint32_t time)
{
#if 1==0
  FILE *fp=fopen("/tmp/x","a");
  fprintf(fp,"x\n");
  fclose(fp);
#endif
    (void) data;
    wl_callback_destroy(callback);
    (void) time;
    if (mf_update) {
      mf_update=0;
      @<Fill...@>@;
      wl_surface_damage(surface, 0, 0, screenwidth, screendepth);
      char dummy = 1;
      write(STDOUT_FILENO, &dummy, 1);
    }
    @<Request ``compositor free'' notification@>@;
    @<Commit surface@>@;
}

@ @<Fill...@>=
lseek(STDIN_FILENO,0,SEEK_SET);
pixel_t *pixel = shm_data;
for (int n = 0; n < screenwidth * screendepth; n++) {
  read(STDIN_FILENO, pixel, 4);
  pixel++;
}

@* Active window detection.

@ @<Global...@>=
struct wl_seat *seat = NULL;

@ @<Get seat from the registry@>=
else if (strcmp(interface,"wl_seat") == 0) {
  seat = wl_registry_bind (registry, id, &wl_seat_interface, 1);
  wl_seat_add_listener(seat, &seat_listener, NULL);
}

@ @<On-top...@>=
struct wl_seat_listener seat_listener = { &seat_capabilities, NULL };
struct wl_keyboard_listener keyboard_listener = {
  &keyboard_keymap,
  &keyboard_enter,
  &keyboard_leave,
  &keyboard_key,
  &keyboard_modifiers,
  NULL
};

@ @<Function prototypes@>=
void keyboard_enter (void *data, struct wl_keyboard *keyboard, uint32_t serial,
  struct wl_surface *surface, struct wl_array *keys);
@ @c
void keyboard_enter (void *data, struct wl_keyboard *keyboard, uint32_t serial,
  struct wl_surface *surface, struct wl_array *keys) {
  (void) data;
  (void) keyboard;
  (void) serial;
  (void) surface;
  (void) keys;
  on_top=1;
}

@ @<Function prototypes@>=
void keyboard_leave(void *data, struct wl_keyboard *keyboard,
  uint32_t serial, struct wl_surface *surface);
@ @c
void keyboard_leave(void *data, struct wl_keyboard *keyboard,
  uint32_t serial, struct wl_surface *surface) {
  (void) data;
  (void) keyboard;
  (void) serial;
  (void) surface;
  on_top=0;
}

@ @<Function prototypes@>=
void seat_capabilities (void *data, struct wl_seat *seat, uint32_t capabilities);
@ @c
void seat_capabilities (void *data, struct wl_seat *seat, uint32_t capabilities) {
  (void) data;
        if (capabilities & WL_SEAT_CAPABILITY_KEYBOARD) {
                struct wl_keyboard *keyboard = wl_seat_get_keyboard (seat);
                wl_keyboard_add_listener (keyboard, &keyboard_listener, NULL);
        }
}

@ @<Function prototypes@>=
void keyboard_modifiers (void *data, struct wl_keyboard *keyboard, uint32_t serial, uint32_t
mods_depressed, uint32_t mods_latched, uint32_t mods_locked, uint32_t group);
@ @c
void keyboard_modifiers (void *data, struct wl_keyboard *keyboard, uint32_t serial, uint32_t
mods_depressed, uint32_t mods_latched, uint32_t mods_locked, uint32_t group) {
  (void) data;
  (void) keyboard;
  (void) serial;
  (void) mods_depressed;
  (void) mods_latched;
  (void) mods_locked;
  (void) group;
}

@ @<Function prototypes@>=
void keyboard_keymap (void *data, struct wl_keyboard *keyboard, uint32_t format, int32_t fd,
uint32_t size);
@ @c
void keyboard_keymap (void *data, struct wl_keyboard *keyboard, uint32_t format, int32_t fd,
uint32_t size) {
  (void) data;
  (void) keyboard;
  (void) format;
  (void) fd;
  (void) size;
}

@ @<Function prototypes@>=
void keyboard_key (void *data, struct wl_keyboard *keyboard, uint32_t serial, uint32_t time,
uint32_t key, uint32_t state);
@ @c
void keyboard_key (void *data, struct wl_keyboard *keyboard, uint32_t serial, uint32_t time,
uint32_t key, uint32_t state) {
  (void) data;
  (void) keyboard;
  (void) serial;
  (void) time;
  (void) key;
  (void) state;
}

@* Anonymous file.
TODO: do via sections instead of functions
@^TODO@>

@ @<Func...@>=
int set_cloexec_or_close(int fd);
@ @c
int set_cloexec_or_close(int fd)
{
        long flags;

        if (fd == -1)
                return -1;

        flags = fcntl(fd, F_GETFD);
        if (flags == -1)
                goto err;

        if (fcntl(fd, F_SETFD, flags | FD_CLOEXEC) == -1)
                goto err;

        return fd;

err:
        close(fd);
        return -1;
}

@ @<Func...@>=
int create_tmpfile_cloexec(char *tmpname);
@ @c
int create_tmpfile_cloexec(char *tmpname)
{
        int fd;

#ifdef HAVE_MKOSTEMP
        fd = mkostemp(tmpname, O_CLOEXEC);
        if (fd >= 0)
                unlink(tmpname);
#else
        fd = mkstemp(tmpname);
        if (fd >= 0) {
                fd = set_cloexec_or_close(fd);
                unlink(tmpname);
        }
#endif

        return fd;
}

@ @<Func...@>=
int os_create_anonymous_file(off_t size);
@ @c
int os_create_anonymous_file(off_t size)
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

        fd = create_tmpfile_cloexec(name);

        free(name);

        if (fd < 0)
                return -1;

        if (ftruncate(fd, size) < 0) {
                close(fd);
                return -1;
        }

        return fd;
}

@ @<Head...@>=
#include <stdio.h>
#include <time.h>
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
