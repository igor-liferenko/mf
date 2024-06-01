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
	@sed -i 's/\[r,c\]/[rc]/' mf-web2w.web
	@sed -i '/t_of_the_way/{s/#,t@=)@>/R/;s/@=(@>#/L/}' mf-web2w.web
	@sed -i '/trans_spec=/d' mf-web2w.web
	@sed -i '0,/@<Other local variables for |fill.*@;/s//@{&@}/' mf-web2w.web
	@sed -i '0,/until lll=0/s//&;/' mf-web2w.web
	./web2w -o cmf.w mf-web2w.web
	@sed -i 's/\[rc\]/[r,c]/' cmf.w
	@sed -i '/t_of_the_way/{s/R/X,t@=)@>/;s/L/@=(@>X/}' cmf.w
	@sed -i '/trans_spec/{s//screen_col/;s/;/[screen_width+1];/}' cmf.w
	@sed -i '/@<Other local variables for |fill.*@;/s/[/*]//g' cmf.w
	@sed -i '0,/while (!(lll==0))/{//s/;//}' cmf.w
	patch -s cmf.w cmf.patch
