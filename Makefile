all:
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w constants.ch screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT mf.c -o inimf -lrt
	./inimf 'plain; input local; dump' >/dev/null && mv plain.base MFbases/
	gcc -DSTAT mf.c -o virmf -lrt
	@for i in gray.mf black.mf slant?*.mf; do ./plain '\mode=localfont; batchmode; input '$$i \
	>/dev/null || exit; rm $${i%mf}log $${i%mf}[0-9]*; done # generate tfm files for gray fonts
	@rm -f ~/tex/TeXfonts/*pk # mode parameters could change
	@for i in `cd MFinputs/cm; grep -L Math cm*[0-9]*`; do sed "/font_identifier/s/CM/OM/;s/generate /&ld/;/generate/i def LHver_check(expr e,f)=enddef;\nebbase:=0;\nboolean roman_ec; roman_ec:=false;\ninput lcyrbeg;\ngensize:=`echo $$i|tr -dc 0-9`;\ninput lhcodes;\ninput lcyrdefs;\ninput lxpseudo;" MFinputs/cm/$$i >MFinputs/om/om$${i#cm}; done # fikparm.mf equivalent (except that 'input lxpseudo' was moved from drivers)

trapmf:
	@[ $(MAKELEVEL) = 1 ]
	make -C web2w
	cp web2w/cmf.w mf.w
	tie -c mf.ch mf.w trap/constants.ch trap/screen.ch $(CHF) >/dev/null
	ctangle mf mf
	gcc -DINIT -DSTAT mf.c -o trap/trapmf

CHF=charset.ch path.ch interrupt.ch arg.ch print.ch preload.ch time.ch edit.ch name.ch exit.ch search.ch
