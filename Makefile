all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w $(CHF) constants.ch screen.ch >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf -lrt
	@./inimf 'plain; input local; dump' >/dev/null && mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf -lrt
	@for i in gray.mf black.mf slant?*.mf; do base=plain ./virmf \
	'\mode=localfont; batchmode; input '$$i >/dev/null || exit; done # 'mode' in mytex/mf+,mf- (it must be mode that is used for printing)

trapmf:
	@[ $(MAKELEVEL) = 1 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w $(CHF) trap/constants.ch trap/screen.ch >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=charset.ch path.ch interrupt.ch arg.ch print.ch preload.ch time.ch log.ch edit.ch name.ch exit.ch
