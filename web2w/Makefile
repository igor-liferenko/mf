all:
	/bin/ctangle web2w
	flex -o web.lex.c web.l
	bison --warnings=none -d -v pascal.y
	gcc -o web2w web2w.c web.lex.c pascal.tab.c
	cp mf.web mf-web2w.web
	@# 1:
	sed -i '/@d t_of_the_way/s/\(,t\)\?@=[()]@>#\?//' mf-web2w.web
	@# 2:
	sed -i 's/screen_pixel\[r,c\]/screen_pixel[r]/' mf-web2w.web
	@# 3:
	sed -i '/trans_spec=/d;s/row_transition:trans_spec/row_transition:array[screen_col] of screen_col/' mf-web2w.web
	@# 4:
	sed -n '/@<Other local variables for |fill_envelope|@>=/,/^$$/p' mf-web2w.web | sed '1s/.*/{<<<}/' | sed '$$s/.*/{>>>}/' >tmp.ww
	awk -i inplace '/@<Other local variables for \|fill_envelope\|@>=/{print;getline;while($$0!~/^$$/){getline}}1' mf-web2w.web
	sed -i '/@<Other local variables for |fill_envelope|@>@;/r tmp.ww' mf-web2w.web
	@# 5:
	sed -i 's/until lll=0$$/until llll=0;/' mf-web2w.web
	@# 6:
	#!!! sed -i 's/\bvoid\b/XvoidX/g' mf-web2w.web
	sed -i 's/\bvoid\b/empty/g' mf-web2w.web
	./web2w -p -o mf.w mf-web2w.web ###########################################################
	@# 1:
	@# 2:
	@# 3:
	@# 4:
	sed -n '/\/\*<<<\*\//,/\/\*>>>\*\//{/\/\*>>>\*\//q;p}' mf.w | sed 1d >tmp.ww
	sed -i '/\/\*<<<\*\//,/\/\*>>>\*\//d' mf.w
	sed -i '/@<Other local variables for |fill_envelope|@>=/r tmp.ww' mf.w; rm tmp.ww
	@# 5:
	sed -i 's/while (!(llll==0));/while (!(lll==0))/' mf.w
	sed -i 's/for (k=str_start\[s\]+b-1; k>=str_start\[s\]+a; k--) append_char(so(str_pool\[k\]))/&;/' mf.w # FIXME: /{&;}/ ? and for second "for" /{&}/ ?
	sed -i 's/trans_spec/screen_col/' mf.w
	@# 6:
	#!!! sed -i 's/XvoidX/void/g' mf.w
