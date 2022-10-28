all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf
	./inimf 'plain; input local; dump' >/dev/null && mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@for i in gray.mf black.mf slant?*.mf; do ./plain '\mode=localfont; batchmode; input '$$i \
	>/dev/null || exit; rm $${i%mf}log $${i%mf}[0-9]*; done # generate tfm files for gray fonts
	@rm -f ~/tex/TeXfonts/*pk # mode parameters could change

trapmf:
	@[ $(MAKELEVEL) = 1 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=charset.ch path.ch search.ch interrupt.ch arg.ch print.ch preload.ch time.ch name.ch exit.ch editor.ch
