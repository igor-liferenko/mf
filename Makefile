all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf
	@rm -f *.tfm *.log
	@./inimf 'plain; input local; dump' >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@./plain '\mode:=localfont; mode_setup; input gray' >/dev/null
	@./plain '\mode:=localfont; mode_setup; input black' >/dev/null
	@./plain '\mode:=localfont; mode_setup; input slant6' >/dev/null
	@rm -f *gf *pk
	@rm -f /home/user/tex/TeXfonts/*pk

trapmf:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
