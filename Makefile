.PHONY: all opt
all: osm_api.cmo
opt: osm_api.cmx

osm_api.cmi: osm_api.mli
	ocamlc -c -I wclient/ -I +xml-light $<

osm_api.cmo: osm_api.ml osm_api.cmi
	ocamlc -c -I wclient/ -I +xml-light osm_api.ml

osm_api.cmx: osm_api.ml osm_api.cmi
	ocamlopt -c -I wclient/ -I +xml-light osm_api.ml

.PHONY: doc
doc:
	mkdir -p doc
	ocamldoc -d doc -html osm_api.mli

.PHONY: clean
clean:
	$(RM) *.[oa] *.cm[ioxa] *.opt *.byte

