OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLRUN = ocamlrun

.PHONY: all opt
all: wclient.cmo
opt: wclient.cmx

wclient.cmo: wclient.ml wclient.cmi
	$(OCAMLC) -c unix.cma $<

wclient.cmx: wclient.ml wclient.cmi
	$(OCAMLOPT) -c unix.cmxa $<

wclient.cmi: wclient.mli
	$(OCAMLC) -c unix.cma $<

.PHONY: clean
clean:
	$(RM) *.o *.cm[iox] *.opt *.byte

