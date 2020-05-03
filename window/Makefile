wl: wayland
	ctangle wl
	gcc -g -Og -c wl.c
	@ar -cr wl.a wl.o # do via library to avoid errors if window.ch is not used

wayland:
	ctangle wayland
	gcc -o /var/local/bin/wayland wayland.c -lwayland-client

view:
	@cweave wl >/dev/null
	@cweave wayland >/dev/null

print:
	@cweave wl duplex >/dev/null
	@cweave wayland duplex >/dev/null
