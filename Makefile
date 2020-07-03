all:
	tie -c mf.ch mf.w constants.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	ctangle wayland
	gcc -g -Og -DINIT -o inimf mf.c
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -DSTAT -o virmf mf.c

trapmf:
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -DINIT -DSTAT -o trap/trapmf mf.c

CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch tab.ch
