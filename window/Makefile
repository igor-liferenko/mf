wayland:
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o wayland.o wayland.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o wayland.o
	ranlib libwindow.a

x:
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o x11-Xt.o x11-Xt.c
	rm -f libwindow.a
	ar cruU libwindow.a trap.o x11-Xt.o
	ranlib libwindow.a
