all:
	patch -so mf-new.w mf.w goto.patch
	tie -c mf.ch mf-new.w constants.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf-new mf mf
	ctangle wayland
	gcc -g -Og -DINIT -o inimf mf.c
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og -DSTAT -o virmf mf.c

trapmf:
	patch -so mf-new.w mf.w goto.patch
	tie -c mf.ch mf-new.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf-new mf mf
	gcc -DINIT -DSTAT -o trap/trapmf mf.c

CHF=format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch tab.ch
