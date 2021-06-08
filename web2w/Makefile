all:
	/bin/ctangle web2w
	flex -o web.lex.c web.l
	bison --warnings=none -d -v pascal.y
	gcc -o web2w web2w.c web.lex.c pascal.tab.c
	cp mf.web mf-web2w.web
	sed -i '/@d t_of_the_way/s/\(,t\)\?@=[()]@>#\?//' mf-web2w.web
	sed -i 's/screen_pixel\[r,c\]/screen_pixel[r]/' mf-web2w.web
	sed -i '/trans_spec=/d;s/row_transition:trans_spec/row_transition:array[screen_col] of screen_col/' mf-web2w.web
	perl -i -ne 'BEGIN{open F, ">tmp.web";print F "{<<<}\n"}if(!$$f || ($$f&&/^$$/)){print}else{print F} $$f=1 if /.<Other local variables for .fill_envelope..>=/; $$f=0 if /^$$/;END{print F "{>>>}\n"}' mf-web2w.web
	sed -i '/@<Other local variables for |fill_envelope|@>@;/r tmp.web' mf-web2w.web
	sed -i 's/until lll=0$$/until llll=0;/' mf-web2w.web
	#sed -i 's/\bvoid\b/XvoidX/g' mf-web2w.web
	sed -i 's/\bvoid\b/empty/g' mf-web2w.web
	./web2w -p -o mf.w mf-web2w.web
	#sed -i 's/XvoidX/void/g' mf.w
	sed -n '/\/\*<<<\*\//,/\/\*>>>\*\//{/\/\*>>>\*\//q;p}' mf.w | sed 1d >tmp.web
	sed -i '/\/\*<<<\*\//,/\/\*>>>\*\//d' mf.w
	sed -i '/.<Other local variables for .fill_envelope..>=/r tmp.web' mf.w
	sed -i 's/while (!(llll==0));/while (!(lll==0))/' mf.w
	sed -i 's/append_char(so(str_pool\[k\]))@;$$/append_char(so(str_pool[k]));/' mf.w
	sed -i 's/trans_spec/screen_col/' mf.w
