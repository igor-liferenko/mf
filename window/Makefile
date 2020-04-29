wl: wayland
	ctangle wl
	gcc -g -Og -c wl.c

wayland:
	ctangle wayland
	gcc -o /var/local/bin/wayland wayland.c -lwayland-client

view:
	@cweave wl >/dev/null
	@cweave wayland >/dev/null

print:
	@cweave wl wayland >/dev/null
	@cweave wayland wayland >/dev/null
