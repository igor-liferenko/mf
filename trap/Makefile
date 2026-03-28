all:
	@make -C .. trapmf
	@rm -f trap.log trap.base
	@printf '\n\input trap\n' | ./trapmf >/dev/null || true
	@diff mf/trapin.log trap.log
	@rm -f trap.72270gf trap.log trap.tfm
	@printf ' &trap  trap \n' | ./trapmf | sed '2s/**/** \&trap  trap \n/' >trap.fot
	@max_rows=79 max_cols=79 line_length=79 gftype -i -m trap.72270gf | sed 's/ (TeX Live .*//' >trap.typ
	@diff mf/trap.typ trap.typ
	@sed -i -f traplog.sed trap.log
	@diff mf/trap.log trap.log
	@sed -i -f trapfot.sed trap.fot
	@printf '\n' >>trap.fot
	@diff mf/trap.fot trap.fot
	@tftopl trap.tfm | diff mf/trap.pl -
	@printf '\n%s\n\n' 'Passed.'
