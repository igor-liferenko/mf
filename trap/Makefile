all:
	@make -C .. triptex
	@rm -f trip.log trip.fmt
	@/bin/echo -e '\n\\input trip' | ./triptex >/dev/null || true
	@perl -i -pe 's/\(HINT\) //' trip.log
	@sed -i -f tripin.sed trip.log
	@diff tex/tripin.log trip.log
	@rm -f trap.72270gf trap.log
	@/bin/echo ' &trip  trip ' | ./triptex >trip.fot || true
	@gftype -i -m trap.72270gf >trap.typ
	@sed -i -f traptyp.sed trap.typ
	@diff mf/trap.typ trap.typ
	@sed -i -f traplog.sed trap.log
	@diff tex/trap.log trap.log
	@perl -i -l -0777 -pe 's/\n$$//' trap.fot
	@sed -i -f tripfot.sed trap.fot
	@diff tex/trip.fot trip.fot
	@tftopl trap.tfm | diff trap.pl -
	@echo
	@echo Passed.
	@echo
