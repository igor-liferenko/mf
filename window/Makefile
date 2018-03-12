wayland: way doc
	ctangle wayland
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o wayland.o wayland.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o wayland.o
	ranlib libwindow.a

way:
	ctangle way
	clang -o way way.c -lwayland-client

doc:
	cweave wayland
	cweave way
	tex tcb
