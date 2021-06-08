all:
	/bin/ctangle web2w
	flex -o web.lex.c web.l
	bison --warnings=none -d -v pascal.y
	gcc -o web2w web2w.c web.lex.c pascal.tab.c
	sed '/trans_spec=/d;s/trans_spec/array[screen_col] of screen_col/' mf.web >mf-web2w.web # web2w does not handle named array types
	sed -i 's/\bvoid\b/XvoidX/g' mf-web2w.web
	./web2w -o mf.w mf-web2w.web
	sed -i 's/XvoidX/void/g' mf.w
