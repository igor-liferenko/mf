all: change-file web2w/ctangle
	web2w/ctangle -bhp mf mf
	make -C window
	gcc -g -Og -DINIT -o inimf mf.c -lm window/wl.o
	@echo 'plain dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm window/wl.o

SHELL=/bin/bash
trapmf: web2w/ctangle
	tie -bhp -c trapmf.ch mf.w trap/constants.ch trap/window.ch $(CHF)
	web2w/ctangle -bhp mf.w trapmf.ch trapmf
	gcc -DINIT -DSTAT trapmf.c -lm -o trap/trapmf

CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch
change-file:
	tie -bhp -c mf.ch mf.w constants.ch window.ch $(CHF)

web2w/ctangle:
	make -C web2w ctangle
