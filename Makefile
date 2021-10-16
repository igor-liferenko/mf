all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch pk.ch screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT mf.c -o inimf
	@echo 'plain; input local; dump' | ./inimf >/dev/null; mv plain.base MFbases/
	gcc -O3 -DSTAT mf.c -o virmf
	@rm -f /home/user/tex/TeXfonts/*pk
	@printf '\\mode:=localfont; nonstopmode; input gray\n' | /home/user/mf/plain >/dev/null && mv gray.tfm /home/user/tex/TeXfonts/ && rm gray.*
	@printf '\\mode:=localfont; nonstopmode; input black\n' | /home/user/mf/plain >/dev/null && mv black.tfm /home/user/tex/TeXfonts/ && rm black.*

trapmf:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	/bin/ctangle mf mf
	gcc -O3 -DINIT -DSTAT mf.c -o trap/trapmf

CHF=path.ch search.ch interrupt.ch arg.ch print.ch editor.ch preload.ch time.ch verify.ch exit.ch
