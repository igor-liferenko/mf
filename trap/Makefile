all:
	@make -C .. trapmf
	@rm -f trap.log trap.base
	@/bin/echo -e '\n\\input trap' | ./trapmf >/dev/null || true
	@sed -i -f trapin.sed trap.log
	@diff mf/trapin.log trap.log
	@rm -f trap.72270gf trap.log trap.tfm
	@echo ' &trap  trap ' | ./trapmf >trap.fot || true
	@gftype -i -m trap.72270gf >trap.typ
	@sed -i -f traptyp.sed trap.typ
	@diff mf/trap.typ trap.typ
	@sed -i -f traplog.sed trap.log
	@patch -R trap.log <web2c.diff
	@diff mf/trap.log trap.log
	@perl -i -l -0777 -pe 's/\n$$//' trap.fot
	@sed -i -f trapfot.sed trap.fot
	@diff mf/trap.fot trap.fot
	@tftopl trap.tfm | diff mf/trap.pl -
	@echo
	@echo Passed.
	@echo
