all: web2w/ctangle change-file
	web2w/ctangle -bhp mf mf
	./edit.pl screen.h
	ctangle -bhp libwayland
	gcc -g -Og -c libwayland.c
	gcc -g -Og -DINIT -o inimf mf.c -lm libwayland.o
	@echo 'plain dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm libwayland.o

trapmf: web2w/ctangle
	tie -bhp -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF)
	web2w/ctangle -bhp mf mf
	gcc -DINIT -DSTAT mf.c -lm -o trap/trapmf

CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch
change-file:
	tie -bhp -c mf.ch mf.w constants.ch screen.ch $(CHF)

web2w/ctangle:
	make -C web2w ctangle

wayland: wayland.c
	gcc -o $@ $< -lwayland-client
