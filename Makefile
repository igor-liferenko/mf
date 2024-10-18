all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf -lrt
	@./inimf 'plain; input local; dump' >/dev/null && mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf -lrt
	@for i in gray.mf black.mf slant?*.mf; do ./plain '\mode=localfont; batchmode; input '$$i \
	>/dev/null || exit; rm $${i%mf}log $${i%mf}[0-9]*; done # generate tfm files for gray fonts
	@rm -f ~/tex/TeXfonts/*/* # mode parameters could change
	@for i in `cd MFinputs/cm; grep -L Math cm*[0-9]*`; do sed "s/generate /input lcyrbeg;\ngensize:=`echo $$i|tr -dc 0-9`;\ninput omcodes;\ninput lcyrdefs;\n&ld/" MFinputs/cm/$$i >MFinputs/om/om$${i#cm}; done # equivalent to fikparm.mf
	@for i in `cd MFinputs/om; ls om*`; do sed 's/generate \(\w*\)/generate \U\1/' MFinputs/om/$$i >MFinputs/om/$$(echo $${i%.*}|tr a-z A-Z).mf; done # om/om* -> om/OM*
	@for i in `cd MFinputs/lh; ls ld*`; do sed '0,/lgrusu/s//LGRUSU/' MFinputs/lh/$$i >MFinputs/om/$$(echo $${i%.*}|tr a-z A-Z).mf; done # lh/ld* -> om/LD*
	@sed '/CYR_.YO\|CYR_.I_shrt/a charht:=cap_height#;' MFinputs/lh/lgrusu.mf >MFinputs/om/LGRUSU.mf # make height of uppercase accented characters the same as non-accented ones (for strut-based code)

trapmf:
	@[ $(MAKELEVEL) = 1 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=charset.ch path.ch interrupt.ch arg.ch print.ch preload.ch time.ch log.ch edit.ch name.ch exit.ch search.ch fontmaking.ch
