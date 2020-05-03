all: change-file web2w/ctangle
	web2w/ctangle -bhp mf mf # if you need to disable ch-file, put `#' after constants.ch, not here
	make -C window
	gcc -g -Og -DINIT -o inimf mf.c -lm window/wl.a
	@echo 'plain dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -o virmf mf.c -lm window/wl.a

SHELL=/bin/bash
trapmf: change-file web2w/ctangle
	diff <(wmerge -h mf.w constants.ch) <(wmerge -h mf.w mf.ch) | patch -sl mf.w -o trapmf.w # subtract constants.ch from mf.ch
	web2w/ctangle -bhp trapmf.w trap/constants.ch
	gcc -DINIT -DSTAT trapmf.c -lm -o trap/trapmf

ifeq ($(MAKECMDGOALS),trapmf)
window.ch=
else
window.ch=window.ch
endif
change-file:
	tie -bhp -c mf.ch mf.w constants.ch exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch banner.ch $(window.ch)

web2w/ctangle:
	make -C web2w ctangle

view:
	@make --no-print-directory -C window $@
	@tex window >/dev/null
	@echo use \"dvi window\" to view the document

print:
	@make --no-print-directory -C window $@
	@tex window >/dev/null
	@echo use \"prt window\" to print the document
