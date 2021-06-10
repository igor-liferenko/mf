all:
	make -C web2w
	patch -so mf.w web2w/cmf.w goto.patch
	patch -s mf.w malloc.patch
	tie -c mf.ch mf.w constants.ch gftodvi.ch gftopk.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -O3 -DSTAT mf.c -o virmf

trapmf:
	make -C web2w
	patch -so mf.w web2w/cmf.w goto.patch
	patch -s mf.w malloc.patch
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch interrupt.ch arg.ch print.ch editor.ch format.ch time.ch verify.ch
