all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/ # TODO: change "local" to "/usr/local/mode" and create it in post-install.sh values specific for a given installation
	gcc -O3 -DSTAT mf.c -o virmf

trapmf:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch search.ch
