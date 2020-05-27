all: wayland change-file
	/usr/bin/ctangle -bhp mf mf
	gcc -g -Og -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -g -Og mf.c -o virmf

trapmf:
	ctie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/usr/bin/ctangle -bhp mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

change-file:
	ctie -c mf.ch mf.w constants.ch screen.ch $(CHF) >/dev/null
CHF=exit.ch format.ch arg.ch path.ch interrupt.ch output.ch editor.ch time.ch

wayland:
	ctangle -bhp wayland
