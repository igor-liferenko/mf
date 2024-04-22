all:
	tie -c web2w.ch web2w.w time.ch web2w-mf.ch >/dev/null
	ctangle web2w web2w
	patch -so web-mf.l web.l web-mf.patch
	flex -o web.lex.c web-mf.l
	patch -so pascal-mf.y pascal.y pascal-mf.patch
	bison --warnings=none -d -v pascal-mf.y
	gcc -o web2w web2w.c web.lex.c pascal-mf.tab.c
	cp mf.web mf-web2w.web
	@sed -i '/@t$$(2^{29}$$@>\*p+q/{s/(//;s/@t/(@t/}' mf-web2w.web # scheduled for 2029 tuneup
	@sed -i '/@{[^}]*$$/,/@}/{/@{/!d;s%@{.*%@/%}' mf-web2w.web
	@# 1:
	@sed -i 's/@d t_of_the_way_end(#)==#,t@=)@>/@d t_of_the_way_end(#)==#/' mf-web2w.web
	@sed -i 's/@d t_of_the_way(#)==#-take_fraction@=(@>#-t_of_the_way_end/@d t_of_the_way(#)==#-take_fraction-t_of_the_way_end/' mf-web2w.web
	@# 2:
	@sed -i '/trans_spec=/d;s/row_transition:trans_spec/row_transition:array[screen_col] of screen_col/' mf-web2w.web
	@# 3:
	@sed -i -e '/@<Other local variables for |fill_envelope|@>=/,/^$$/{//!{w /dev/stdout' -e 'd}}' mf-web2w.web >tmp.hack
	@# 4:
	@sed -i 's/until lll=0$$/until llll=0;/' mf-web2w.web
	@######################################################################
	./web2w -o cmf.w mf-web2w.web
	@######################################################################
	@# 1:
	@sed -i 's/@d t_of_the_way_end(X)\tX/@d t_of_the_way_end(X)\tX,t@=)@>/' cmf.w
	@sed -i 's/@d t_of_the_way(X)\tX-take_fraction-t_of_the_way_end/@d t_of_the_way(X)\tX-take_fraction@=(@>X-t_of_the_way_end/' cmf.w
	@# 2:
	@sed -i 's/trans_spec/screen_col/' cmf.w
	@# 3:
	@sed -i 's%{%/*%;s%}%*/%;s/\(.*\):\([^;]*\)/\2 \1/;s/eger//;s/0..move_size/uint16_t/' tmp.hack
	@sed -i '/@<Other local variables for |fill_envelope|@>=/r tmp.hack' cmf.w; rm tmp.hack
	@# 4:
	@sed -i 's/while (!(llll==0));/while (!(lll==0))/' cmf.w
	patch -s cmf.w cmf.patch
