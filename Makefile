all:
	make -C web2w
	tie -m mf.w web2w/cmf.w web2w/cmf.ch >/dev/null
	tie -c mf.ch mf.w $(CHF) path.ch constants.ch screen.ch comment.ch >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf -lrt
	@./inimf 'plain; input local; dump' >/dev/null && mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf -lrt

trapmf:
	@[ $(MAKELEVEL) = 1 ]
	make -C web2w
	tie -m mf.w web2w/cmf.w web2w/cmf.ch >/dev/null
	tie -c mf.ch mf.w $(CHF) trap/constants.ch trap/screen.ch >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=charset.ch interrupt.ch arg.ch print.ch preload.ch time.ch log.ch edit.ch exit.ch close.ch 64bit.ch
