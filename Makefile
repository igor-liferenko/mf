all: wayland web2w/ctangle change-file
	web2w/ctangle -bhp mf mf
	./edit.pl screen.h
	gcc -g -Og -DINIT mf.c wayland.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og mf.c wayland.c -o virmf

trapmf: web2w/ctangle
	tie -bhp -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF)
	web2w/ctangle -bhp mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

change-file:
	tie -bhp -c mf.ch mf.w constants.ch screen.ch $(CHF)
CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch

web2w/ctangle:
	make -C web2w ctangle

wayland:
	ctangle -bhp wayland
