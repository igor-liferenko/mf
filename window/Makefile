all:
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o amiga.o amiga.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o epsf.o epsf.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o hp2627.o hp2627.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o mftalk.o mftalk.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o next.o next.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o regis.o regis.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o suntools.o suntools.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o tek.o tek.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o trap.o trap.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o uniterm.o uniterm.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o win32.o win32.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -I.. -Wimplicit -Wreturn-type -g -O2 -c -o x11-Xt.o x11-Xt.c # this place must be changed to wayland
	rm -f libwindow.a
	ar cruU libwindow.a amiga.o epsf.o hp2627.o mftalk.o next.o regis.o suntools.o tek.o trap.o uniterm.o win32.o x11-Xt.o
	ranlib libwindow.a
