wayland: way
	ctangle wayland
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o wayland.o wayland.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o wayland.o
	ranlib libwindow.a

way:
	ctangle way
	clang -o /usr/local/bin/way way.c -lwayland-client

view:
	@cweave wayland >/dev/null
	@cweave way >/dev/null
	@tex tcb >/dev/null

print:
	@cweave wayland wayland >/dev/null
	@cweave way wayland >/dev/null
	@tex tcb >/dev/null
