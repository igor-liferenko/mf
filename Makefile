all: change-file web2w/ctangle
	web2w/ctangle -bhp mf mf # if you need to disable ch-file, put `#' after constants.ch, not here
	gcc -g -Og -DINIT -o inimf mf.c -lm
	@echo 'plain dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm

SHELL=/bin/bash
trapmf: change-file web2w/ctangle
	diff <(wmerge -h mf.w constants.ch) <(wmerge -h mf.w mf.ch) | patch -sl mf.w -o trapmf.w # subtract constants.ch from mf.ch
	web2w/ctangle -bhp trapmf.w trap/constants.ch
	gcc -DINIT -DSTAT trapmf.c -lm -o trap/trapmf

change-file:
	tie -bhp -c mf.ch mf.w constants.ch #path.ch interrupt.ch arg.ch output.ch editor.ch format.ch time.ch banner.ch exit.ch

web2w/ctangle:
	make -C web2w ctangle
