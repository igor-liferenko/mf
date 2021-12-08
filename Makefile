all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -O3 -DSTAT mf.c -o virmf
	@/home/user/mf/plain gray >/dev/null; rm gray.log gray.*pk gray.*gf
	@/home/user/mf/plain black >/dev/null; rm black.log black.*pk black.*gf
	@/home/user/mf/plain slant6 >/dev/null; rm slant6.log slant6.*pk slant6.*gf
	@rm -f /usr/local/share/texmf/fonts/pk/*

trapmf:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
