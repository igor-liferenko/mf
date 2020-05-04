all:
	ctangle -bhp wl
	gcc -g -Og -c wl.c
	ctangle -bhp wayland
	gcc -o wayland wayland.c -lwayland-client
