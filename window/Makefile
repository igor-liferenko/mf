wl: way
	ctangle wl
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o wl.o wl.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o wl.o
	ranlib libwindow.a

way:
	ctangle way
	clang -o /usr/local/bin/way way.c -lwayland-client

view:
	@cweave wl >/dev/null
	@cweave way >/dev/null

print:
	@cweave wl wayland >/dev/null
	@cweave way wayland >/dev/null
