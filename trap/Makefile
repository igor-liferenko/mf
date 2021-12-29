all:
	@make -C .. trapmf
	@rm -f trap.log trap.base
	@/bin/echo -e '\n\\input trap' | ./trapmf >/dev/null || true
	@sed -i -f trapin.sed trap.log
	@diff mf/trapin.log trap.log
	@rm -f trap.72270gf trap.log trap.tfm
	@echo ' &trap  trap ' | ./trapmf >trap.fot || true
	@max_rows=79 max_cols=79 line_length=79 gftype -i -m trap.72270gf >trap.typ
	@sed -i -f traptyp.sed trap.typ
	@diff mf/trap.typ trap.typ
	@sed -i -f traplog.sed trap.log
	@diff mf/trap.log trap.log
	@sed -i -f trapfot.sed trap.fot
	@echo >>trap.fot
	@diff mf/trap.fot trap.fot
	@tftopl trap.tfm | diff mf/trap.pl -
	@echo
	@echo Passed.
	@echo
