wl: wayland
	ctangle wl
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o wl.o wl.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o wl.o
	ranlib libwindow.a

wayland:
	ctangle wayland
	clang -o /usr/local/bin/wayland wayland.c -lwayland-client

view:
	@cweave wl >/dev/null
	@cweave wayland >/dev/null

print:
	@cweave wl wayland >/dev/null
	@cweave wayland wayland >/dev/null
