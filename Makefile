.PHONY: all
all: osm_api.cmo

osm_api.cmi: osm_api.mli
	ocamlc -c -I webget/ -I +xml-light $<

osm_api.cmo: osm_api.ml osm_api.cmi
	ocamlc -c -I webget/ -I +xml-light osm_api.ml

.PHONY: doc
doc:
	mkdir -p doc
	ocamldoc -d doc -html osm_api.mli

.PHONY: clean
clean:
	$(RM) *.[oa] *.cm[ioxa] *.opt *.byte

