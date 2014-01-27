OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLRUN = ocamlrun

#RUNDIR = +unix-red
RUNDIR = ../../ocaml-unix-red/mod

.PHONY: all opt
all: wclient.cmo
opt: wclient.cmx

wclient.cmo: wclient.ml wclient.cmi
	$(OCAMLC) -c -I $(RUNDIR) redUnix.cma $<

wclient.cmx: wclient.ml wclient.cmi
	$(OCAMLOPT) -c unix.cmxa -I $(RUNDIR) redUnix.cmxa $<

wclient.cmi: wclient.mli
	$(OCAMLC) -c -I $(RUNDIR) redUnix.cma $<

.PHONY: clean
clean:
	$(RM) *.o *.cm[iox] *.opt *.byte

