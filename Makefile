all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf
	@./inimf 'plain; input local; dump' >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@for i in gray.mf black.mf slant*.mf; do ./plain '\mode=localfont; input '$$i >/dev/null \
        || exit; rm $${i%mf}log $${i%mf}[0-9]*; done # ensure that tfm files correspond to local.mf
	@rm -f ~/tex/TeXfonts/*pk # ensure that pk files correspond to local.mf

trapmf:
	@[ $(MAKELEVEL) != 0 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
