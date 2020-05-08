all: web2w/ctangle change-file
	web2w/ctangle -bhp mf mf
	./edit.pl screen.h
	ctangle -bhp wayland
	gcc -g -Og -c wayland.c
	gcc -g -Og -DINIT -o inimf mf.c -lm wayland.o
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm wayland.o

trapmf: web2w/ctangle
	tie -bhp -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF)
	web2w/ctangle -bhp mf mf
	gcc -DINIT -DSTAT mf.c -lm -o trap/trapmf

change-file:
	tie -bhp -c mf.ch mf.w constants.ch screen.ch $(CHF)
CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch

web2w/ctangle:
	make -C web2w ctangle
