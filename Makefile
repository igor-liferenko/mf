all: change-file web2w/ctangle
	web2w/ctangle -bhp mf mf
	make -C window
	gcc -g -Og -DINIT -o inimf mf.c -lm window/wl.o
	@echo 'plain dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm window/wl.o

SHELL=/bin/bash
trapmf: change-file web2w/ctangle
	tie -bhp -c tmp.ch mf.w constants.ch window.ch
	diff <(wmerge -h mf.w tmp.ch) <(wmerge -h mf.w mf.ch) | patch -sl mf.w -o trapmf.w # subtract constants.ch and window.ch from mf.ch
	tie -bhp -c trapmf.ch trapmf.w trap/constants.ch trap/window.ch
	web2w/ctangle -bhp trapmf.w trapmf.ch
	gcc -DINIT -DSTAT trapmf.c -lm -o trap/trapmf

change-file:
	tie -bhp -c mf.ch mf.w constants.ch exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch window.ch

web2w/ctangle:
	make -C web2w ctangle
