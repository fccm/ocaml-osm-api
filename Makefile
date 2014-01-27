OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLDOC = ocamldoc
OCAML_INC = -I wclient -I +xml-light

.PHONY: all opt
all: osm_api.cmo
opt: osm_api.cmx

osm_api.cmi: osm_api.mli
	$(OCAMLC) -c $(OCAML_INC) $<

osm_api.cmo: osm_api.ml
	$(OCAMLC) -c $(OCAML_INC) $<

osm_api.cmx: osm_api.ml
	$(OCAMLOPT) -c $(OCAML_INC) $<

osm_api.cmo: osm_api.ml osm_api.cmi
osm_api.cmx: osm_api.ml osm_api.cmi

.PHONY: doc
doc:
	mkdir -p doc
	$(OCAMLDOC) -d doc -html osm_api.mli

.PHONY: clean
clean:
	$(RM) *.[oa] *.cm[ioxa] *.opt *.byte

