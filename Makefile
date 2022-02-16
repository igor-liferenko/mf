all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf
	@./inimf 'plain; input local; dump' >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@./plain '\mode:=localfont; input gray' >/dev/null; rm gray.log gray.*gf gray.*pk
	@./plain '\mode:=localfont; input black' >/dev/null; rm black.log black.*gf black.*pk
	@./plain '\mode:=localfont; input slant6' >/dev/null; rm slant6.log slant6.*gf slant6.*pk
	@rm -f /home/user/tex/TeXfonts/*pk

trapmf:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
