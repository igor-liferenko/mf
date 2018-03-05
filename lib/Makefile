all:
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o basechsuffix.o basechsuffix.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o chartostring.o chartostring.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o coredump.o coredump.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o eofeoln.o eofeoln.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o fprintreal.o fprintreal.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o inputint.o inputint.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o input2int.o input2int.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o main.o main.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o openclose.o openclose.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o printversion.o printversion.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o setupvar.o setupvar.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o uexit.o uexit.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o usage.o usage.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o version.o version.c
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o zround.o zround.c
	rm -f lib.a
	ar cruU lib.a basechsuffix.o chartostring.o coredump.o eofeoln.o fprintreal.o inputint.o input2int.o main.o openclose.o printversion.o setupvar.o uexit.o usage.o version.o zround.o
	ranlib lib.a
