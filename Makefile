all:
	cp web2w/cmf.w mf.w
	for i in constants.ch pk.ch screen.ch $(CHF); do \
	  wmerge mf.w $$i >out.w || exit; mv out.w mf.w; done
	ctangle mf
	gcc -DINIT mf.c -o inimf
	@./inimf 'plain; input local; dump' >/dev/null; mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf
	@mf '\mode:=localfont; input gray' >/dev/null; rm gray.log gray.*gf gray.*pk
	@mf '\mode:=localfont; input black' >/dev/null; rm black.log black.*gf black.*pk
	@mf '\mode:=localfont; input slant6' >/dev/null; rm slant6.log slant6.*gf slant6.*pk
	@rm -f /home/user/tex/TeXfonts/*pk

trapmf:
	cp web2w/cmf.w mf.w
	for i in trap/constants.ch trap/screen.ch $(CHF); do \
	  wmerge -h mf.w $$i >out.w || exit; mv out.w mf.w; done
	ctangle mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
