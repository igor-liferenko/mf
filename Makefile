all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf
	@./inimf 'plain; input local; dump' >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@for i in `ls black.mf gray.mf slant*.mf | sed 's/\.mf//'`; do \
	   ./plain '\mode=localfont; input '$$i >/dev/null || exit; \
	   rm $$i.log $$i.*gf $$i.*pk; done # make tfm files correspond to resolution in local.mf
	@rm -f /home/user/tex/TeXfonts/*pk

trapmf:
	@[ $(MAKELEVEL) != 0 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
