all:
	/bin/ctangle web2w
	flex -o web.lex.c web.l
	bison --warnings=none -d -v pascal.y
	gcc -o web2w web2w.c web.lex.c pascal.tab.c
	cp mf.web mf-web2w.web
	sed -i '/@d t_of_the_way/s/\(,t\)\?@=[()]@>#\?//' mf-web2w.web
	sed -i '/trans_spec=/d;s/trans_spec/array[screen_col] of screen_col/' mf-web2w.web
	perl -i -ne 'BEGIN{open F, ">tmp.web";print F "{<<<}\n"}if(!$$f || ($$f&&/^$$/)){print}else{print F} $$f=1 if /@<Other local variables for \|fill_envelope\|@>=/; $$f=0 if /^$$/;END{print F "{>>>}\n"}' mf-web2w.web
	sed -i '/@<Other local variables for |fill_envelope|@>@;/e cat tmp.web' mf-web2w.web
	sed -i 's/\bvoid\b/XvoidX/g' mf-web2w.web
	./web2w -p -o mf.w mf-web2w.web
	sed -i 's/XvoidX/void/g' mf.w
