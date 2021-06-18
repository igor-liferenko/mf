all:
	/bin/ctangle web2w web2w-mf
	patch web.l -o web-mf.l <web-mf.patch
	flex -o web.lex.c web-mf.l
	patch pascal.y -o pascal-mf.y <pascal-mf.patch
	bison --warnings=none -d -v pascal-mf.y
	gcc -o web2w web2w.c web.lex.c pascal-mf.tab.c
	cp mf.web mf-web2w.web
	@perl -0777 -i -pe 's/\@{[^{]+screen_pixel\[r,c\].*?\@}//gs' mf-web2w.web
	@# 1:
	@sed -i 's/@d t_of_the_way_end(#)==#,t@=)@>/@d t_of_the_way_end(#)==#/' mf-web2w.web
	@sed -i 's/@d t_of_the_way(#)==#-take_fraction@=(@>#-t_of_the_way_end/@d t_of_the_way(#)==#-take_fraction-t_of_the_way_end/' mf-web2w.web
	@# 2:
	@sed -i '/trans_spec=/d;s/row_transition:trans_spec/row_transition:array[screen_col] of screen_col/' mf-web2w.web
	@# 3:
	@sed -n '/@<Other local variables for |fill_envelope|@>=/,/^$$/p' mf-web2w.web | sed '1s/.*/{<<<}/' | sed '$$s/.*/{>>>}/' >tmp.ww
	@awk -i inplace '/@<Other local variables for \|fill_envelope\|@>=/{print;getline;while($$0!~/^$$/){getline}}1' mf-web2w.web
	@sed -i '/@<Other local variables for |fill_envelope|@>@;/r tmp.ww' mf-web2w.web; rm tmp.ww
	@# 4:
	@sed -i 's/until lll=0$$/until llll=0;/' mf-web2w.web
	@# 5:
	@sed -i 's/\bvoid\b/XvoidX/g' mf-web2w.web
	@######################################################################
	./web2w -o cmf.w mf-web2w.web
	@######################################################################
	@# 1:
	@sed -i 's/@d t_of_the_way_end(X)\tX/@d t_of_the_way_end(X)\tX,t@=)@>/' cmf.w
	@sed -i 's/@d t_of_the_way(X)\tX-take_fraction-t_of_the_way_end/@d t_of_the_way(X)\tX-take_fraction@=(@>X-t_of_the_way_end/' cmf.w
	@# 2:
	@sed -i 's/trans_spec/screen_col/' cmf.w
	@# 3:
	@awk '/\/\*<<<\*\//{getline;while($$0!~/\/\*>>>\*\//){print;getline}exit}' cmf.w >tmp.ww
	@sed -i '/\/\*<<<\*\//,/\/\*>>>\*\//d' cmf.w
	@sed -i '/@<Other local variables for |fill_envelope|@>=/r tmp.ww' cmf.w; rm tmp.ww
	@# 4:
	@sed -i 's/while (!(llll==0));/while (!(lll==0))/' cmf.w
	@# 5:
	@sed -i 's/XvoidX/vоid/g' cmf.w
	patch -s cmf.w cmf.patch
