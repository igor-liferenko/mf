all:
	patch -so mf-goto.w mf.w goto.patch
	tie -c mf.ch mf-goto.w constants.ch screen.ch gftopk.ch $(CHF) >/dev/null
	/bin/ctangle mf-goto mf mf
	ctangle wayland
	gcc -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf

trapmf:
	patch -so mf-goto.w mf.w goto.patch
	tie -c mf.ch mf-goto.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf-goto mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=format.ch arg.ch path.ch interrupt.ch print.ch editor.ch time.ch
