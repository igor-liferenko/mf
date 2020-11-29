all:
	patch -so mf-goto.w mf.w goto.patch
	tie -c mf.ch mf-goto.w constants.ch screen.ch gftopk.ch $(CHF) >/dev/null
	/bin/ctangle mf-goto mf mf
	gcc -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf

trapmf:
	patch -so mf-goto.w mf.w goto.patch
	tie -c mf.ch mf-goto.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf-goto mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch interrupt.ch arg.ch print.ch editor.ch format.ch time.ch verify.ch
